import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meowdabattery/theme/app_theme.dart';
import 'package:meowdabattery/providers/app_provider.dart';
import 'package:meowdabattery/widgets/glass_container.dart';

/// Reusable approval list and approval card used by ApprovalScreen and LeaderDashboard.
class ApprovalList extends StatelessWidget {
  final List<Map<String, String>> approvals;

  const ApprovalList({super.key, required this.approvals});

  @override
  Widget build(BuildContext context) {
    if (approvals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.verified_rounded,
                color: AppColors.accentGreen,
                size: 42,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'All caught up!',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No pending approvals at the moment.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      children: approvals.map((a) {
        final user = a['user']!;
        final task = a['task']!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ApprovalCard(user: user, task: task),
        );
      }).toList(),
    );
  }
}

class ApprovalCard extends StatelessWidget {
  final String user;
  final String task;

  const ApprovalCard({super.key, required this.user, required this.task});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);

    return GlassContainer(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: AppColors.accentOrange.withValues(alpha: 0.65),
        width: 1.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.accentOrange.withValues(alpha: 0.30),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.hourglass_bottom_rounded,
                    color: AppColors.accentOrange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.accentOrange.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Icon(
                    Icons.hourglass_top_rounded,
                    color: AppColors.accentOrange,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.divider.withValues(alpha: 0.3)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await provider.rejectTask(user, task);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('$task rejected for $user'),
                          backgroundColor: AppColors.accentRed,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.accentRed.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.accentRed.withValues(alpha: 0.35),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.close_rounded,
                            color: AppColors.accentRed,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Reject',
                            style: TextStyle(
                              color: AppColors.accentRed,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await provider.approveTask(user, task);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('$task approved for $user'),
                          backgroundColor: AppColors.accentGreen,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.accentGreen.withValues(alpha: 0.35),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.accentGreen,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Approve',
                            style: TextStyle(
                              color: AppColors.accentGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
