part of 'session_cubit.dart';

enum AuthStatus { authenticated, unauthenticated, guest }

class SessionState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? userName;
  final bool hasOnboarded;
  final String? photoUrl;
  final double? latitude;
  final double? longitude;
  final String? cityName;
  final double? tempLatitude;
  final double? tempLongitude;

  const SessionState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.userName,
    this.hasOnboarded = false,
    this.photoUrl,
    this.latitude,
    this.longitude,
    this.cityName,
    this.tempLatitude,
    this.tempLongitude,
  });

  @override
  List<Object?> get props => [
    status,
    user,
    userName,
    hasOnboarded,
    photoUrl,
    latitude,
    longitude,
    cityName,
    tempLatitude,
    tempLongitude,
  ];

  SessionState copyWith({
    AuthStatus? status,
    User? user,
    String? userName,
    bool? hasOnboarded,
    String? photoUrl,
    double? latitude,
    double? longitude,
    String? cityName,
    double? tempLatitude,
    double? tempLongitude,
    bool clearTempLocation = false,
  }) {
    return SessionState(
      status: status ?? this.status,
      user: user ?? this.user,
      userName: userName ?? this.userName,
      hasOnboarded: hasOnboarded ?? this.hasOnboarded,
      photoUrl: photoUrl ?? this.photoUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cityName: cityName ?? this.cityName,
      tempLatitude: clearTempLocation
          ? null
          : (tempLatitude ?? this.tempLatitude),
      tempLongitude: clearTempLocation
          ? null
          : (tempLongitude ?? this.tempLongitude),
    );
  }
}
