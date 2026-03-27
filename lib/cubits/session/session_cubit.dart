import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/data_models/user.dart';
import 'package:nearvendorapp/services/auth_services.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';
import 'package:flutter/foundation.dart';

part 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  SessionCubit() : super(const SessionState());

  void initialize() async {
    final token = CurrentUserStorage.getUserAuthToken();
    final user = CurrentUserStorage.getCurrentUser();

    if (token != null) {
      if (user != null) {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            userName: user.fullName,
            isVendor: user.role?.toUpperCase() == 'VENDOR',
          ),
        );
      }

      try {
        final response = await AuthServices().getMe();
        if (response.user != null) {
          await CurrentUserStorage.storeUserData(response.user);
          emit(
            state.copyWith(
              status: AuthStatus.authenticated,
              user: response.user,
              userName: response.user?.fullName,
              isVendor: response.user?.role?.toUpperCase() == 'VENDOR',
            ),
          );
        }
      } catch (e) {
        debugPrint('Session refresh failed: $e');
      }
    } else {
      emit(state.copyWith(status: AuthStatus.guest, userName: 'Guest User'));
    }
  }

  void setAuthenticated(User? user) {
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      userName: user?.fullName,
      isVendor: user?.role?.toUpperCase() == 'VENDOR',
    ));
  }

  void setGuest() {
    emit(state.copyWith(status: AuthStatus.guest, userName: 'Guest User'));
  }

  Future<void> logout() async {
    await CurrentUserStorage.clearUserData();
    emit(state.copyWith(status: AuthStatus.guest, userName: 'Guest User'));
  }

  void setVendorStatus(bool isVendor) {
    emit(state.copyWith(isVendor: isVendor));
  }

  bool get isAuthenticated => state.status == AuthStatus.authenticated;
}
