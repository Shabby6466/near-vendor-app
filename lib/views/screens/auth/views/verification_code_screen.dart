import 'package:flutter/material.dart';
import 'package:nearvendorapp/models/api_inputs/auth_api_inputs.dart';
import 'package:nearvendorapp/services/auth_services.dart';
import 'package:nearvendorapp/utils/app_strings.dart';
import 'package:nearvendorapp/views/screens/home/view/main_screen.dart' show MainScreen;
import 'package:nearvendorapp/views/widgets/general_input_screen.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';

class VerificationCodeScreen extends StatelessWidget {
  const VerificationCodeScreen({super.key, required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return GeneralPinScreen(
      title: AppStrings.enterCodeTitle,
      subtitle: AppStrings.enterCodeSubtitle,
      email: email,
      buttonText: AppStrings.verifyButton,
      onPinSubmitted: (code, email, cubit) async {
        cubit.submitCode(code);
        final response = await AuthServices().verifyOtp(
          VerifyOtpInput(email: email, otp: code),
        );
        if (response.status == 200 || response.status == 201) {
          if (response.user != null && response.token != null) {
            await CurrentUserStorage.storeUserData(response.user);
            await CurrentUserStorage.storeUserAuthToken(response.token!, null);
            if (context.mounted) {
              context.read<SessionCubit>().setAuthenticated(response.user?.fullName ?? 'User');
            }
          }
          cubit.onSuccess();
        } else {
          cubit.onFailure(response.message ?? 'Verification failed');
        }
      },
      onSuccessNavigation: (context, email, code) => const MainScreen(),
    );
  }
}
