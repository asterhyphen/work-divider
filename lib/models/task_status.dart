/// Task completion status enum.
enum TaskStatus {
  none, // Not started
  pendingApproval, // User submitted, awaiting leader approval
  approved, // Leader approved
  rejected, // Leader rejected
}

extension TaskStatusExt on TaskStatus {
  String get displayName => switch (this) {
    TaskStatus.none => 'Not Started',
    TaskStatus.pendingApproval => 'Pending Approval',
    TaskStatus.approved => 'Approved',
    TaskStatus.rejected => 'Rejected',
  };

  String get emoji => switch (this) {
    TaskStatus.none => '⭕',
    TaskStatus.pendingApproval => '⏳',
    TaskStatus.approved => '✅',
    TaskStatus.rejected => '❌',
  };
}
