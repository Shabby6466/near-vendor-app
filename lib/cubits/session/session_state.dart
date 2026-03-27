part of 'session_cubit.dart';

enum AuthStatus { authenticated, unauthenticated, guest }

class SessionState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? userName;
  final bool isVendor;

  const SessionState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.userName,
    this.isVendor = false,
  });

  @override
  List<Object?> get props => [status, user, userName, isVendor];

  SessionState copyWith({
    AuthStatus? status,
    User? user,
    String? userName,
    bool? isVendor,
  }) {
    return SessionState(
      status: status ?? this.status,
      user: user ?? this.user,
      userName: userName ?? this.userName,
      isVendor: isVendor ?? this.isVendor,
    );
  }
}
