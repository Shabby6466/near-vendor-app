part of 'session_cubit.dart';

/// Auth-only state. Location fields have been moved to LocationState.
/// The latitude/longitude/cityName fields are kept as read-only convenience
/// getters derived from AppData so existing BlocBuilder widgets
/// that display the city name don't need to be migrated all at once.
class SessionState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? userName;
  final bool hasOnboarded;
  final String? photoUrl;

  const SessionState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.userName,
    this.hasOnboarded = false,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [status, user, userName, hasOnboarded, photoUrl];

  SessionState copyWith({
    AuthStatus? status,
    User? user,
    String? userName,
    bool? hasOnboarded,
    String? photoUrl,
  }) {
    return SessionState(
      status: status ?? this.status,
      user: user ?? this.user,
      userName: userName ?? this.userName,
      hasOnboarded: hasOnboarded ?? this.hasOnboarded,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
