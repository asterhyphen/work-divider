import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meowdabattery/theme/app_theme.dart';
import 'package:meowdabattery/providers/app_provider.dart';
import 'package:meowdabattery/models/task_status.dart';
import 'package:meowdabattery/widgets/task_card.dart';
import 'package:meowdabattery/widgets/progress_ring.dart';
import 'package:meowdabattery/widgets/confetti_overlay.dart';
import 'package:meowdabattery/widgets/glass_container.dart';
import 'package:meowdabattery/widgets/sketch_background.dart';

class LeaderDashboard extends StatefulWidget {
  const LeaderDashboard({super.key});

  @override
  State<LeaderDashboard> createState() => _LeaderDashboardState();
}

class _LeaderDashboardState extends State<LeaderDashboard> {
  bool _showConfetti = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final assignments = provider.fullAssignments;
        final pending = provider.pendingApprovals;
        final completion = provider.weekCompletionPercent;

        if (provider.allTasksComplete && !_showConfetti) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _showConfetti = true);
          });
        }

        return ConfettiOverlay(
          isPlaying: _showConfetti,
          child: Scaffold(
            body: SketchBackground(
              child: SafeArea(
                child: Column(
                  children: [
                    _buildAppBar(context),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            _buildStatsCard(completion, assignments, provider),
                            const SizedBox(height: 16),
                            _buildAdminControls(context, provider, pending),
                            const SizedBox(height: 24),
                            if (pending.isNotEmpty) ...[
                              _sectionHeader(
                                'Pending Approvals',
                                '${pending.length}',
                              ),
                              const SizedBox(height: 12),
                              ...pending.map(
                                (p) => _buildApprovalCard(
                                  context,
                                  provider,
                                  p['user']!,
                                  p['task']!,
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                            _sectionHeader(
                              'All Members',
                              '${assignments.length}',
                            ),
                            const SizedBox(height: 12),
                            ...assignments.entries.map((e) {
                              final status = provider.getTaskStatus(
                                e.value,
                                e.key,
                              );
                              return TaskCard(
                                taskName: e.key,
                                assignedTo: e.value,
                                status: status,
                                showUser: true,
                                isOverdue:
                                    provider.isOverdue &&
                                    status != TaskStatus.approved,
                              );
                            }),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.ink.withValues(alpha: 0.55),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Icon(
            Icons.workspace_premium_rounded,
            color: AppColors.accentGold,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text(
            'Admin Dashboard',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
    double completion,
    Map<String, String> assignments,
    AppProvider provider,
  ) {
    int approved = 0, pendingA = 0, notStarted = 0;
    for (final e in assignments.entries) {
      final s = provider.getTaskStatus(e.value, e.key);
      if (s == TaskStatus.approved) {
        approved++;
      } else if (s == TaskStatus.pendingApproval) {
        pendingA++;
      } else {
        notStarted++;
      }
    }

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: AppColors.accentGold.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.accentGold.withValues(alpha: 0.72),
        width: 1.5,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Week Progress',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                _statRow(
                  Icons.check_circle_rounded,
                  AppColors.accentGreen,
                  'Completed',
                  '$approved',
                ),
                const SizedBox(height: 6),
                _statRow(
                  Icons.hourglass_top_rounded,
                  AppColors.accentOrange,
                  'Pending',
                  '$pendingA',
                ),
                const SizedBox(height: 6),
                _statRow(
                  Icons.radio_button_unchecked_rounded,
                  AppColors.textMuted,
                  'Not Started',
                  '$notStarted',
                ),
              ],
            ),
          ),
          ProgressRing(
            progress: completion,
            size: 90,
            strokeWidth: 7,
            gradientColors: const [
              AppColors.accentGold,
              AppColors.accentOrange,
            ],
            child: Text(
              '${(completion * 100).toInt()}%',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(IconData icon, Color color, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, String count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.accentPurple.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.accentPurple.withValues(alpha: 0.25),
            ),
          ),
          child: Text(
            count,
            style: const TextStyle(
              color: AppColors.accentPurpleLight,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminControls(
    BuildContext context,
    AppProvider provider,
    List<Map<String, String>> pending,
  ) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.accentPurple.withValues(alpha: 0.55),
        width: 1.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tune_rounded, color: AppColors.accentPurple, size: 20),
              SizedBox(width: 8),
              Text(
                'Admin Controls',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  'Approve All',
                  AppColors.accentGreen,
                  pending.isEmpty
                      ? null
                      : () => _runAdminAction(
                          context,
                          provider.approveAllPending,
                          success: 'Approved all pending tasks.',
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionButton(
                  'Reject All',
                  AppColors.accentRed,
                  pending.isEmpty
                      ? null
                      : () => _runAdminAction(
                          context,
                          provider.rejectAllPending,
                          success: 'Rejected all pending tasks.',
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: _actionButton(
              'Reset Week Tasks',
              AppColors.accentOrange,
              () async {
                final confirmed = await _confirmReset(context);
                if (!confirmed || !context.mounted) return;
                await _runAdminAction(
                  context,
                  provider.resetWeekTasks,
                  success: 'Week 1 task statuses reset.',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalCard(
    BuildContext context,
    AppProvider provider,
    String user,
    String task,
  ) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: AppColors.accentOrange.withValues(alpha: 0.65),
        width: 1.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.accentOrange.withValues(alpha: 0.30),
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  color: AppColors.accentOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      task,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  'Reject',
                  AppColors.accentRed,
                  () => _runAdminAction(
                    context,
                    () => provider.rejectTask(user, task),
                    success: '$task rejected for $user.',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionButton(
                  'Approve',
                  AppColors.accentGreen,
                  () => _runAdminAction(
                    context,
                    () => provider.approveTask(user, task),
                    success: '$task approved for $user.',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback? onTap) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: enabled ? 0.12 : 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withValues(alpha: enabled ? 0.35 : 0.14),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: enabled ? color : AppColors.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _runAdminAction(
    BuildContext context,
    Future<void> Function() action, {
    required String success,
  }) async {
    try {
      await action();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success),
          backgroundColor: AppColors.accentGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin action failed. Please try again.'),
          backgroundColor: AppColors.accentRed,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<bool> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text(
          'Reset Week 1?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'This clears every task status for the active week.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}
