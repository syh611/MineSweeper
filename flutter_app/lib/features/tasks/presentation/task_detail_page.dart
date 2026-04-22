import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/task_repository.dart';
import '../domain/task_models.dart';

final taskDetailProvider = FutureProvider.family<TaskItem, String>((ref, id) async {
  final data = await ref.watch(supabaseClientProvider).from('tasks').select().eq('id', id).single();
  return TaskItem.fromJson(data);
});

class TaskDetailPage extends ConsumerWidget {
  const TaskDetailPage({super.key, required this.taskId});
  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('任务详情')),
      child: SafeArea(
        child: ref.watch(taskDetailProvider(taskId)).when(
              data: (task) => _TaskContent(task: task),
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (e, _) => Center(child: Text('$e')),
            ),
      ),
    );
  }
}

class _TaskContent extends ConsumerWidget {
  const _TaskContent({required this.task});
  final TaskItem task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(supabaseClientProvider).auth.currentUser!.id;
    final isReceiver = uid == task.receiverId;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(task.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(task.description),
        const SizedBox(height: 8),
        Text('奖励：${task.rewardAmount}${task.currency}'),
        Text('状态：${task.status.label}'),
        const SizedBox(height: 16),
        if (task.status == TaskStatus.pendingAcceptance && isReceiver)
          Row(
            children: [
              Expanded(child: CupertinoButton.filled(onPressed: () => ref.read(taskRepositoryProvider).updateStatus(task.id, TaskStatus.accepted), child: const Text('接受'))),
              const SizedBox(width: 8),
              Expanded(child: CupertinoButton(onPressed: () => ref.read(taskRepositoryProvider).updateStatus(task.id, TaskStatus.rejected), child: const Text('拒绝'))),
            ],
          ),
        if ((task.status == TaskStatus.accepted || task.status == TaskStatus.completionRejected) && isReceiver)
          CupertinoButton.filled(onPressed: () => context.push('/submit-proof/${task.id}'), child: const Text('提交完成证明')),
        if (task.status == TaskStatus.completedPendingConfirm && !isReceiver)
          Column(
            children: [
              CupertinoButton.filled(onPressed: () => ref.read(taskRepositoryProvider).confirmAndReward(task), child: const Text('确认完成并发放奖励')),
              CupertinoButton(onPressed: () => ref.read(taskRepositoryProvider).updateStatus(task.id, TaskStatus.completionRejected), child: const Text('驳回证明')),
            ],
          ),
      ],
    );
  }
}
