import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meowdabattery/theme/app_theme.dart';
import 'package:meowdabattery/providers/app_provider.dart';
import 'package:meowdabattery/models/task_status.dart';
import 'package:meowdabattery/widgets/task_card.dart';
import 'package:meowdabattery/screens/leader_dashboard.dart';
import 'package:meowdabattery/screens/user_select_screen.dart';
import 'package:meowdabattery/widgets/glass_container.dart';
import 'package:meowdabattery/widgets/sketch_background.dart';

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
        final admin = appProvider.adminName;
        final deadlineStatus = appProvider.deadlineStatus;
        final reminderLevel = appProvider.reminderLevel;

        return Scaffold(
          body: SketchBackground(
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, $userName',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
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
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.ink.withValues(
                                      alpha: 0.45,
                                    ),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.workspace_premium_rounded,
                                      color: Color(0xFF1a1a1a),
                                      size: 15,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Admin',
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
                              elevation: 0,
                              offset: const Offset(0, 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: AppColors.ink.withValues(alpha: 0.45),
                                  width: 1.4,
                                ),
                              ),
                              onSelected: (value) async {
                                try {
                                  if (value == 'dashboard' && isLeader) {
                                    _openAdminDashboard(context);
                                  } else if (value == 'logout') {
                                    await _logout(context, appProvider);
                                  }
                                } catch (error) {
                                  if (!context.mounted) return;
                                  _showErrorSnackBar(
                                    context,
                                    'Could not complete that action. Please try again.',
                                  );
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                    if (isLeader)
                                      const PopupMenuItem<String>(
                                        value: 'dashboard',
                                        child: _MenuOption(
                                          icon: Icons.dashboard_rounded,
                                          title: 'Admin Dashboard',
                                          subtitle: 'Approvals and controls',
                                          color: AppColors.accentPurple,
                                        ),
                                      ),
                                    const PopupMenuItem<String>(
                                      enabled: false,
                                      height: 6,
                                      child: SizedBox.shrink(),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'logout',
                                      child: _MenuOption(
                                        icon: Icons.logout_rounded,
                                        title: 'Logout',
                                        subtitle: 'Return to password screen',
                                        color: AppColors.accentRed,
                                      ),
                                    ),
                                  ],
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.bgCard,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.ink.withValues(
                                      alpha: 0.55,
                                    ),
                                  ),
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
                    child: GlassContainer(
                      padding: const EdgeInsets.all(16),
                      color: reminderLevel >= 3
                          ? AppColors.accentRed.withValues(alpha: 0.1)
                          : AppColors.bgCard,
                      border: Border.all(
                        color: reminderLevel >= 3
                            ? AppColors.accentRed.withValues(alpha: 0.3)
                            : AppColors.ink.withValues(alpha: 0.55),
                        width: 1.5,
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
                            'Admin: $admin | Outside 2: $leader',
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
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.accentGreen.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.celebration_rounded,
                                color: AppColors.accentGreen,
                                size: 44,
                              ),
                            ),
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
                              onAction:
                                  status == TaskStatus.none ||
                                      status == TaskStatus.rejected
                                  ? () => _submitTask(
                                      context,
                                      appProvider,
                                      task,
                                      isResubmission:
                                          status == TaskStatus.rejected,
                                    )
                                  : null,
                              actionLabel: status == TaskStatus.rejected
                                  ? 'Resubmit for approval'
                                  : 'Submit for approval',
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
            if (currentStatus == TaskStatus.none ||
                currentStatus == TaskStatus.rejected)
              ElevatedButton(
                onPressed: () async {
                  final isResubmission = currentStatus == TaskStatus.rejected;
                  await _submitTask(
                    context,
                    provider,
                    task,
                    isResubmission: isResubmission,
                    showSnackBar: false,
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isResubmission
                            ? 'Task resubmitted for approval!'
                            : 'Task submitted for approval!',
                      ),
                      backgroundColor: AppColors.accentGreen,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle),
                    const SizedBox(width: 8),
                    Text(
                      currentStatus == TaskStatus.rejected
                          ? 'Resubmit for approval'
                          : 'Mark as Complete',
                    ),
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

  Future<void> _submitTask(
    BuildContext context,
    AppProvider provider,
    String task, {
    bool isResubmission = false,
    bool showSnackBar = true,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await provider.submitTaskForApproval(task);
      if (!context.mounted || !showSnackBar) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isResubmission
                ? 'Task resubmitted for approval!'
                : 'Task submitted for approval!',
          ),
          backgroundColor: AppColors.accentGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      _showErrorSnackBar(context, 'Could not submit this task.');
    }
  }

  void _openAdminDashboard(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LeaderDashboard(),
        transitionsBuilder: (context, anim, secondaryAnimation, child) =>
            SlideTransition(
              position: Tween(begin: const Offset(1, 0), end: Offset.zero)
                  .animate(
                    CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                  ),
              child: child,
            ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Future<void> _logout(BuildContext context, AppProvider appProvider) async {
    await appProvider.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const UserSelectScreen(),
        transitionsBuilder: (context, anim, secondaryAnimation, child) =>
            FadeTransition(
              opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
              child: child,
            ),
        transitionDuration: const Duration(milliseconds: 280),
      ),
      (_) => false,
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.accentRed,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _MenuOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.28)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
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
