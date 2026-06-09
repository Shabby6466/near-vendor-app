import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/data_models/shop.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/navigation/location_picker_launcher.dart';
import 'package:nearvendorapp/utils/theme/app_spacing.dart';
import 'package:nearvendorapp/views/screens/common/fallback_banner.dart';
import 'package:nearvendorapp/views/screens/home/cubit/explore_screen_cubit.dart';
import 'package:nearvendorapp/views/screens/home/widgets/explore_shimmer_loading.dart';
import 'package:nearvendorapp/views/screens/shop_detail_screen/view/shop_detail_screen.dart';
import 'package:nearvendorapp/views/widgets/animated_error_state.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ShopGrid extends StatelessWidget {
  const ShopGrid({super.key});

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
                        Icons.location_off_rounded,
                        size: 64,
                        color: theme.primaryColor.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Location Not Set',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please set your location to discover local vendors and shops near you.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await LocationPickerLauncher.open(context);
                        if (context.mounted) {
                          context
                              .read<ExploreScreenCubit>()
                              .reloadAfterLocationSet();
                        }
                      },
                      icon: const Icon(
                        Icons.my_location_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Set Location',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                            cubit.trackImpression(
                              shop.id ?? '',
                            );
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
                        child: CircularProgressIndicator(),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isDark
            ? Border.all(color: theme.dividerColor.withValues(alpha: 0.1))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
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
                    placeholder: (context, url) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor.withValues(alpha: 0.1),
                            theme.primaryColor.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.storefront_outlined,
                          color: theme.primaryColor.withValues(alpha: 0.4),
                          size: 32,
                        ),
                      ),
                    ),
                    errorWidget: (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor.withValues(alpha: 0.1),
                            theme.primaryColor.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.storefront_outlined,
                          color: theme.primaryColor.withValues(alpha: 0.4),
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
                if (shop.distance != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                            shop.distance! < 1000
                                ? '${shop.distance!.toInt()}m'
                                : '${(shop.distance! / 1000).toStringAsFixed(1)}km',
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
                // Badge Overlays
                Positioned(
                  top: 8,
                  left: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (shop.isVerifiedBadge ?? false)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            color: Colors.blue,
                            size: 14,
                          ),
                        ),
                      if (shop.isRecentlyActive ?? false)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Category Tag
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      shop.businessCategory?.toUpperCase() ?? 'N/A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shop.shopName ?? 'Unknown Shop',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 12,
                      color: theme.primaryColor.withValues(alpha: 0.7),
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
                if (shop.itemCount != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${shop.itemCount} Items Available',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
