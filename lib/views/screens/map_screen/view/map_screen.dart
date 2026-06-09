import 'dart:async';
import 'dart:math' as math;
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
import 'package:nearvendorapp/utils/ui/app_alerts.dart';
import 'package:nearvendorapp/views/screens/map_screen/cubit/map_cubit.dart';
import 'package:nearvendorapp/views/screens/map_screen/cubit/map_state.dart';
import 'package:nearvendorapp/views/screens/shop_detail_screen/view/shop_detail_screen.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';
import 'package:nearvendorapp/views/widgets/location_required_widget.dart';

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
        if (location == null ||
            !location.latitude.isFinite ||
            !location.longitude.isFinite) {
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
          child: BlocListener<MapCubit, MapState>(
            listener: (context, state) {
              if (state is MapFailure) {
                AppAlerts.showError(context, state.message);
              }
            },
            child: _MapView(mapController: _mapController),
          ),
        );
      },
    );
  }
}

class _LocationRequiredView extends StatelessWidget {
  const _LocationRequiredView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LocationRequiredWidget(
        description: 'Set your location to discover nearby shops on the map.',
        buttonText: 'Pick Location',
      ),
    );
  }
}

class ShopCluster {
  final double latitude;
  final double longitude;
  final List<Shop> shops;

  ShopCluster({
    required this.latitude,
    required this.longitude,
    required this.shops,
  });
}

class _MapView extends StatefulWidget {
  final MapController mapController;

