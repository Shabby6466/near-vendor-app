part of 'session_cubit.dart';

enum AuthStatus { authenticated, unauthenticated, guest }

class SessionState extends Equatable {
  final AuthStatus status;
  final String? userName;
  final bool isVendor;

  const SessionState({
    this.status = AuthStatus.unauthenticated,
    this.userName,
    this.isVendor = false,
  });

  @override
  List<Object?> get props => [status, userName, isVendor];

  SessionState copyWith({
    AuthStatus? status,
    String? userName,
    bool? isVendor,
  }) {
    return SessionState(
      status: status ?? this.status,
      userName: userName ?? this.userName,
      isVendor: isVendor ?? this.isVendor,
    );
  }
}
