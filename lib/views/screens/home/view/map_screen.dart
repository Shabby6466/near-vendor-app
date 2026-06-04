import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nearvendorapp/models/data_models/app_location.dart';
import 'package:nearvendorapp/models/data_models/shop.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/navigation/location_picker_launcher.dart';
import 'package:nearvendorapp/views/screens/home/cubit/map_cubit.dart';
import 'package:nearvendorapp/views/screens/home/cubit/map_state.dart';
import 'package:nearvendorapp/views/screens/home/view/customer_shop_details_screen.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController _mapController;
  double? _lastLat;
  double? _lastLon;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLocation?>(
      valueListenable: AppData().locationNotifier,
      builder: (context, location, _) {
        if (location == null) {
          return const _LocationRequiredView();
        }

        if (location.latitude != _lastLat || location.longitude != _lastLon) {
          _lastLat = location.latitude;
          _lastLon = location.longitude;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _mapController.move(location.toLatLng(), 13);
          });
        }

        return BlocProvider(
          key: ValueKey(
            'map_${location.latitude.toStringAsFixed(4)}_${location.longitude.toStringAsFixed(4)}',
          ),
          create: (_) =>
              MapCubit(lat: location.latitude, lon: location.longitude),
          child: _MapView(mapController: _mapController),
        );
      },
    );
  }
}

class _LocationRequiredView extends StatelessWidget {
  const _LocationRequiredView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off_rounded,
                size: 72,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
              ),
              const SizedBox(height: 24),
              Text(
                'Location Not Set',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Set your location to discover nearby shops on the map.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: AppElevatedButton(
                  text: 'Pick Location',
                  onPressed: () async {
                    await LocationPickerLauncher.open(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapView extends StatelessWidget {
  final MapController mapController;

  const _MapView({required this.mapController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<MapCubit, MapState>(
            builder: (context, state) {
              return FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: LatLng(state.latitude, state.longitude),
                  onPositionChanged: (position, hasGesture) {
                    if (hasGesture) {}
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.nearvendor.app',
                  ),
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: LatLng(state.latitude, state.longitude),
                        radius: state.radius,
                        useRadiusInMeter: true,
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderColor: theme.primaryColor.withValues(alpha: 0.3),
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
                   MarkerLayer(
                     markers: state.shops
                         .where((shop) => shop.shopLatitude != null && shop.shopLongitude != null)
                         .map((shop) {
                           return Marker(
                             point: LatLng(shop.shopLatitude!, shop.shopLongitude!),
                             width: 100,
                             height: 100,
                             child: _ShopMarker(shop: shop),
                           );
                         }).toList(),
                   ),
                ],
              );
            },
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: const _ControlPanel(),
          ),
          Positioned(
            bottom: 10,
            right: 24,
            child: SafeArea(
              top: false,
              child: FloatingActionButton(
                heroTag: 'recenter_map',
                onPressed: () {
                  final loc = AppData().location;
                  if (loc != null) {
                    mapController.move(loc.toLatLng(), 13);
                  }
                },

                child: const Icon(Icons.my_location_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlPanel extends StatelessWidget {
  const _ControlPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<MapCubit, MapState>(
      builder: (context, state) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Discovery Radius',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${(state.radius / 1000).toStringAsFixed(1)} KM',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onSurface,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 6,
                      activeTrackColor: theme.primaryColor,
                      inactiveTrackColor: theme.colorScheme.onSurface
                          .withValues(alpha: 0.1),
                      thumbColor: theme.primaryColor,
                      overlayColor: theme.primaryColor.withValues(alpha: 0.1),
                    ),
                    child: Slider(
                      value: state.radius,
                      min: 1000,
                      max: 20000,
                      divisions: 19,
                      onChanged: (val) {
                        context.read<MapCubit>().updateRadius(val);
                      },
                      onChangeEnd: (val) {
                        context.read<MapCubit>().fetchShops(radius: val);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.categories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final category = state.categories[index];
                        final isSelected = state.selectedCategory == category;
                        return GestureDetector(
                          onTap: () =>
                              context.read<MapCubit>().selectCategory(category),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.primaryColor
                                  : theme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : theme.primaryColor,
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShopMarker extends StatelessWidget {
  final Shop shop;

  const _ShopMarker({required this.shop});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        AppNavigator.push(context, CustomerShopDetailsScreen(shop: shop));
      },
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
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: theme.primaryColor, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: shop.storeLogoUrl != null && shop.storeLogoUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: shop.storeLogoUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    )
                  : Icon(
                      Icons.storefront_rounded,
                      color: theme.primaryColor,
                      size: 30,
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                ),
              ],
            ),
             child: Text(
               shop.shopName ?? 'Unknown Shop',
               maxLines: 1,
               overflow: TextOverflow.ellipsis,
               style: const TextStyle(
                 color: Colors.white,
                 fontSize: 10,
                 fontWeight: FontWeight.w700,
               ),
             ),
          ),
        ],
      ),
    );
  }
}
