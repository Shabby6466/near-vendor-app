import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/services/auth_services.dart';

part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit() : super(ForgotPasswordInitial());

  final _authServices = AuthServices();

  final emailFormKey = GlobalKey<FormState>();
  final otpFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<void> sendOtp() async {
    if (!emailFormKey.currentState!.validate()) return;
    emit(ForgotPasswordLoading());
    try {
      final email = emailController.text.trim();
      final response = await _authServices.forgotPassword(email);

      if (response.isSuccess) {
        emit(ForgotPasswordOtpSent(email));
      } else {
        emit(ForgotPasswordError(response.message ?? 'Failed to send OTP'));
      }
    } catch (e) {
      emit(ForgotPasswordError(e.toString()));
    }
  }

  Future<void> verifyOtp() async {
    if (!otpFormKey.currentState!.validate()) return;
    emit(ForgotPasswordLoading());
    try {
      final email = emailController.text.trim();
      final otp = otpController.text.trim();
      final response = await _authServices.verifyResetOtp(email, otp);

      if (response.isSuccess && response.resetToken != null) {
        emit(ForgotPasswordOtpVerified(
          email: email,
          resetToken: response.resetToken!,
        ));
      } else {
        emit(ForgotPasswordError(response.message ?? 'Invalid OTP'));
      }
    } catch (e) {
      emit(ForgotPasswordError(e.toString()));
    }
  }

  Future<void> resetPassword() async {
    if (!passwordFormKey.currentState!.validate()) return;

    final currentState = state;
    if (currentState is! ForgotPasswordOtpVerified) {
      emit(const ForgotPasswordError('Invalid state for password reset'));
      return;
    }

    emit(ForgotPasswordLoading());
    try {
      final response = await _authServices.resetPassword(
        currentState.resetToken,
        newPasswordController.text,
      );

      if (response.isSuccess) {
        emit(ForgotPasswordSuccess());
      } else {
        emit(ForgotPasswordError(
            response.message ?? 'Failed to reset password'));
      }
    } catch (e) {
      emit(ForgotPasswordError(e.toString()));
    }
  }

  void backToEmail() {
    emit(ForgotPasswordInitial());
  }

  @override
  Future<void> close() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    return super.close();
  }
}
