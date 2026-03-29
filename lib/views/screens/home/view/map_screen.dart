import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart';
import 'package:nearvendorapp/models/ui_models/shop_model.dart' as ui;
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/views/screens/home/cubit/map_cubit.dart';
import 'package:nearvendorapp/views/screens/home/cubit/map_state.dart';
import 'package:nearvendorapp/views/screens/home/view/shop_details_screen.dart';

class MapScreen extends StatefulWidget {
  final double initialLat;
  final double initialLon;

  const MapScreen({
    super.key,
    required this.initialLat,
    required this.initialLon,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    context.read<MapCubit>().fetchShops(
      lat: widget.initialLat,
      lon: widget.initialLon,
      radius: 5000,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<MapCubit, MapState>(
            builder: (context, state) {
              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(widget.initialLat, widget.initialLon),
                  initialZoom: 13,
                  onPositionChanged: (position, hasGesture) {
                    if (hasGesture) {
                      // Optional: Fetch as user drags?
                      // For now, only fetch on radius change or explicit button.
                    }
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
                    markers: state.shops.map((shop) {
                      return Marker(
                        point: LatLng(shop.shopLatitude, shop.shopLongitude),
                        width: 100,
                        height: 100,
                        child: _buildShopMarker(context, shop),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),

          // Control Panel
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: _buildControlPanel(context),
          ),
          // Recenter Button
          Positioned(
            bottom: 100,
            right: 24,
            child: FloatingActionButton(
              heroTag: 'recenter_map',
              onPressed: () {
                _mapController.move(
                  LatLng(widget.initialLat, widget.initialLon),
                  13,
                );
              },
              backgroundColor: theme.primaryColor,
              child: const Icon(Icons.my_location_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel(BuildContext context) {
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
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${(state.radius / 1000).toStringAsFixed(1)} KM',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w900,
                          color: theme.primaryColor,
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
                      inactiveTrackColor: theme.primaryColor.withValues(
                        alpha: 0.1,
                      ),
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
                                  color:
                                      isSelected ? Colors.white : theme.primaryColor,
                                  fontFamily: 'Poppins',
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

  Widget _buildShopMarker(BuildContext context, Shop shop) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        AppNavigator.push(
          context,
          ShopDetailsScreen(
            shop: ui.ShopModel(
              id: shop.id,
              name: shop.shopName,
              image: shop.coverImageUrl ?? '',
              category: shop.businessCategory,
              latitude: shop.shopLatitude,
              longitude: shop.shopLongitude,
            ),
          ),
        );
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
              shop.shopName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
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
