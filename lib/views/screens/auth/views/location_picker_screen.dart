import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/services/location_service.dart';
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
  final LocationService _locationService = LocationService();
  List<LocationSuggestion> _suggestions = [];
  Timer? _debounce;
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query, {double? lat, double? lon}) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchSuggestions(query, lat: lat, lon: lon);
    });
  }

  Future<void> _fetchSuggestions(
    String query, {
    double? lat,
    double? lon,
  }) async {
    final suggestions = await _locationService.getSuggestions(
      query,
      lat: lat,
      lon: lon,
    );
    if (mounted) {
      setState(() {
        _suggestions = suggestions;
      });
    }
  }

  void _selectSuggestion(LocationSuggestion suggestion) {
    FocusScope.of(context).unfocus();
    setState(() {
      _suggestions = [];
      _searchController.text = suggestion.displayName;
    });

    _mapController.move(suggestion.location, 15.0);
    context.read<SessionCubit>().updateTempLocation(
      suggestion.location.latitude,
      suggestion.location.longitude,
    );
  }

  Future<void> _getCurrentLocation(BuildContext context) async {
    setState(() => _isLoading = true);
    // Capture cubit reference before any await so we don't use context across gaps
    final sessionCubit = context.read<SessionCubit>();
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
        sessionCubit.updateTempLocation(
          newLocation.latitude,
          newLocation.longitude,
        );
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

    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        final sessionCubit = context.read<SessionCubit>();
        final currentLat =
            state.tempLatitude ??
            widget.initialLocation?.latitude ??
            state.latitude ??
            33.667306;
        final currentLon =
            state.tempLongitude ??
            widget.initialLocation?.longitude ??
            state.longitude ??
            73.075177;
        final currentLatLng = LatLng(currentLat, currentLon);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text(
              'Location Picker',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
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
              onPressed: () {
                sessionCubit.cancelManualLocationPick();
                Navigator.pop(context);
              },
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
                    if (hasGesture) {
                      sessionCubit.updateTempLocation(
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

              // Top Search Overlay
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
                        onChanged: (value) => _onSearchChanged(
                          value,
                          lat: currentLat,
                          lon: currentLon,
                        ),
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

              // Center Target Indicator
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
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

              // Bottom Actions Layout
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
                            onPressed: _isLoading
                                ? null
                                : () => _getCurrentLocation(context),
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
                          // Capture navigator before await to avoid context-across-gap lint
                          final nav = Navigator.of(context);
                          try {
                            await sessionCubit.confirmManualLocationPick();
                            if (!mounted) return;
                            nav.pop();
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
      },
    );
  }
}
