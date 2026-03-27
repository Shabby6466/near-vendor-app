part of 'session_cubit.dart';

enum AuthStatus { authenticated, unauthenticated, guest }

class SessionState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? userName;
  final bool isVendor;
  final bool hasOnboarded;
  final String? photoUrl;
  final double? latitude;
  final double? longitude;
  final String? cityName;
  final String? vendorStatus;

  const SessionState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.userName,
    this.isVendor = false,
    this.hasOnboarded = false,
    this.photoUrl,
    this.latitude,
    this.longitude,
    this.cityName,
    this.vendorStatus,
  });

  @override
  List<Object?> get props => [
        status,
        user,
        userName,
        isVendor,
        hasOnboarded,
        photoUrl,
        latitude,
        longitude,
        cityName,
        vendorStatus,
      ];

  SessionState copyWith({
    AuthStatus? status,
    User? user,
    String? userName,
    bool? isVendor,
    bool? hasOnboarded,
    String? photoUrl,
    double? latitude,
    double? longitude,
    String? cityName,
    String? vendorStatus,
    bool clearVendorStatus = false,
  }) {
    return SessionState(
      status: status ?? this.status,
      user: user ?? this.user,
      userName: userName ?? this.userName,
      isVendor: isVendor ?? this.isVendor,
      hasOnboarded: hasOnboarded ?? this.hasOnboarded,
      photoUrl: photoUrl ?? this.photoUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cityName: cityName ?? this.cityName,
      vendorStatus: clearVendorStatus ? null : (vendorStatus ?? this.vendorStatus),
    );
  }
}
