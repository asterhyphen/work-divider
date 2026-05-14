import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:meowdabattery/theme/app_theme.dart';
import 'package:meowdabattery/models/task_status.dart';
import 'package:meowdabattery/data/schedule_data.dart';
import 'package:meowdabattery/theme/app_icons.dart';
import 'package:meowdabattery/widgets/glass_container.dart';

/// Task card with status, actions, animation, and sketch-style surfaces.
class TaskCard extends StatefulWidget {
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

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motionController;
  late final Animation<double> _floatAnimation;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -1.8, end: 1.8).animate(
      CurvedAnimation(parent: _motionController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _motionController, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.10, end: 0.26).animate(
      CurvedAnimation(parent: _motionController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _motionController.dispose();
    super.dispose();
  }

  Color get _statusColor => switch (widget.status) {
    TaskStatus.none =>
      widget.isOverdue ? AppColors.accentRed : AppColors.textMuted,
    TaskStatus.pendingApproval => AppColors.accentOrange,
    TaskStatus.approved => AppColors.accentGreen,
    TaskStatus.rejected => AppColors.accentRed,
  };

  String get _statusText => switch (widget.status) {
    TaskStatus.none => widget.isOverdue ? 'OVERDUE' : 'Not Started',
    TaskStatus.pendingApproval => 'Awaiting Approval',
    TaskStatus.approved => 'Completed',
    TaskStatus.rejected => 'Rejected - Redo',
  };

  IconData get _statusIcon => switch (widget.status) {
    TaskStatus.none =>
      widget.isOverdue ? Icons.warning_rounded : Icons.circle_outlined,
    TaskStatus.pendingApproval => Icons.hourglass_top_rounded,
    TaskStatus.approved => Icons.check_circle_rounded,
    TaskStatus.rejected => Icons.cancel_rounded,
  };

  String get _displayName => widget.taskName ?? widget.task ?? 'Task';

  IconData get _taskIcon => AppIcons.task(_displayName);

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.status == TaskStatus.approved
        ? AppColors.accentGreen.withValues(alpha: 0.65)
        : widget.isOverdue
        ? AppColors.accentRed.withValues(alpha: 0.65)
        : AppColors.ink.withValues(alpha: 0.70);

    return AnimatedBuilder(
      animation: _motionController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onStatusChange,
        child: GlassContainer(
          duration: const Duration(milliseconds: 400),
          margin: const EdgeInsets.only(bottom: 12),
          color: AppColors.bgCard,
          blur: 15,
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.12),
              blurRadius: 12,
              spreadRadius: 0.2,
              offset: const Offset(4, 5),
            ),
          ],
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _motionController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.accentPurple.withValues(
                              alpha: 0.10,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.accentPurple.withValues(
                                alpha: 0.45 + _glowAnimation.value * 0.14,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentPurple.withValues(
                                  alpha: _glowAnimation.value,
                                ),
                                blurRadius: 14,
                                spreadRadius: -6,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            _taskIcon,
                            color: AppColors.accentPurpleLight,
                            size: 23,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 14),
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
                        if (widget.showUser && widget.assignedTo != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.assignedTo!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _StatusBadge(
                    color: _statusColor,
                    icon: _statusIcon,
                    text: _statusText,
                    pulse: _pulseAnimation.value,
                  ),
                ],
              ),
              if (widget.status == TaskStatus.approved) ...[
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
              if (widget.onAction != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: widget.onAction,
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
                          widget.actionLabel ?? 'I finished my work',
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
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final double pulse;

  const _StatusBadge({
    required this.color,
    required this.icon,
    required this.text,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.95 + (pulse - 0.98) * 0.8,
      child: CustomPaint(
        painter: _SketchBadgePainter(color: color.withValues(alpha: 0.32)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          constraints: const BoxConstraints(maxWidth: 132, minHeight: 32),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
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
        ),
      ),
    );
  }
}

class _SketchBadgePainter extends CustomPainter {
  final Color color;

  const _SketchBadgePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final wobble = 2.3;
    final random = math.Random(size.width.round() + size.height.round());
    final left = 1.2;
    final top = 1.2;
    final right = size.width - 1.2;
    final bottom = size.height - 1.2;
    final radius = 9.0;

    Offset jitter(double x, double y) => Offset(
      x + (random.nextDouble() - 0.5) * wobble,
      y + (random.nextDouble() - 0.5) * wobble,
    );

    path.moveTo(left + radius, top + (random.nextDouble() - 0.5) * wobble);
    path.lineTo(jitter(right - radius, top).dx, jitter(right - radius, top).dy);
    path.quadraticBezierTo(right, top, right, top + radius);
    path.lineTo(
      jitter(right, bottom - radius).dx,
      jitter(right, bottom - radius).dy,
    );
    path.quadraticBezierTo(right, bottom, right - radius, bottom);
    path.lineTo(
      jitter(left + radius, bottom).dx,
      jitter(left + radius, bottom).dy,
    );
    path.quadraticBezierTo(left, bottom, left, bottom - radius);
    path.lineTo(jitter(left, top + radius).dx, jitter(left, top + radius).dy);
    path.quadraticBezierTo(left, top, left + radius, top);
    path.close();

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SketchBadgePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
