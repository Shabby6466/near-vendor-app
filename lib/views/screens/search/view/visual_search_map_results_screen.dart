import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';
import 'package:nearvendorapp/views/screens/search/widgets/vendor_list_overlay.dart';
import 'package:nearvendorapp/views/screens/search/widgets/search_bar_field.dart';

class VisualSearchMapResultsScreen extends StatefulWidget {
  final List<Item> results;

  const VisualSearchMapResultsScreen({super.key, required this.results});

  @override
  State<VisualSearchMapResultsScreen> createState() =>
      _VisualSearchMapResultsScreenState();
}

class _VisualSearchMapResultsScreenState
    extends State<VisualSearchMapResultsScreen> {
  final MapController _mapController = MapController();
  late List<Marker> _markers;

  @override
  void initState() {
    super.initState();
    _markers = widget.results
        .where((item) => item.lat != null && item.long != null)
        .map(
          (item) => Marker(
            point: LatLng(item.lat!, item.long!),
            width: 80,
            height: 80,
            child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final initialCenter = _markers.isNotEmpty
        ? _markers.first.point
        : const LatLng(33.5898, 73.0221);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.nearvendor.app',
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: initialCenter,
                      radius: CurrentUserStorage.getDiscoveryRadius() * 1000,
                      useRadiusInMeter: true,
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderColor: Colors.blue.withValues(alpha: 0.3),
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
                MarkerLayer(markers: _markers),
              ],
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.black38,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),

          VendorListOverlay(searchResults: widget.results),
        ],
      ),
    );
  }
}
