import 'package:flutter/material.dart';
import 'package:nearvendorapp/services/safety_services.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/ui/app_alerts.dart';
import 'package:nearvendorapp/views/screens/auth/view/login_screen.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';

class SafetyReportDialog extends StatefulWidget {
  final String targetId;
  final String targetType; // USER, SHOP, ITEM
  final String targetName;

  const SafetyReportDialog({
    super.key,
    required this.targetId,
    required this.targetType,
    required this.targetName,
  });

  @override
  State<SafetyReportDialog> createState() => _SafetyReportDialogState();
}

class _SafetyReportDialogState extends State<SafetyReportDialog> {
  final List<String> _reasons = [
    'Inappropriate Content',
    'Spam or Misleading',
    'Harassment',
    'Offensive Imagery',
    'Illegal Goods',
    'Other',
  ];

  String? _selectedReason;
  final TextEditingController _detailsController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitReport() async {
    if (_selectedReason == null) return;

    if (!AppData().isLoggedIn) {
      AppNavigator.pop(context); // Close dialog
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

    setState(() => _isLoading = true);

    final result = await SafetyServices().reportContent(
      targetId: widget.targetId,
      targetType: widget.targetType,
      reason: _selectedReason!,
      additionalDetails: _detailsController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result.success == true) {
        AppNavigator.pop(context);
        AppAlerts.showSuccess(context, 'Report submitted for review.');
      } else {
        AppAlerts.showError(
          context,
          result.message ?? 'Failed to submit report',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Report ${widget.targetName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Help us maintain a safe community. Why are you reporting this?',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            RadioGroup<String>(
              groupValue: _selectedReason,
              onChanged: (val) => setState(() => _selectedReason = val),
              child: Column(
                children: _reasons
                    .map(
                      (reason) => RadioListTile<String>(
                        title: Text(
                          reason,
                          style: const TextStyle(fontSize: 14),
                        ),
                        value: reason,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                    .toList(),
              ),
            ),
            if (_selectedReason == 'Other')
              TextField(
                controller: _detailsController,
                decoration: const InputDecoration(
                  hintText: 'Describe the issue...',
                  hintStyle: TextStyle(fontSize: 13),
                ),
                maxLines: 2,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => AppNavigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedReason == null || _isLoading
              ? null
              : _submitReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: LoadingAnimation(size: 20, color: Colors.white),
                )
              : const Text('Submit Report'),
        ),
      ],
    );
  }
}
