enum Gender { male, female }

enum TaskStatus {
  pendingAcceptance,
  accepted,
  rejected,
  completedPendingConfirm,
  completedRewarded,
  completionRejected,
  expired,
  cancelled,
}

extension TaskStatusX on TaskStatus {
  String get value => switch (this) {
        TaskStatus.pendingAcceptance => 'pending_acceptance',
        TaskStatus.accepted => 'accepted',
        TaskStatus.rejected => 'rejected',
        TaskStatus.completedPendingConfirm => 'completed_pending_confirm',
        TaskStatus.completedRewarded => 'completed_rewarded',
        TaskStatus.completionRejected => 'completion_rejected',
        TaskStatus.expired => 'expired',
        TaskStatus.cancelled => 'cancelled',
      };

  String get label => switch (this) {
        TaskStatus.pendingAcceptance => '待接受',
        TaskStatus.accepted => '进行中',
        TaskStatus.rejected => '已拒绝',
        TaskStatus.completedPendingConfirm => '待确认',
        TaskStatus.completedRewarded => '已发放',
        TaskStatus.completionRejected => '驳回重提',
        TaskStatus.expired => '已过期',
        TaskStatus.cancelled => '已取消',
      };
}

class TaskItem {
  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardAmount,
    required this.currency,
    required this.status,
    required this.creatorId,
    required this.receiverId,
    this.dueAt,
  });

  final String id;
  final String title;
  final String description;
  final int rewardAmount;
  final String currency;
  final TaskStatus status;
  final String creatorId;
  final String receiverId;
  final DateTime? dueAt;

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      rewardAmount: json['reward_amount'] as int,
      currency: json['reward_currency'] as String,
      status: TaskStatus.values.firstWhere((e) => e.value == json['status']),
      creatorId: json['creator_id'] as String,
      receiverId: json['receiver_id'] as String,
      dueAt: json['due_at'] == null ? null : DateTime.parse(json['due_at'] as String),
    );
  }
}
