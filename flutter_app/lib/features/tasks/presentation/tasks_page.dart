import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/glass_card.dart';
import '../data/task_repository.dart';
import '../domain/task_models.dart';

final myTasksProvider = FutureProvider.autoDispose((ref) => ref.watch(taskRepositoryProvider).listTasks(mine: true));
final receivedTasksProvider = FutureProvider.autoDispose((ref) => ref.watch(taskRepositoryProvider).listTasks(mine: false));

class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  int segment = 0;

  @override
  Widget build(BuildContext context) {
    final provider = segment == 0 ? myTasksProvider : receivedTasksProvider;
    final tasksState = ref.watch(provider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('任务'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.push('/create-task').then((_) {
            ref.invalidate(myTasksProvider);
            ref.invalidate(receivedTasksProvider);
          }),
          child: const Icon(CupertinoIcons.add_circled),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            CupertinoSlidingSegmentedControl<int>(
              groupValue: segment,
              children: const {0: Text('我发布的'), 1: Text('发给我的')},
              onValueChanged: (v) => setState(() => segment = v ?? 0),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: tasksState.when(
                data: (tasks) {
                  if (tasks.isEmpty) return const Center(child: Text('还没有任务，去创建第一个吧。'));
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _TaskCard(task: tasks[i]),
                  );
                },
                loading: () => const Center(child: CupertinoActivityIndicator()),
                error: (e, _) => Center(child: Text('加载失败：$e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});
  final TaskItem task;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/task/${task.id}'),
      child: GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(task.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('奖励 ${task.rewardAmount} ${task.currency}'),
          Text('状态：${task.status.label}'),
          if (task.dueAt != null) Text('截止：${task.dueAt}'),
        ]),
      ),
    );
  }
}
