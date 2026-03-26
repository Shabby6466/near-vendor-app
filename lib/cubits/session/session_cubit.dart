import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/data_models/user.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';

part 'session_state.dart';


class SessionCubit extends Cubit<SessionState> {
  SessionCubit() : super(const SessionState());

  void initialize() {
    final token = CurrentUserStorage.getUserAuthToken();
    final user = CurrentUserStorage.getCurrentUser();

    if (token != null && user != null) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        userName: user.fullName,
      ));
    } else {
      emit(state.copyWith(
        status: AuthStatus.guest,
        userName: 'Guest User',
      ));
    }
  }

  void setAuthenticated(String name) {
    emit(state.copyWith(status: AuthStatus.authenticated, userName: name));
  }

  void setGuest() {
    emit(state.copyWith(status: AuthStatus.guest, userName: 'Guest User'));
  }

  Future<void> logout() async {
    await CurrentUserStorage.clearUserData();
    emit(const SessionState(status: AuthStatus.unauthenticated));
  }

  void setVendorStatus(bool isVendor) {
    emit(state.copyWith(isVendor: isVendor));
  }

  bool get isAuthenticated => state.status == AuthStatus.authenticated;
}
