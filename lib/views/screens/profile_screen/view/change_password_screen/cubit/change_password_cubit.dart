import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/api_request_models/auth_api_inputs.dart';
import 'package:nearvendorapp/services/auth_services.dart';

part 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit() : super(ChangePasswordInitial());

  final formKey = GlobalKey<FormState>();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<void> handleChangePassword() async {
    if (!formKey.currentState!.validate()) return;

    emit(ChangePasswordLoading());
    try {
      final response = await AuthServices().changePassword(
        ChangePasswordInput(
          oldPassword: oldPasswordController.text.trim(),
          newPassword: newPasswordController.text.trim(),
        ),
      );

      if (response.isSuccess) {
        emit(
          ChangePasswordSuccess(
            response.message ?? 'Password changed successfully',
          ),
        );
      } else {
        emit(
          ChangePasswordFailure(
            response.message ?? 'Failed to change password',
          ),
        );
      }
    } catch (e) {
      emit(ChangePasswordFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    return super.close();
  }
}
