-- Extensions
create extension if not exists pgcrypto;

create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nickname text not null,
  gender text not null check (gender in ('male','female')),
  avatar_url text,
  lover_alias text,
  pair_code text unique not null default upper(substr(replace(gen_random_uuid()::text,'-',''),1,8)),
  created_at timestamptz not null default now()
);

create table if not exists partner_links (
  id uuid primary key default gen_random_uuid(),
  user_id uuid unique not null references profiles(id) on delete cascade,
  partner_id uuid unique not null references profiles(id) on delete cascade,
  partner_gender text not null check (partner_gender in ('male','female')),
  created_at timestamptz not null default now(),
  constraint no_self_partner check (user_id <> partner_id)
);

create table if not exists wallets (
  user_id uuid primary key references profiles(id) on delete cascade,
  currency_name text not null check (currency_name in ('菲币','小币')),
  balance integer not null default 10,
  total_earned integer not null default 10,
  updated_at timestamptz not null default now()
);

create table if not exists tasks (
  id uuid primary key default gen_random_uuid(),
  creator_id uuid not null references profiles(id),
  receiver_id uuid not null references profiles(id),
  title text not null,
  description text,
  reward_amount integer not null check (reward_amount >= 1),
  reward_currency text not null check (reward_currency in ('菲币','小币')),
  status text not null,
  due_at timestamptz,
  category text,
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists idx_tasks_creator on tasks(creator_id, created_at desc);
create index if not exists idx_tasks_receiver on tasks(receiver_id, created_at desc);
create index if not exists idx_tasks_status on tasks(status);

create table if not exists task_status_logs (
  id bigint generated always as identity primary key,
  task_id uuid not null references tasks(id) on delete cascade,
  from_user uuid not null references profiles(id),
  to_status text not null,
  note text,
  created_at timestamptz not null default now()
);

create table if not exists task_completion_proofs (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references tasks(id) on delete cascade,
  submitted_by uuid not null references profiles(id),
  proof_text text,
  proof_image_path text,
  created_at timestamptz not null default now(),
  constraint proof_required check (coalesce(length(trim(proof_text)),0) > 0 or proof_image_path is not null)
);

create table if not exists wallet_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  amount integer not null,
  direction text not null check (direction in ('income','system_init')),
  source_type text not null,
  source_id uuid,
  remark text,
  created_at timestamptz not null default now()
);
create index if not exists idx_wallet_tx on wallet_transactions(user_id, created_at desc);

create table if not exists notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  type text not null,
  title text not null,
  body text,
  is_read boolean not null default false,
  meta jsonb,
  created_at timestamptz not null default now()
);

create table if not exists user_streaks (
  user_id uuid primary key references profiles(id) on delete cascade,
  current_streak integer not null default 0,
  longest_streak integer not null default 0,
  last_completed_date date
);

create table if not exists badges (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  name text not null,
  icon text not null,
  condition_type text not null,
  condition_value integer not null
);

create table if not exists user_badges (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  badge_id uuid not null references badges(id) on delete cascade,
  unlocked_at timestamptz not null default now(),
  unique(user_id, badge_id)
);

-- RPC: confirm task + reward + streak + badge
create or replace function confirm_task_and_reward(p_task_id uuid)
returns void language plpgsql security definer as $$
declare
  t tasks;
  completed_day date;
begin
  select * into t from tasks where id = p_task_id for update;
  if t.status <> 'completed_pending_confirm' then
    raise exception 'invalid status';
  end if;

  update tasks set status = 'completed_rewarded', updated_at = now() where id = p_task_id;

  update wallets
    set balance = balance + t.reward_amount,
        total_earned = total_earned + t.reward_amount,
        updated_at = now()
    where user_id = t.receiver_id;

  insert into wallet_transactions(user_id, amount, direction, source_type, source_id, remark)
  values (t.receiver_id, t.reward_amount, 'income', 'task_reward', t.id, '任务奖励到账');

  completed_day := (now() at time zone 'utc')::date;

  insert into user_streaks(user_id, current_streak, longest_streak, last_completed_date)
  values (t.receiver_id, 1, 1, completed_day)
  on conflict (user_id) do update set
    current_streak = case
      when user_streaks.last_completed_date = completed_day then user_streaks.current_streak
      when user_streaks.last_completed_date = completed_day - 1 then user_streaks.current_streak + 1
      else 1
    end,
    longest_streak = greatest(user_streaks.longest_streak,
      case
        when user_streaks.last_completed_date = completed_day then user_streaks.current_streak
        when user_streaks.last_completed_date = completed_day - 1 then user_streaks.current_streak + 1
        else 1
      end),
    last_completed_date = completed_day;
end $$;

-- Seed badges
insert into badges(code,name,icon,condition_type,condition_value)
values
('first_done','初次完成','✨','completed_count',1),
('streak_3','连续 3 天','🔥','streak_days',3),
('streak_7','连续 7 天','🏅','streak_days',7),
('done_10','累计完成 10 次','🎯','completed_count',10),
('earn_50','累计获得 50 币','💎','total_earned',50)
on conflict (code) do nothing;

-- RLS
alter table profiles enable row level security;
alter table partner_links enable row level security;
alter table wallets enable row level security;
alter table tasks enable row level security;
alter table task_status_logs enable row level security;
alter table task_completion_proofs enable row level security;
alter table wallet_transactions enable row level security;
alter table notifications enable row level security;
alter table user_streaks enable row level security;
alter table user_badges enable row level security;

create policy "self profile" on profiles for all using (id = auth.uid()) with check (id = auth.uid());
create policy "partner link own" on partner_links for all using (user_id = auth.uid() or partner_id = auth.uid()) with check (user_id = auth.uid());
create policy "wallet own" on wallets for select using (user_id = auth.uid());
create policy "task participant" on tasks for all using (creator_id = auth.uid() or receiver_id = auth.uid()) with check (creator_id = auth.uid());
create policy "status log participant" on task_status_logs for select using (from_user = auth.uid() or exists(select 1 from tasks t where t.id=task_id and (t.creator_id=auth.uid() or t.receiver_id=auth.uid())));
create policy "proof participant" on task_completion_proofs for all using (submitted_by = auth.uid() or exists(select 1 from tasks t where t.id=task_id and (t.creator_id=auth.uid() or t.receiver_id=auth.uid()))) with check (submitted_by = auth.uid());
create policy "wallet tx own" on wallet_transactions for select using (user_id = auth.uid());
create policy "notification own" on notifications for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "streak own" on user_streaks for select using (user_id = auth.uid());
create policy "user badges own" on user_badges for select using (user_id = auth.uid());
