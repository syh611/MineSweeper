import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../data/task_repository.dart';

class SubmitProofPage extends ConsumerStatefulWidget {
  const SubmitProofPage({super.key, required this.taskId});
  final String taskId;

  @override
  ConsumerState<SubmitProofPage> createState() => _SubmitProofPageState();
}

class _SubmitProofPageState extends ConsumerState<SubmitProofPage> {
  final textCtrl = TextEditingController();
  File? image;
  bool loading = false;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    setState(() => image = File(picked.path));
  }

  Future<void> submit() async {
    setState(() => loading = true);
    try {
      await ref.read(taskRepositoryProvider).submitProof(taskId: widget.taskId, text: textCtrl.text, image: image);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      showCupertinoDialog(context: context, builder: (_) => CupertinoAlertDialog(content: Text('$e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('提交完成证明')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CupertinoTextField(controller: textCtrl, placeholder: '一句话说明（可选）', maxLines: 3),
            const SizedBox(height: 12),
            CupertinoButton(onPressed: pickImage, child: Text(image == null ? '上传照片（可选）' : '已选择照片，重新上传')),
            const SizedBox(height: 24),
            CupertinoButton.filled(onPressed: loading ? null : submit, child: Text(loading ? '提交中...' : '提交完成')),
            const SizedBox(height: 8),
            const Text('规则：照片和文字至少选一项。', style: TextStyle(color: CupertinoColors.systemGrey)),
          ],
        ),
      ),
    );
  }
}
