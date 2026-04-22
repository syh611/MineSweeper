import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/task_repository.dart';

class CreateTaskPage extends ConsumerStatefulWidget {
  const CreateTaskPage({super.key});

  @override
  ConsumerState<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends ConsumerState<CreateTaskPage> {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final rewardCtrl = TextEditingController(text: '1');

  Future<void> submit() async {
    final amount = int.tryParse(rewardCtrl.text) ?? 0;
    if (titleCtrl.text.trim().isEmpty || amount < 1) return;
    await ref.read(taskRepositoryProvider).createTask(
          title: titleCtrl.text.trim(),
          description: descCtrl.text.trim(),
          rewardAmount: amount,
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('创建任务')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('奖励币种将根据接收者性别自动决定。'),
            const SizedBox(height: 12),
            CupertinoTextField(controller: titleCtrl, placeholder: '任务标题'),
            const SizedBox(height: 10),
            CupertinoTextField(controller: descCtrl, placeholder: '任务描述', maxLines: 4),
            const SizedBox(height: 10),
            CupertinoTextField(controller: rewardCtrl, placeholder: '奖励数量（最小 1）', keyboardType: TextInputType.number),
            const SizedBox(height: 18),
            CupertinoButton.filled(onPressed: submit, child: const Text('发布任务')),
          ],
        ),
      ),
    );
  }
}
