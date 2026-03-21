part of 'session_cubit.dart';

enum AuthStatus { authenticated, unauthenticated, guest }

class SessionState extends Equatable {
  final AuthStatus status;
  final String? userName;

  const SessionState({
    this.status = AuthStatus.unauthenticated,
    this.userName,
  });

  @override
  List<Object?> get props => [status, userName];

  SessionState copyWith({
    AuthStatus? status,
    String? userName,
  }) {
    return SessionState(
      status: status ?? this.status,
      userName: userName ?? this.userName,
    );
  }
}
