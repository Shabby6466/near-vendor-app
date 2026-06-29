import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/enums/report_target_type.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/ui/app_alerts.dart';
import 'package:nearvendorapp/views/screens/auth/view/login_screen.dart';
import 'package:nearvendorapp/views/widgets/app_animate_list.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';
import 'package:nearvendorapp/views/widgets/safety_report/cubit/safety_report_cubit.dart';

class SafetyReportBottomSheet extends StatelessWidget {
  final String targetId;
  final ReportTargetType targetType;
  final String targetName;

  const SafetyReportBottomSheet({
    super.key,
    required this.targetId,
    required this.targetType,
    required this.targetName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SafetyReportCubit>(
      create: (context) =>
          SafetyReportCubit(targetId: targetId, targetType: targetType),
      child: BlocConsumer<SafetyReportCubit, SafetyReportState>(
        listener: (context, state) {
          if (state is SafetyReportSuccess) {
            AppNavigator.pop(context);
            AppAlerts.showSuccess(context, 'Report submitted for review.');
          } else if (state is SafetyReportFailure) {
            AppAlerts.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final cubit = context.read<SafetyReportCubit>();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: AppAnimateList.stagger([
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Text(
                'Report $targetName',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Help us maintain a safe community. Why are you reporting this?',
                style: TextStyle(fontSize: 13, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              IgnorePointer(
                ignoring: state is SafetyReportLoading,
                child: RadioGroup<String>(
                  groupValue: state.selectedReason,
                  onChanged: (val) => cubit.selectReason(val),
                  child: Column(
                    children: cubit.reasons
                        .map(
                          (reason) => RadioListTile<String>(
                            title: Text(
                              reason,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            value: reason,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            activeColor: Colors.red.shade700,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              if (state.selectedReason == 'Other') ...[
                const SizedBox(height: 8),
                TextField(
                  controller: cubit.detailsController,
                  decoration: InputDecoration(
                    hintText: 'Describe the issue...',
                    hintStyle: const TextStyle(fontSize: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: 2,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed:
                    state.selectedReason == null || state is SafetyReportLoading
                    ? null
                    : () {
                        // Check login status first
                        if (!AppData().isLoggedIn) {
                          AppNavigator.pop(context); // Close sheet
                          AppBottomSheet.showConfirmationBottomSheet(
                            context: context,
                            title: 'Sign In Required',
                            message: 'You need to sign in to submit a report.',
                            confirmButtonText: 'Sign In',
                            onConfirm: () {
                              AppNavigator.push(context, const LoginScreen());
                            },
                          );
                          return;
                        }
                        cubit.submitReport();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.red.shade100,
                  disabledForegroundColor: Colors.red.shade300,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: state is SafetyReportLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: LoadingAnimation(size: 20, color: Colors.white),
                      )
                    : const Text(
                        'Submit Report',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: state is SafetyReportLoading
                    ? null
                    : () => AppNavigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ]),
          );
        },
      ),
    );
  }
}
