import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/api_request_models/auth_api_inputs.dart';
import 'package:nearvendorapp/models/data_models/user.dart';
import 'package:nearvendorapp/services/auth_services.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';

part 'verification_state.dart';

class VerificationCubit extends Cubit<VerificationState> {
  VerificationCubit({required this.email}) : super(VerificationInitial());

  final String email;
  final _authServices = AuthServices();

  // The PIN controller lives in the cubit, not the view
  final codeController = TextEditingController();

  void onCodeChanged(String code) {
    emit(VerificationCodeChanged(code));
  }

  Future<void> verifyOtp() async {
    final code = codeController.text.trim();
    if (code.length != 6) return;

    emit(VerificationLoading());
    try {
      final response = await _authServices.verifyOtp(
        VerifyOtpInput(email: email, otp: code),
      );

      if (response.status == 200 || response.status == 201) {
        if (response.user != null && response.token != null) {
          await CurrentUserStorage.storeUserData(response.user);
          await CurrentUserStorage.storeUserAuthToken(
            response.token!,
            response.refreshToken,
          );
        }
        emit(VerificationSuccess(user: response.user));
      } else if (response.status == 403) {
        emit(
          VerificationInvalidCode(
            response.message ??
                'The verification code you entered is incorrect.',
          ),
        );
      } else {
        emit(VerificationFailure(response.message ?? 'Verification failed'));
      }
    } catch (e) {
      emit(VerificationFailure(e.toString()));
    }
  }

  void resetCode() {
    codeController.clear();
    emit(VerificationInitial());
  }

  @override
  Future<void> close() {
    codeController.dispose();
    return super.close();
  }
}
