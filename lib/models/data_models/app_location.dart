import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

/// Canonical lat/lng + optional human-readable place name for the app.
class AppLocation extends Equatable {
  final double latitude;
  final double longitude;
  final String? placeName;

  const AppLocation({
    required this.latitude,
    required this.longitude,
    this.placeName,
  });

  factory AppLocation.fromLatLng(LatLng latLng, {String? placeName}) {
    return AppLocation(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
      placeName: placeName,
    );
  }

  LatLng toLatLng() => LatLng(latitude, longitude);

  bool get hasPlaceName => placeName != null && placeName!.trim().isNotEmpty;

  String get displayLabel {
    if (hasPlaceName) return placeName!.trim();
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }

  AppLocation copyWith({
    double? latitude,
    double? longitude,
    String? placeName,
  }) {
    return AppLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeName: placeName ?? this.placeName,
    );
  }

  @override
  List<Object?> get props => [latitude, longitude, placeName];
}
