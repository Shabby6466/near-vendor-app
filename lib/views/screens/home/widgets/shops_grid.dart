import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearvendorapp/models/data_models/app_location.dart';
import 'package:nearvendorapp/models/data_models/shop.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/theme/app_spacing.dart';
import 'package:nearvendorapp/views/screens/common/fallback_banner.dart';
import 'package:nearvendorapp/views/screens/home/cubit/explore_screen_cubit.dart';
import 'package:nearvendorapp/views/screens/home/widgets/explore_shimmer_loading.dart';
import 'package:nearvendorapp/views/screens/shop_detail_screen/view/shop_detail_screen.dart';
import 'package:nearvendorapp/views/widgets/animated_error_state.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';
import 'package:nearvendorapp/views/widgets/location_required_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ShopsGrid extends StatelessWidget {
  const ShopsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<ExploreScreenCubit, ExploreScreenState>(
      builder: (context, state) {
        if (state is ExploreScreenLoading) {
          return const ExploreShimmerLoading();
        }

        if (state is ExploreScreenNoLocation) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: LocationRequiredWidget(
              onLocationSet: () {
                context.read<ExploreScreenCubit>().reloadAfterLocationSet();
              },
            ),
          );
        }

        if (state is ExploreScreenFailure) {
          return SliverFillRemaining(
            child: AnimatedErrorState(
              message: state.message,
              onRetry: () {
                context.read<ExploreScreenCubit>().loadShops();
              },
            ),
          );
        }

        if (state is ExploreScreenSuccess) {
          final cubit = context.read<ExploreScreenCubit>();
          final shops = cubit.shops;

          if (shops.isEmpty) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.storefront_rounded,
                          size: 64,
                          color: theme.primaryColor.withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No vendors found here',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try exploring a different category or\ncheck back later for new arrivals.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white54 : Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return SliverMainAxisGroup(
            slivers: [
              if (cubit.isGlobalFallback && cubit.rangeMessage != null)
                SliverPadding(
                  padding: const EdgeInsets.only(top: 12),
                  sliver: SliverToBoxAdapter(
                    child: FallbackBanner(message: cubit.rangeMessage!),
                  ),
                ),
              SliverPadding(
                padding: EdgeInsets.only(
                  left: AppSpacing.mediumHorizontalSpacing(context),
                  right: AppSpacing.mediumHorizontalSpacing(context),
                  top: cubit.isGlobalFallback ? 8 : 12,
                  bottom: cubit.isLoadingNextPage
                      ? 12
                      : AppSpacing.screenHeight(context) * 0.1 + 24,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final shop = shops[index];
                    return GestureDetector(
                      onTap: () {
                        AppNavigator.push(
                          context,
                          ShopDetailScreen(shop: shop),
                        );
                      },
                      child: VisibilityDetector(
                        key: Key('shop-${shop.id ?? index}'),
                        onVisibilityChanged: (info) {
                          if (info.visibleFraction > 0.5) {
                            cubit.trackImpression(shop.id ?? '');
                          }
                        },
                        child: ShopCard(shop: shop),
                      ),
                    );
                  }, childCount: shops.length),
                ),
              ),
              if (cubit.isLoadingNextPage)
                SliverPadding(
                  padding: EdgeInsets.only(
                    bottom: AppSpacing.screenHeight(context) * 0.1 + 24,
                  ),
                  sliver: const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: LoadingAnimation(),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}

class ShopCard extends StatelessWidget {
  final Shop shop;

  const ShopCard({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: isDark ? 0.1 : 0.06),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.5,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: shop.coverImageUrl ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor.withValues(alpha: 0.06),
                            theme.primaryColor.withValues(alpha: 0.02),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.storefront_rounded,
                          color: theme.primaryColor.withValues(alpha: 0.2),
                          size: 36,
                        ),
                      ),
                    ),
                    errorWidget: (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor.withValues(alpha: 0.06),
                            theme.primaryColor.withValues(alpha: 0.02),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.storefront_rounded,
                          color: theme.primaryColor.withValues(alpha: 0.2),
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
                ValueListenableBuilder<AppLocation?>(
                  valueListenable: AppData().locationNotifier,
                  builder: (context, userLocation, _) {
                    double? calculatedDistance = shop.distance;
                    if (userLocation != null &&
                        shop.shopLatitude != null &&
                        shop.shopLongitude != null) {
                      calculatedDistance = Geolocator.distanceBetween(
                        userLocation.latitude,
                        userLocation.longitude,
                        shop.shopLatitude!,
                        shop.shopLongitude!,
                      );
                    }

                    if (calculatedDistance == null) return const SizedBox.shrink();

                    return Positioned(
                      top: 8,
                      right: 8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            color: Colors.black.withValues(alpha: 0.4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white,
                                  size: 10,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  calculatedDistance < 1000
                                      ? '${calculatedDistance.toInt()}m'
                                      : '${(calculatedDistance / 1000).toStringAsFixed(1)}km',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (shop.businessCategory?.isNotEmpty ?? false) ...[
                  Text(
                    shop.businessCategory!.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        shop.shopName ?? 'Unknown Shop',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    if (shop.isVerifiedBadge ?? false) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.verified_rounded,
                        color: theme.primaryColor,
                        size: 14,
                      ),
                    ],
                    if (shop.isRecentlyActive ?? false) ...[
                      const SizedBox(width: 4),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 11,
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        shop.shopAddress != null && shop.shopAddress!.isNotEmpty
                            ? shop.shopAddress!
                            : 'N/A',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
