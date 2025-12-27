import 'package:flutter/material.dart';
import 'package:nearvendorapp/utils/app_strings.dart';
import 'package:nearvendorapp/views/widgets/general_input_screen.dart';

class VerificationCodeScreen extends StatelessWidget {
  const VerificationCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GeneralPinScreen(
      title: AppStrings.enterCodeTitle,
      subtitle: AppStrings.enterCodeSubtitle,
      email: '',
      buttonText: AppStrings.verifyButton,
      onPinSubmitted: (code, email, cubit) async {},
    );
  }
}
