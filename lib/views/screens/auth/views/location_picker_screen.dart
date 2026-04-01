import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';

import 'dart:async';
import 'package:nearvendorapp/services/location_service.dart';
import 'package:nearvendorapp/views/widgets/app_loading_indicator.dart';
import 'package:nearvendorapp/views/widgets/animated_error_state.dart';
import 'package:nearvendorapp/views/widgets/app_search_bar.dart';

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
  bool _isSearching = false;

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

  Future<void> _fetchSuggestions(String query, {double? lat, double? lon}) async {
    setState(() => _isSearching = true);
    final suggestions = await _locationService.getSuggestions(query, lat: lat, lon: lon);
    if (mounted) {
      setState(() {
        _suggestions = suggestions;
        _isSearching = false;
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
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        final newLocation = LatLng(position.latitude, position.longitude);
        if (mounted) {
          context.read<SessionCubit>().updateTempLocation(
            newLocation.latitude,
            newLocation.longitude,
          );
          _mapController.move(newLocation, 15.0);
        }
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
        final currentLat = state.tempLatitude ?? widget.initialLocation?.latitude ?? state.latitude ?? 33.667306;
        final currentLon = state.tempLongitude ?? widget.initialLocation?.longitude ?? state.longitude ?? 73.075177;
        final currentLatLng = LatLng(currentLat, currentLon);

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Pin Your Location',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
            ),
            elevation: 0,
            backgroundColor: theme.scaffoldBackgroundColor,
            foregroundColor: theme.textTheme.titleLarge?.color,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
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
              // Search Bar Placeholder (Simplified for this version)
              Positioned(
                top: 20,
                left: 20,
                right: 20,
                child: Column(
                  children: [
                    AppSearchBar(
                      controller: _searchController,
                      hintText: 'Search location...',
                      padding: EdgeInsets.zero,
                      onChanged: (value) => _onSearchChanged(
                        value,
                        lat: state.tempLatitude ?? state.latitude,
                        lon: state.tempLongitude ?? state.longitude,
                      ),
                      onClear: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    ),
                    if (_suggestions.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        constraints: const BoxConstraints(maxHeight: 250),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _suggestions.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final suggestion = _suggestions[index];
                            return ListTile(
                              title: Text(
                                suggestion.displayName,
                                style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => _selectSuggestion(suggestion),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              // My Location Button
              Positioned(
                bottom: 110,
                right: 20,
                child: FloatingActionButton(
                  heroTag: 'my_location',
                  onPressed: _isLoading ? null : () => _getCurrentLocation(context),
                  backgroundColor: theme.primaryColor,
                  child: _isLoading
                      ? const LoadingAnimation(color: Colors.white, size: 24)
                      : const Icon(Icons.my_location, color: Colors.white),
                ),
              ),
              // Center Marker
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
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
                  onPressed: () async {
                    await sessionCubit.confirmManualLocationPick();
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


