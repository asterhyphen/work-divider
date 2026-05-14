import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meowdabattery/theme/app_theme.dart';
import 'package:meowdabattery/data/schedule_data.dart';
import 'package:meowdabattery/providers/app_provider.dart';
import 'package:meowdabattery/widgets/user_card.dart';
import 'package:meowdabattery/widgets/glass_container.dart';
import 'package:meowdabattery/widgets/sketch_background.dart';

/// User identity selection with a small hardcoded password gate.
class UserSelectScreen extends StatefulWidget {
  const UserSelectScreen({super.key});

  @override
  State<UserSelectScreen> createState() => _UserSelectScreenState();
}

class _UserSelectScreenState extends State<UserSelectScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _introController;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final introCurve = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutBack,
    );

    return Scaffold(
      body: SketchBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.86,
                      end: 1,
                    ).animate(introCurve),
                    child: FadeTransition(
                      opacity: _introController,
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
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Pick your name, unlock your tasks.',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Who are you?',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enter your password after selecting your name',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
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
                        onTap: () => _showPasswordPrompt(context, name),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Text(
                      'Week ${ScheduleData.getCurrentWeekNumber()} of 7 | Admin: ${ScheduleData.adminUser}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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

  Future<void> _showPasswordPrompt(BuildContext context, String name) async {
    final passwordController = TextEditingController();
    var obscurePassword = true;
    var isLoading = false;
    String? errorText;
    final provider = context.read<AppProvider>();

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Password',
      barrierColor: AppColors.ink.withValues(alpha: 0.24),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            Future<void> submit() async {
              if (isLoading) return;
              setDialogState(() {
                isLoading = true;
                errorText = null;
              });

              try {
                await Future<void>.delayed(const Duration(milliseconds: 180));
                if (!dialogContext.mounted) return;
                if (!ScheduleData.isPasswordValid(
                  name,
                  passwordController.text,
                )) {
                  setDialogState(() {
                    isLoading = false;
                    errorText = 'Wrong password for $name';
                  });
                  return;
                }

                await provider.selectUser(name);
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
              } catch (error) {
                if (!dialogContext.mounted) return;
                setDialogState(() {
                  isLoading = false;
                  errorText = 'Could not log in. Try again.';
                });
              }
            }

            return AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.viewInsetsOf(dialogContext).bottom + 24,
              ),
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Material(
                    color: Colors.transparent,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(20),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.accentPurple.withValues(alpha: 0.72),
                          width: 1.6,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.accentPurple.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.accentPurple.withValues(
                                        alpha: 0.34,
                                      ),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.lock_rounded,
                                    color: AppColors.accentPurple,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const Text(
                                        'Password required',
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            TextField(
                              controller: passwordController,
                              obscureText: obscurePassword,
                              autofocus: true,
                              onSubmitted: (_) => submit(),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                errorText: errorText,
                                filled: true,
                                fillColor: AppColors.bgCardLight.withValues(
                                  alpha: 0.45,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () => setDialogState(() {
                                    obscurePassword = !obscurePassword;
                                  }),
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.accentPurple,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () =>
                                              Navigator.of(dialogContext).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : submit,
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      child: isLoading
                                          ? const SizedBox(
                                              key: ValueKey('loading'),
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              'Unlock',
                                              key: ValueKey('unlock'),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );

    passwordController.dispose();
  }
}
