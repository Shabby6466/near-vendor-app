part of 'location_cubit.dart';

class LocationState extends Equatable {
  final double? latitude;
  final double? longitude;
  final String? cityName;
  final double? tempLatitude;
  final double? tempLongitude;

  const LocationState({
    this.latitude,
    this.longitude,
    this.cityName,
    this.tempLatitude,
    this.tempLongitude,
  });

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    cityName,
    tempLatitude,
    tempLongitude,
  ];

  LocationState copyWith({
    double? latitude,
    double? longitude,
    String? cityName,
    double? tempLatitude,
    double? tempLongitude,
    bool clearTempLocation = false,
  }) {
    return LocationState(
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
