import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meowdabattery/theme/app_theme.dart';
import 'package:meowdabattery/providers/app_provider.dart';
import 'package:meowdabattery/widgets/sketch_background.dart';
import 'package:meowdabattery/widgets/approval_list.dart';

/// Detailed approval screen for reviewing pending task completions.
class ApprovalScreen extends StatefulWidget {
  const ApprovalScreen({super.key});

  @override
  State<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final pendingApprovals = provider.pendingApprovals;

        return Scaffold(
          body: SketchBackground(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
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
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pending Approvals',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Review and approve submissions',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
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
                            color: AppColors.accentOrange.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.accentOrange.withValues(
                                alpha: 0.28,
                              ),
                            ),
                          ),
                          child: Text(
                            '${pendingApprovals.length}',
                            style: const TextStyle(
                              color: AppColors.accentOrange,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 20),
                        child: ApprovalList(approvals: pendingApprovals),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
