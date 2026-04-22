import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../domain/task_models.dart';

final supabaseClientProvider = Provider<SupabaseClient>((_) => Supabase.instance.client);

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.watch(supabaseClientProvider));
});

class TaskRepository {
  TaskRepository(this.client);

  final SupabaseClient client;

  Future<List<TaskItem>> listTasks({required bool mine}) async {
    final uid = client.auth.currentUser!.id;
    final query = mine ? 'creator_id' : 'receiver_id';
    final data = await client.from('tasks').select().eq(query, uid).order('created_at', ascending: false);
    return (data as List).map((e) => TaskItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createTask({
    required String title,
    required String description,
    required int rewardAmount,
    DateTime? dueAt,
    String? category,
    String? note,
  }) async {
    final uid = client.auth.currentUser!.id;
    final partner = await client.from('partner_links').select('partner_id, partner_gender').eq('user_id', uid).single();
    final rewardCurrency = partner['partner_gender'] == 'female' ? '菲币' : '小币';

    await client.from('tasks').insert({
      'creator_id': uid,
      'receiver_id': partner['partner_id'],
      'title': title,
      'description': description,
      'reward_amount': rewardAmount,
      'reward_currency': rewardCurrency,
      'status': TaskStatus.pendingAcceptance.value,
      'due_at': dueAt?.toIso8601String(),
      'category': category,
      'note': note,
    });
  }

  Future<void> updateStatus(String taskId, TaskStatus status, {String? note}) async {
    final uid = client.auth.currentUser!.id;
    await client.from('tasks').update({'status': status.value}).eq('id', taskId);
    await client.from('task_status_logs').insert({'task_id': taskId, 'from_user': uid, 'to_status': status.value, 'note': note});
  }

  Future<void> submitProof({required String taskId, String? text, File? image}) async {
    if ((text == null || text.trim().isEmpty) && image == null) {
      throw Exception('请至少提交一句话说明或一张图片');
    }

    final uid = client.auth.currentUser!.id;
    String? imagePath;
    if (image != null) {
      final name = const Uuid().v4();
      imagePath = 'proofs/$uid/$taskId/$name.jpg';
      await client.storage.from('proofs').upload(imagePath, image);
    }

    await client.from('task_completion_proofs').insert({
      'task_id': taskId,
      'submitted_by': uid,
      'proof_text': text,
      'proof_image_path': imagePath,
    });

    await updateStatus(taskId, TaskStatus.completedPendingConfirm);
  }

  Future<void> confirmAndReward(TaskItem task) async {
    await client.rpc('confirm_task_and_reward', params: {'p_task_id': task.id});
  }
}
