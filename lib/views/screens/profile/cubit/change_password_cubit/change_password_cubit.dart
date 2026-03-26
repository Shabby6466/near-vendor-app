import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nearvendorapp/models/api_inputs/auth_api_inputs.dart';
import 'package:nearvendorapp/services/auth_services.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';

part 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit() : super(ChangePasswordInitial());

  Future<void> handleChangePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    emit(ChangePasswordLoading());
    try {
      final user = CurrentUserStorage.getCurrentUser();
      if (user == null || user.email == null) {
        emit(const ChangePasswordFailure('User session not found. Please login again.'));
        return;
      }

      final response = await AuthServices().changePassword(
        ChangePasswordInput(
          email: user.email!,
          oldPassword: oldPassword,
          newPassword: newPassword,
        ),
      );

      if (response.status == 200 || response.status == 201) {
        emit(ChangePasswordSuccess(response.message ?? 'Password changed successfully'));
      } else {
        emit(ChangePasswordFailure(response.message ?? 'Failed to change password'));
      }
    } catch (e) {
      emit(ChangePasswordFailure(e.toString()));
    }
  }
}
