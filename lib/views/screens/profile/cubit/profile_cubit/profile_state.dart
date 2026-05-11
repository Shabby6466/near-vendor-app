part of 'profile_cubit.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileSuccess extends ProfileState {
  final String userName;
  final String userLocation;
  final String? photoUrl;
  final double discoveryRadius;
  final bool newOfferAlerts;
  final bool isUploadingImage;

  const ProfileSuccess({
    required this.userName,
    required this.userLocation,
    this.photoUrl,
    required this.discoveryRadius,
    required this.newOfferAlerts,
    this.isUploadingImage = false,
  });

  ProfileSuccess copyWith({
    String? userName,
    String? userLocation,
    String? photoUrl,
    double? discoveryRadius,
    bool? newOfferAlerts,
    bool? isUploadingImage,
  }) {
    return ProfileSuccess(
      userName: userName ?? this.userName,
      userLocation: userLocation ?? this.userLocation,
      photoUrl: photoUrl ?? this.photoUrl,
      discoveryRadius: discoveryRadius ?? this.discoveryRadius,
      newOfferAlerts: newOfferAlerts ?? this.newOfferAlerts,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
    );
  }

  @override
  List<Object?> get props => [
    userName,
    userLocation,
    photoUrl,
    discoveryRadius,
    newOfferAlerts,
    isUploadingImage,
  ];
}

final class ProfileFailure extends ProfileState {
  final String error;

  const ProfileFailure(this.error);

  @override
  List<Object?> get props => [error];
}
