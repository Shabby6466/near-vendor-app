import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/enums/auth_status.dart';
import 'package:nearvendorapp/models/data_models/user.dart';
import 'package:nearvendorapp/services/auth_services.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';

part 'session_state.dart';

/// Thin auth-status cubit — owns only: initialize, setAuthenticated,
/// setGuest, logout, setOnboarded.
/// Location is now owned by LocationCubit.
/// Profile updates are now owned by ProfileCubit.
class SessionCubit extends Cubit<SessionState> {
  SessionCubit() : super(const SessionState());

  Future<void> initialize() async {
    final token = CurrentUserStorage.getUserAuthToken();
    final refreshToken = CurrentUserStorage.getUserRefreshAuthToken();
    final user = CurrentUserStorage.getCurrentUser();
    final hasOnboarded = CurrentUserStorage.getHasOnboarded();

    if (token != null) {
      if (user != null) {
        await AppData().setUser(user, token: token, refreshToken: refreshToken);
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            userName: user.fullName,
            hasOnboarded: hasOnboarded,
            photoUrl: user.photoUrl,
          ),
        );
      }

      try {
        final response = await AuthServices().getMe();
        if (response.user != null) {
          await CurrentUserStorage.storeUserData(response.user);
          AppData().setUser(response.user);
          emit(
            state.copyWith(
              status: AuthStatus.authenticated,
              user: response.user,
              userName: response.user?.fullName,
              hasOnboarded: hasOnboarded,
              photoUrl: response.user?.photoUrl,
            ),
          );
        } else {
          await logout();
        }
      } catch (e) {
        debugPrint('Session refresh failed: $e');
        await logout();
      }
    } else {
      emit(
        state.copyWith(
          status: AuthStatus.guest,
          userName: 'Guest User',
          hasOnboarded: hasOnboarded,
        ),
      );
    }
  }

  Future<void> setAuthenticated(User? user) async {
    if (user != null) await AppData().setUser(user);
    emit(
      state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        userName: user?.fullName,
        photoUrl: user?.photoUrl,
      ),
    );
  }

  void setGuest() {
    emit(state.copyWith(status: AuthStatus.guest, userName: 'Guest User'));
  }

  Future<void> logout() async {
    await AppData().clear();
    emit(const SessionState(status: AuthStatus.guest, userName: 'Guest User'));
  }

  void setOnboarded() {
    CurrentUserStorage.setHasOnboarded(true);
    emit(state.copyWith(hasOnboarded: true));
  }

  bool get isAuthenticated => state.status == AuthStatus.authenticated;
}
