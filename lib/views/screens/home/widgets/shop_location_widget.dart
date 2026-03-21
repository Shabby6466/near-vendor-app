import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';

class ShopLocationWidget extends StatelessWidget {
  final String shopName;
  final String shopAddress;
  final double latitude;
  final double longitude;

  const ShopLocationWidget({
    super.key,
    required this.shopName,
    required this.shopAddress,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: FlutterMap(
        options: MapOptions(initialCenter: LatLng(latitude, longitude), initialZoom: 15.0),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
            userAgentPackageName: 'com.nearvendorapp.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(33.667306, 73.075177),
                alignment: Alignment.topCenter,
                child: SvgPicture.asset('assets/icons/location_marker.svg', width: 35, height: 35),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
