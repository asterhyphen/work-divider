import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meowdabattery/theme/app_theme.dart';
import 'package:meowdabattery/data/schedule_data.dart';
import 'package:meowdabattery/providers/app_provider.dart';
import 'package:meowdabattery/widgets/user_card.dart';
import 'package:meowdabattery/screens/home_screen.dart';
import 'package:meowdabattery/widgets/sketch_background.dart';

/// "Who are you?" screen — user identity selection.
class UserSelectScreen extends StatelessWidget {
  const UserSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SketchBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Logo / app name
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.ink.withValues(alpha: 0.75),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.ink.withValues(alpha: 0.10),
                              blurRadius: 0,
                              offset: const Offset(4, 5),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.home_rounded,
                          color: AppColors.accentPurple,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'HouseCycle',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Keep the house clean, keep the peace.',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // "Who are you?"
                const Text(
                  'Who are you?',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Select your name to see your tasks',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                // User grid
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.3,
                        ),
                    itemCount: ScheduleData.allUsers.length,
                    itemBuilder: (context, index) {
                      final name = ScheduleData.allUsers[index];
                      return UserCard(
                        name: name,
                        index: index,
                        onTap: () => _selectUser(context, name),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Week indicator
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.divider.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'Week ${ScheduleData.getCurrentWeekNumber()} of 7',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectUser(BuildContext context, String name) {
    final provider = context.read<AppProvider>();
    provider.selectUser(name);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, anim, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
