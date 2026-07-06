import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/services/auth_services.dart';
import 'package:nearvendorapp/views/screens/profile_screen/view/delete_account_screen/cubit/delete_account_state.dart';

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  DeleteAccountCubit() : super(const DeleteAccountState());

  final _authServices = AuthServices();
  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();

  void toggleConfirmation(bool? value) {
    emit(state.copyWith(isConfirmed: value ?? false));
  }

  Future<void> deleteAccount() async {
    if (!formKey.currentState!.validate()) return;
    if (!state.isConfirmed) {
      emit(state.copyWith(
        status: DeleteAccountStatus.failure,
        errorMessage: 'Please confirm that you understand the terms.',
      ));
      return;
    }

    final password = passwordController.text.trim();
    if (password.isEmpty) {
      emit(state.copyWith(
        status: DeleteAccountStatus.failure,
        errorMessage: 'Please enter your password.',
      ));
      return;
    }

    emit(state.copyWith(status: DeleteAccountStatus.submitting));

    try {
      final response = await _authServices.deleteAccount(password);

      if (response.isSuccess) {
        emit(state.copyWith(status: DeleteAccountStatus.success));
      } else {
        emit(state.copyWith(
          status: DeleteAccountStatus.failure,
          errorMessage: response.message ?? 'Failed to delete account. Please try again.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: DeleteAccountStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    passwordController.dispose();
    return super.close();
  }
}
