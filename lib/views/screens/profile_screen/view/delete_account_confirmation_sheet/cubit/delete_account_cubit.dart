import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/services/auth_services.dart';

part 'delete_account_state.dart';

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  DeleteAccountCubit() : super(DeleteAccountInitial());

  final _authServices = AuthServices();
  final passwordController = TextEditingController();

  Future<void> deleteAccount() async {
    final password = passwordController.text.trim();

    if (password.isEmpty) {
      emit(const DeleteAccountFailure('Please enter your password.'));
      return;
    }

    emit(DeleteAccountLoading());

    try {
      final response = await _authServices.deleteAccount(password);

      if (response.isSuccess) {
        emit(DeleteAccountSuccess());
      } else {
        emit(
          DeleteAccountFailure(
            response.message ?? 'Failed to delete account. Please try again.',
          ),
        );
      }
    } catch (e) {
      emit(DeleteAccountFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    passwordController.dispose();
    return super.close();
  }
}
