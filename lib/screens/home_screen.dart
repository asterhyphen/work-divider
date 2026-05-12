import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meowdabattery/theme/app_theme.dart';
import 'package:meowdabattery/providers/app_provider.dart';
import 'package:meowdabattery/models/task_status.dart';
import 'package:meowdabattery/widgets/task_card.dart';
import 'package:meowdabattery/screens/leader_dashboard.dart';

/// Home screen - shows user's tasks and completion status.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        final userName = appProvider.currentUser ?? 'Unknown';
        final currentWeek = appProvider.currentWeekNumber;
        final tasks = appProvider.myTasks;
        final isLeader = appProvider.isLeader;
        final leader = appProvider.leaderName;
        final deadlineStatus = appProvider.deadlineStatus;
        final reminderLevel = appProvider.reminderLevel;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(gradient: AppGradients.bgSubtle),
            child: SafeArea(
              child: Column(
                children: [
                  // Header with user info and leader dashboard button
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // User greeting
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, $userName',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Week $currentWeek of 7',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        // Leader badge and menu
                        Row(
                          children: [
                            if (isLeader)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppGradients.gold,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Text(
                                      '👑 Leader',
                                      style: TextStyle(
                                        color: Color(0xFF1a1a1a),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(width: 12),
                            PopupMenuButton<String>(
                              color: AppColors.bgCard,
                              onSelected: (value) {
                                if (value == 'dashboard' && isLeader) {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) =>
                                          const LeaderDashboard(),
                                      transitionsBuilder:
                                          (_, anim, __, child) =>
                                              SlideTransition(
                                                position:
                                                    Tween(
                                                      begin: const Offset(1, 0),
                                                      end: Offset.zero,
                                                    ).animate(
                                                      CurvedAnimation(
                                                        parent: anim,
                                                        curve: Curves.easeOut,
                                                      ),
                                                    ),
                                                child: child,
                                              ),
                                      transitionDuration: const Duration(
                                        milliseconds: 300,
                                      ),
                                    ),
                                  );
                                } else if (value == 'logout') {
                                  appProvider.logout();
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                    if (isLeader)
                                      const PopupMenuItem<String>(
                                        value: 'dashboard',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.dashboard,
                                              color: AppColors.textPrimary,
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              'Leader Dashboard',
                                              style: TextStyle(
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const PopupMenuDivider(),
                                    const PopupMenuItem<String>(
                                      value: 'logout',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.logout,
                                            color: AppColors.accentRed,
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'Logout',
                                            style: TextStyle(
                                              color: AppColors.accentRed,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.bgCard,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.more_vert,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Deadline status card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: reminderLevel >= 3
                            ? AppColors.accentRed.withValues(alpha: 0.1)
                            : AppColors.bgCard,
                        border: Border.all(
                          color: reminderLevel >= 3
                              ? AppColors.accentRed.withValues(alpha: 0.3)
                              : AppColors.divider.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Deadline',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            deadlineStatus,
                            style: TextStyle(
                              color: reminderLevel >= 3
                                  ? AppColors.accentRed
                                  : AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Leader: $leader',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tasks list
                  if (tasks.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🎉', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 16),
                            const Text(
                              'No tasks assigned this week!',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Enjoy your break!',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          final status = appProvider.getTaskStatus(
                            userName,
                            task,
                          );

                          return SlideTransition(
                            position:
                                Tween(
                                  begin: const Offset(-1, 0),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: _animationController,
                                    curve: Interval(
                                      index * 0.15,
                                      index * 0.15 + 0.6,
                                      curve: Curves.easeOut,
                                    ),
                                  ),
                                ),
                            child: TaskCard(
                              task: task,
                              status: status,
                              onStatusChange: () =>
                                  _showStatusDialog(context, appProvider, task),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showStatusDialog(
    BuildContext context,
    AppProvider provider,
    String task,
  ) {
    final currentStatus = provider.getTaskStatus(provider.currentUser!, task);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            if (currentStatus == TaskStatus.none)
              ElevatedButton(
                onPressed: () {
                  provider.submitTaskForApproval(task);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Task submitted for approval!'),
                      backgroundColor: AppColors.accentGreen,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle),
                    SizedBox(width: 8),
                    Text('Mark as Complete'),
                  ],
                ),
              )
            else if (currentStatus == TaskStatus.pendingApproval)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accentOrange.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.schedule, color: AppColors.accentOrange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Awaiting leader approval...',
                        style: TextStyle(
                          color: AppColors.accentOrange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (currentStatus == TaskStatus.approved)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accentGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.accentGreen),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Approved! Great work!',
                        style: TextStyle(
                          color: AppColors.accentGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accentRed.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cancel, color: AppColors.accentRed),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Rejected. Please try again.',
                        style: TextStyle(
                          color: AppColors.accentRed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
