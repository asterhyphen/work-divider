import 'package:flutter/material.dart';
import 'package:meowdabattery/theme/app_theme.dart';
import 'package:meowdabattery/providers/app_provider.dart';
import 'package:meowdabattery/data/schedule_data.dart';

/// Beautiful task card with status, animations, and gradient accents.
class TaskCard extends StatelessWidget {
  final String taskName;
  final String assignedTo;
  final TaskStatus status;
  final bool showUser;
  final VoidCallback? onAction;
  final String? actionLabel;
  final bool isOverdue;

  const TaskCard({
    super.key,
    required this.taskName,
    required this.assignedTo,
    required this.status,
    this.showUser = false,
    this.onAction,
    this.actionLabel,
    this.isOverdue = false,
  });

  Color get _statusColor => switch (status) {
        TaskStatus.none => isOverdue ? AppColors.accentRed : AppColors.textMuted,
        TaskStatus.pendingApproval => AppColors.accentOrange,
        TaskStatus.approved => AppColors.accentGreen,
        TaskStatus.rejected => AppColors.accentRed,
      };

  String get _statusText => switch (status) {
        TaskStatus.none =>
          isOverdue ? 'OVERDUE' : 'Not Started',
        TaskStatus.pendingApproval => 'Awaiting Approval',
        TaskStatus.approved => 'Completed ✓',
        TaskStatus.rejected => 'Rejected — Redo',
      };

  IconData get _statusIcon => switch (status) {
        TaskStatus.none =>
          isOverdue ? Icons.warning_rounded : Icons.circle_outlined,
        TaskStatus.pendingApproval => Icons.hourglass_top_rounded,
        TaskStatus.approved => Icons.check_circle_rounded,
        TaskStatus.rejected => Icons.cancel_rounded,
      };

  String get _emoji => ScheduleData.taskIcons[taskName] ?? '📋';

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: status == TaskStatus.approved
              ? AppColors.accentGreen.withValues(alpha: 0.3)
              : isOverdue
                  ? AppColors.accentRed.withValues(alpha: 0.3)
                  : AppColors.divider.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          if (status == TaskStatus.approved)
            BoxShadow(
              color: AppColors.accentGreen.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Task emoji
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.bgCardLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(_emoji, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 14),
                // Task name and user
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        taskName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (showUser) ...[
                        const SizedBox(height: 2),
                        Text(
                          assignedTo,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Status badge
                _StatusBadge(
                  color: _statusColor,
                  icon: _statusIcon,
                  text: _statusText,
                ),
              ],
            ),
            // Completion message
            if (status == TaskStatus.approved) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  ScheduleData.completionMessages[taskName] ??
                      'Task completed! 🎉',
                  style: TextStyle(
                    color: AppColors.accentGreen.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            // Action button
            if (onAction != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    backgroundColor:
                        AppColors.accentPurple.withValues(alpha: 0.12),
                    foregroundColor: AppColors.accentPurpleLight,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    actionLabel ?? 'I finished my work ✓',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;

  const _StatusBadge({
    required this.color,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
