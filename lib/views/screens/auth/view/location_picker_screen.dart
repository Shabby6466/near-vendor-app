import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:nearvendorapp/services/app_location_service.dart';
import 'package:nearvendorapp/services/location_search_service.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/constants/default_location.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:nearvendorapp/views/widgets/app_search_bar.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;
  const LocationPickerScreen({super.key, this.initialLocation});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final LocationSearchService _locationService = LocationSearchService();
  List<LocationSuggestion> _suggestions = [];
  Timer? _debounce;
  bool _isLoading = false;

  late double _centerLat;
  late double _centerLon;
  String? _selectedPlaceName;

  @override
  void initState() {
    super.initState();
    final saved = AppData().location;
    final initial = widget.initialLocation;

    final initialLat = (initial != null && initial.latitude.isFinite)
        ? initial.latitude
        : null;
    final initialLon = (initial != null && initial.longitude.isFinite)
        ? initial.longitude
        : null;

    final savedLat = (saved != null && saved.latitude.isFinite)
        ? saved.latitude
        : null;
    final savedLon = (saved != null && saved.longitude.isFinite)
        ? saved.longitude
        : null;

    _centerLat = initialLat ?? savedLat ?? DefaultLocation.latitude;
    _centerLon = initialLon ?? savedLon ?? DefaultLocation.longitude;
    _selectedPlaceName = saved?.placeName;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_selectedPlaceName != null && _searchController.text.isEmpty) {
        _searchController.text = _selectedPlaceName!;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _updateCenter(double lat, double lon, {String? placeName}) {
    setState(() {
      _centerLat = lat;
      _centerLon = lon;
      if (placeName != null) {
        _selectedPlaceName = placeName;
      } else {
        _selectedPlaceName = null;
      }
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchSuggestions(query);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    final suggestions = await _locationService.getSuggestions(
      query,
      lat: _centerLat,
      lon: _centerLon,
    );
    if (mounted) {
      setState(() => _suggestions = suggestions);
    }
  }

  void _selectSuggestion(LocationSuggestion suggestion) {
    FocusScope.of(context).unfocus();
    setState(() {
      _suggestions = [];
      _searchController.text = suggestion.displayName;
      _selectedPlaceName = suggestion.displayName;
      _centerLat = suggestion.location.latitude;
      _centerLon = suggestion.location.longitude;
    });
    _mapController.move(suggestion.location, 15.0);
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition();
        final newLocation = LatLng(position.latitude, position.longitude);
        if (!mounted) return;
        _updateCenter(newLocation.latitude, newLocation.longitude);
        _mapController.move(newLocation, 15.0);
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLatLng = LatLng(_centerLat, _centerLon);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Location Picker',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: Container(
            color: theme.scaffoldBackgroundColor.withValues(alpha: 0.7),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => AppNavigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentLatLng,
              initialZoom: 15.0,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture &&
                    position.center.latitude.isFinite &&
                    position.center.longitude.isFinite) {
                  _updateCenter(
                    position.center.latitude,
                    position.center.longitude,
                  );
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                userAgentPackageName: 'com.nearvendorapp.app',
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            left: 20,
            right: 20,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AppSearchBar(
                    controller: _searchController,
                    hintText: 'Search for a place...',
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    onChanged: _onSearchChanged,
                    onClear: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  ),
                ),
                if (_suggestions.isNotEmpty)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(top: 12),
                    constraints: const BoxConstraints(maxHeight: 300),
                    decoration: BoxDecoration(
                      color: theme.cardColor.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _suggestions.length,
                        separatorBuilder: (context, index) => Divider(
                          color: theme.dividerColor.withValues(alpha: 0.1),
                          indent: 20,
                          endIndent: 20,
                        ),
                        itemBuilder: (context, index) {
                          final suggestion = _suggestions[index];
                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.location_on_outlined,
                                color: theme.colorScheme.onSurface,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              suggestion.displayName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _selectSuggestion(suggestion),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Center(
            child: Transform.translate(
              offset: const Offset(0, -28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withValues(alpha: 0.4),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 44,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'my_location',
                        onPressed: _isLoading ? null : _getCurrentLocation,
                        backgroundColor: theme.colorScheme.onSurface,
                        foregroundColor: theme.colorScheme.surface,
                        elevation: 4,
                        child: _isLoading
                            ? const LoadingAnimation(
                                color: Colors.white,
                                size: 18,
                              )
                            : const Icon(Icons.my_location_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppElevatedButton(
                    text: 'Confirm Location',
                    isLoading: _isLoading,
                    onPressed: () async {
                      setState(() => _isLoading = true);
                      try {
                        final placeName =
                            _searchController.text.trim().isNotEmpty
                            ? _searchController.text.trim()
                            : _selectedPlaceName;
                        final result = await AppLocationService.instance
                            .saveLocation(
                              latitude: _centerLat,
                              longitude: _centerLon,
                              placeName: placeName,
                            );
                        if (!context.mounted) return;
                        AppNavigator.pop(context, result);
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
