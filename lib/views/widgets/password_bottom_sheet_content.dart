import 'package:flutter/material.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/utils/helper_functions.dart';
import 'package:pinput/pinput.dart';

class PasswordBottomSheetContent extends StatefulWidget {
  final String title;
  final String message;
  final String? correctPin;
  final bool isHashedPin;

  const PasswordBottomSheetContent({
    super.key,
    required this.title,
    required this.message,
    this.correctPin,
    this.isHashedPin = false,
  });

  @override
  State<PasswordBottomSheetContent> createState() =>
      _PasswordBottomSheetContentState();
}

class _PasswordBottomSheetContentState
    extends State<PasswordBottomSheetContent> {
  final TextEditingController _pinController = TextEditingController();


  @override
  void initState() {
    super.initState();
  }


  String? _validatePin(String? pin) {
    if (widget.correctPin == null) return null;
    
    bool isValid;
    if (widget.isHashedPin) {
      isValid = verifyPassword(pin!, widget.correctPin!);
    } else {
      isValid = pin == widget.correctPin;
    }
    
    if (!isValid) {
      _pinController.clear();
      return 'Incorrect passcode. Please try again.';
    }
    return null;
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final basePinTheme = PinTheme(
      width: 24,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      textStyle: const TextStyle(color: Colors.transparent),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.message),
                const SizedBox(height: 16),

                Pinput(
                  controller: _pinController,
                  length: 6,
                  showCursor: false,
                  obscureText: true,
                  autofocus: true,
                  hapticFeedbackType: HapticFeedbackType.mediumImpact,
                  validator: widget.correctPin != null ? _validatePin : null,
                  errorBuilder: (errorText, pin) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          errorText ?? '',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                  defaultPinTheme: basePinTheme,
                  focusedPinTheme: basePinTheme.copyWith(
                    decoration: basePinTheme.decoration?.copyWith(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  submittedPinTheme: basePinTheme.copyWith(
                    decoration: basePinTheme.decoration?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  errorPinTheme: basePinTheme.copyWith(
                    decoration: basePinTheme.decoration?.copyWith(
                      color: Colors.red.withValues(alpha: 0.3),
                      border: Border.all(color: Colors.red),
                    ),
                  ),
                  onCompleted: (value) {
                    if (widget.correctPin != null) {
                      if (_validatePin(value) == null) {
                        AppNavigator.pop(context, true);
                      } else {
                        AppNavigator.pop(context, false);
                      }
                    } else {
                      AppNavigator.pop(context, value);
                    }
                  },
                ),
                SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