  const _MapView({required this.mapController});

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> {
  double _currentZoom = 13.0;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  List<ShopCluster> _clusterShops(List<Shop> shops, double zoom) {
    if (zoom.isNaN || zoom >= 16.5) {
      return shops
          .map(
            (shop) => ShopCluster(
              latitude: shop.shopLatitude!,
              longitude: shop.shopLongitude!,
              shops: [shop],
            ),
          )
          .toList();
    }

    final List<ShopCluster> clusters = [];
    final double radiusLimit = 60.0 * 360.0 / (256.0 * math.pow(2.0, zoom));
    final double radiusLimitSq = radiusLimit * radiusLimit;

    for (final shop in shops) {
      if (shop.shopLatitude == null || shop.shopLongitude == null) continue;
      if (!shop.shopLatitude!.isFinite || !shop.shopLongitude!.isFinite)
        continue;

      ShopCluster? mergedCluster;
      for (final cluster in clusters) {
        final double dLat = cluster.latitude - shop.shopLatitude!;
        final double dLon = cluster.longitude - shop.shopLongitude!;
        final double distSq = dLat * dLat + dLon * dLon;
        if (distSq < radiusLimitSq) {
          mergedCluster = cluster;
          break;
        }
      }

      if (mergedCluster != null) {
        mergedCluster.shops.add(shop);
      } else {
        clusters.add(
          ShopCluster(
            latitude: shop.shopLatitude!,
            longitude: shop.shopLongitude!,
            shops: [shop],
          ),
        );
      }
    }

    return clusters;
  }

  List<Marker> _buildMarkers(
    BuildContext context,
    List<Shop> shops,
    double zoom,
  ) {
    final validShops = shops
        .where(
          (shop) =>
              shop.shopLatitude != null &&
              shop.shopLongitude != null &&
              shop.shopLatitude!.isFinite &&
              shop.shopLongitude!.isFinite,
        )
        .toList();

    final clusters = _clusterShops(validShops, zoom);

    return clusters.map((cluster) {
      if (cluster.shops.length == 1) {
        final shop = cluster.shops.first;
        return Marker(
          point: LatLng(shop.shopLatitude!, shop.shopLongitude!),
          width: 100,
          height: 100,
          child: _ShopMarker(shop: shop),
        );
      } else {
        return Marker(
          point: LatLng(cluster.latitude, cluster.longitude),
          width: 90,
          height: 90,
          child: _ClusterMarker(cluster: cluster),
        );
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<MapCubit>();

    final double lat = cubit.latitude.isFinite ? cubit.latitude : 0.0;
    final double lon = cubit.longitude.isFinite ? cubit.longitude : 0.0;

    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<MapCubit, MapState>(
            builder: (context, state) {
              return FlutterMap(
                mapController: widget.mapController,
                options: MapOptions(
                  initialCenter: LatLng(lat, lon),
                  onPositionChanged: (position, hasGesture) {
                    if (position.zoom.isFinite &&
                        (position.zoom - _currentZoom).abs() > 0.15) {
                      setState(() {
                        _currentZoom = position.zoom;
                      });
                    }

                    _debounceTimer?.cancel();
                    _debounceTimer = Timer(
                      const Duration(milliseconds: 400),
                      () {
                        final camera = widget.mapController.camera;
                        if (!camera.center.latitude.isFinite ||
                            !camera.center.longitude.isFinite ||
                            !camera.zoom.isFinite) {
                          return;
                        }
                        final bounds = camera.visibleBounds;
                        if (!bounds.south.isFinite ||
                            !bounds.north.isFinite ||
                            !bounds.west.isFinite ||
                            !bounds.east.isFinite) {
                          return;
                        }
                        context.read<MapCubit>().fetchShops(
                          lat: camera.center.latitude,
                          lon: camera.center.longitude,
                          minLat: bounds.south,
                          maxLat: bounds.north,
                          minLon: bounds.west,
                          maxLon: bounds.east,
                        );
                      },
                    );
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
                        point: LatLng(lat, lon),
                        radius: cubit.radius,
                        useRadiusInMeter: true,
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderColor: theme.primaryColor.withValues(alpha: 0.3),
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: _buildMarkers(context, cubit.shops, _currentZoom),
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
                    widget.mapController.move(loc.toLatLng(), 13);
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

class _ClusterMarker extends StatelessWidget {
  final ShopCluster cluster;

  const _ClusterMarker({required this.cluster});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = cluster.shops.length;

    return GestureDetector(
      onTap: () {
        _showShopsBottomSheet(context, cluster.shops);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor,
                  theme.primaryColor.withValues(alpha: 0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.white, width: 2.5),
            ),
            child: Center(
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.primaryColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Text(
              '$count Shops',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 9,
                fontWeight: FontWeight.w800,
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
    final cubit = context.read<MapCubit>();

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
                        '${(cubit.radius / 1000).toStringAsFixed(1)} KM',
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
                      value: cubit.radius,
                      min: 1000,
                      max: 20000,
                      divisions: 19,
                      onChanged: (val) {
                        cubit.updateRadius(val);
                      },
                      onChangeEnd: (val) {
                        cubit.fetchShops(radius: val);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: cubit.categories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final category = cubit.categories[index];
                        final isSelected = cubit.selectedCategory == category;
                        return GestureDetector(
                          onTap: () => cubit.selectCategory(category),
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
        AppNavigator.push(context, ShopDetailScreen(shop: shop));
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

void _showShopsBottomSheet(BuildContext context, List<Shop> shops) {
  AppBottomSheet.showScrollableBottomSheet(
    context: context,
    minChildSize: 0.5,
    builder: (context, scrollController) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shops in this Area',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${shops.length} vendors',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.1)),
          Flexible(
            child: ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: shops.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final shop = shops[index];
                return Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.dividerColor.withValues(
                        alpha: isDark ? 0.15 : 0.08,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.2 : 0.02,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            shop.storeLogoUrl != null &&
                                shop.storeLogoUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: shop.storeLogoUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.storefront_rounded,
                                  color: theme.primaryColor,
                                ),
                              )
                            : Icon(
                                Icons.storefront_rounded,
                                color: theme.primaryColor,
                                size: 26,
                              ),
                      ),
                    ),
                    title: Text(
                      shop.shopName ?? 'Unknown Shop',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 12,
                              color: theme.primaryColor.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                shop.shopAddress ?? 'No address listed',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (shop.businessCategory != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              shop.businessCategory!.toUpperCase(),
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: theme.primaryColor.withValues(alpha: 0.7),
                    ),
                    onTap: () {
                      AppNavigator.pop(context); // close bottom sheet
                      AppNavigator.push(context, ShopDetailScreen(shop: shop));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      );
    },
  );
}
