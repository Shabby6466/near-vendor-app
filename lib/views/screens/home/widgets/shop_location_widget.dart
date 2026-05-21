import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// A completely stateless, non-interactive generic map view.
/// Disables all map interaction flags to act as a premium static map display.
class ShopLocationWidget extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double? userLatitude;
  final double? userLongitude;
  final double zoom;
  final double borderRadius;
  final String? shopName;
  final String? shopAddress;

  const ShopLocationWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.userLatitude,
    this.userLongitude,
    this.zoom = 14.0,
    this.borderRadius = 22.0,
    this.shopName,
    this.shopAddress,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(latitude, longitude),
          initialZoom: zoom,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.none,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
            userAgentPackageName: 'com.nearvendorapp.app',
          ),
          MarkerLayer(
            markers: [
              // Target Location Marker
              Marker(
                point: LatLng(latitude, longitude),
                alignment: Alignment.topCenter,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              // User Location Marker
              if (userLatitude != null && userLongitude != null)
                Marker(
                  point: LatLng(userLatitude!, userLongitude!),
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: const Icon(
                      Icons.person_pin_circle,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
