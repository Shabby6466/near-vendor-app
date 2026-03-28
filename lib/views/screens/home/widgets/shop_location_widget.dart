import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ShopLocationWidget extends StatelessWidget {
  final String shopName;
  final String shopAddress;
  final double latitude;
  final double longitude;
  final double? userLatitude;
  final double? userLongitude;

  const ShopLocationWidget({
    super.key,
    required this.shopName,
    required this.shopAddress,
    required this.latitude,
    required this.longitude,
    this.userLatitude,
    this.userLongitude,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(latitude, longitude),
          initialZoom: 14.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
            userAgentPackageName: 'com.nearvendorapp.app',
          ),
          MarkerLayer(
            markers: [
              // Shop Marker
              Marker(
                point: LatLng(latitude, longitude),
                alignment: Alignment.topCenter,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              // User Marker
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
