import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  SessionCubit() : super(const SessionState());

  void setAuthenticated(String name) {
    emit(state.copyWith(status: AuthStatus.authenticated, userName: name));
  }

  void setGuest() {
    emit(state.copyWith(status: AuthStatus.guest, userName: 'Guest User'));
  }

  void logout() {
    emit(const SessionState(status: AuthStatus.unauthenticated));
  }

  void setVendorStatus(bool isVendor) {
    emit(state.copyWith(isVendor: isVendor));
  }

  bool get isAuthenticated => state.status == AuthStatus.authenticated;
}
