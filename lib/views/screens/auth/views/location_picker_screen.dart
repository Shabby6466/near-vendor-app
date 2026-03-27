import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();
  LatLng _selectedLocation = const LatLng(33.667306, 73.075177); // Default fallback

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pin Your Location',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.textTheme.titleLarge?.color,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 15.0,
              onPositionChanged: (position, hasGesture) {
                setState(() {
                  _selectedLocation = position.center;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                userAgentPackageName: 'com.nearvendorapp.app',
              ),
            ],
          ),
          // Center Marker pointing to the exact center of the map
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0), // Adjust to make the pin's tip point at the center
              child: Icon(
                Icons.location_on,
                size: 50,
                color: theme.primaryColor,
              ),
            ),
          ),
          // Confirm Button
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: AppElevatedButton(
              text: 'Confirm Location',
              onPressed: () {
                Navigator.pop(context, _selectedLocation);
              },
            ),
          ),
        ],
      ),
    );
  }
}
