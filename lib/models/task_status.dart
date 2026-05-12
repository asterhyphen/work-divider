import 'package:flutter/material.dart';

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

  IconData get icon => switch (this) {
    TaskStatus.none => Icons.radio_button_unchecked_rounded,
    TaskStatus.pendingApproval => Icons.hourglass_top_rounded,
    TaskStatus.approved => Icons.check_circle_rounded,
    TaskStatus.rejected => Icons.cancel_rounded,
  };
}
