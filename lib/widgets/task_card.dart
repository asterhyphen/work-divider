import 'package:flutter/material.dart';
import 'package:meowdabattery/theme/app_theme.dart';
import 'package:meowdabattery/models/task_status.dart';
import 'package:meowdabattery/data/schedule_data.dart';
import 'package:meowdabattery/theme/app_icons.dart';
import 'package:meowdabattery/widgets/glass_container.dart';

/// Task card with status, actions, and sketch-style surfaces.
class TaskCard extends StatelessWidget {
  // Use either (task, status, onStatusChange) or (taskName, assignedTo, status, showUser, onAction)
  final String? task;
  final String? taskName;
  final String? assignedTo;
  final TaskStatus status;
  final VoidCallback? onStatusChange;
  final bool showUser;
  final VoidCallback? onAction;
  final String? actionLabel;
  final bool isOverdue;

  const TaskCard({
    super.key,
    this.task,
    this.taskName,
    this.assignedTo,
    required this.status,
    this.onStatusChange,
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
    TaskStatus.none => isOverdue ? 'OVERDUE' : 'Not Started',
    TaskStatus.pendingApproval => 'Awaiting Approval',
    TaskStatus.approved => 'Completed',
    TaskStatus.rejected => 'Rejected - Redo',
  };

  IconData get _statusIcon => switch (status) {
    TaskStatus.none =>
      isOverdue ? Icons.warning_rounded : Icons.circle_outlined,
    TaskStatus.pendingApproval => Icons.hourglass_top_rounded,
    TaskStatus.approved => Icons.check_circle_rounded,
    TaskStatus.rejected => Icons.cancel_rounded,
  };

  String get _displayName => taskName ?? task ?? 'Task';

  IconData get _taskIcon => AppIcons.task(_displayName);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onStatusChange,
      child: GlassContainer(
        duration: const Duration(milliseconds: 400),
        margin: const EdgeInsets.only(bottom: 12),
        color: AppColors.bgCard,
        blur: 15,
        border: Border.all(
          color: status == TaskStatus.approved
              ? AppColors.accentGreen.withValues(alpha: 0.65)
              : isOverdue
              ? AppColors.accentRed.withValues(alpha: 0.65)
              : AppColors.ink.withValues(alpha: 0.70),
          width: 1.5,
        ),
        boxShadow: [
          status == TaskStatus.approved
              ? BoxShadow(
                  color: AppColors.accentGreen.withValues(alpha: 0.16),
                  blurRadius: 0,
                  offset: const Offset(4, 5),
                )
              : BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.10),
                  blurRadius: 0,
                  offset: const Offset(4, 5),
                ),
        ],
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accentPurple.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.accentPurple.withValues(alpha: 0.45),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _taskIcon,
                    color: AppColors.accentPurpleLight,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 14),
                // Task name and user
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (showUser && assignedTo != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          assignedTo!,
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
            if (status == TaskStatus.approved) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.accentGreen.withValues(alpha: 0.28),
                  ),
                ),
                child: Text(
                  ScheduleData.completionMessages[_displayName] ??
                      'Task completed!',
                  style: TextStyle(
                    color: AppColors.accentGreen.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            if (onAction != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.accentPurple.withValues(
                      alpha: 0.12,
                    ),
                    foregroundColor: AppColors.accentPurpleLight,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.task_alt_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        actionLabel ?? 'I finished my work',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
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
      constraints: const BoxConstraints(maxWidth: 132, minHeight: 32),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
