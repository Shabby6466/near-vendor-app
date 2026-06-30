import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearvendorapp/enums/report_target_type.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/models/data_models/opening_hours.dart';
import 'package:nearvendorapp/models/data_models/product_model.dart';
import 'package:nearvendorapp/models/data_models/shop.dart';
import 'package:nearvendorapp/services/review_services.dart';
import 'package:nearvendorapp/services/safety_services.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/helper_functions.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/theme/app_spacing.dart';
import 'package:nearvendorapp/utils/ui/app_alerts.dart';
import 'package:nearvendorapp/views/screens/auth/view/login_screen.dart';
import 'package:nearvendorapp/views/screens/common/image_viewer_screen.dart';
import 'package:nearvendorapp/views/screens/home/widgets/shop_location_widget.dart';
import 'package:nearvendorapp/views/screens/product_detail_screen/view/product_detail_screen.dart';
import 'package:nearvendorapp/views/screens/shop_detail_screen/cubit/shop_detail_cubit.dart';
import 'package:nearvendorapp/views/screens/shop_detail_screen/reviews/view/reviews_screen.dart';
import 'package:nearvendorapp/views/screens/shop_detail_screen/reviews/widgets/rating_summary_widget.dart';
import 'package:nearvendorapp/views/screens/shop_detail_screen/reviews/widgets/review_card.dart';
import 'package:nearvendorapp/views/screens/shop_detail_screen/widgets/shop_detail_shimmer_loading.dart';
import 'package:nearvendorapp/views/widgets/animated_error_state.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';
import 'package:nearvendorapp/views/widgets/safety_report/safety_report_bottom_sheet.dart';
import 'package:nearvendorapp/views/widgets/shop_timing_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ShopDetailScreen extends StatelessWidget {
  final Shop shop;

  const ShopDetailScreen({super.key, required this.shop});

  bool _isValidLatLng(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    return lat.isFinite &&
        lng.isFinite &&
        lat != 0.0 &&
        lng != 0.0 &&
        lat >= -90.0 &&
        lat <= 90.0 &&
        lng >= -180.0 &&
        lng <= 180.0;
  }

  void _handleSafetyAction(BuildContext context, Shop fullShop) {
    if (!AppData().isLoggedIn) {
      AppBottomSheet.showConfirmationBottomSheet(
        context: context,
        title: 'Sign In Required',
        message: 'You need to sign in to report content or block vendors.',
        confirmButtonText: 'Sign In',
        onConfirm: () {
          AppNavigator.push(context, const LoginScreen());
        },
      );
      return;
    }
    _showSafetyMenu(context, fullShop);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final shopId = shop.id ?? '';
        return ShopDetailCubit()..loadShopData(shopId, initialShop: shop);
      },
      child: BlocBuilder<ShopDetailCubit, ShopDetailState>(
        builder: (context, state) {
          final fullShop = state is ShopDetailSuccess ? state.shop : null;

          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.black,
                      size: 18,
                    ),
                    onPressed: () => AppNavigator.pop(context),
                  ),
                ),
              ),
              actions: [
                if (fullShop != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(
                          Icons.more_horiz_rounded,
                          color: Colors.black,
                          size: 20,
                        ),
                        onPressed: () => _handleSafetyAction(context, fullShop),
                      ),
                    ),
                  ),
              ],
            ),
            body: _buildBody(context, state),
            floatingActionButton: fullShop != null
                ? _buildFloatingActionPill(context, fullShop)
                : null,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ShopDetailState state) {
    if (state is ShopDetailLoading) {
      return const ShopDetailShimmerLoading();
    }

    if (state is ShopDetailFailure) {
      return AnimatedErrorState(
        message: state.message,
        onRetry: () =>
            context.read<ShopDetailCubit>().loadShopData(shop.id ?? ''),
      );
    }

    if (state is ShopDetailSuccess) {
      final fullShop = state.shop;
      final inventory = state.inventory;

      return RefreshIndicator(
        onRefresh: () async {
          await context.read<ShopDetailCubit>().loadShopData(fullShop.id ?? '');
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderImage(context, fullShop),
              _buildSellerCard(context, fullShop),
              SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
              _buildReviewsSection(context, fullShop),
              SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
              _buildMapSection(context, fullShop),
              SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
              _buildShopAds(context, fullShop, inventory),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildReviewsSection(BuildContext context, Shop fullShop) {
    final state = context.read<ShopDetailCubit>().state;
    final stats = state is ShopDetailSuccess ? state.reviewStats : null;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.mediumHorizontalSpacing(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RatingSummaryWidget(
            stats: stats,
            onTap: () {
              AppNavigator.push(context, ReviewsScreen(shop: fullShop)).then((
                _,
              ) {
                if (context.mounted) {
                  context.read<ShopDetailCubit>().loadShopData(
                    fullShop.id ?? '',
                  );
                }
              });
            },
          ),
          if (fullShop.userReview != null) ...[
            const SizedBox(height: 16),
            Text(
              'Your Review',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ReviewCard(
              review: fullShop.userReview!,
              shop: fullShop,
              onDeleted: () async {
                // Delete review and reload
                if (fullShop.userReview!.id != null) {
                  final res = await ReviewServices().deleteReview(
                    fullShop.userReview!.id!,
                  );
                  if (res.isSuccess && context.mounted) {
                    context.read<ShopDetailCubit>().loadShopData(
                      fullShop.id ?? '',
                    );
                  }
                }
              },
              onEdited: () {
                context.read<ShopDetailCubit>().loadShopData(fullShop.id ?? '');
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMapSection(BuildContext context, Shop fullShop) {
    final theme = Theme.of(context);
    final isLocationValid = _isValidLatLng(
      fullShop.shopLatitude,
      fullShop.shopLongitude,
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.mediumHorizontalSpacing(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shop Location',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          if (fullShop.shopAddress != null &&
              fullShop.shopAddress!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.map_rounded,
                  size: 16,
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.6,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    fullShop.shopAddress!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: AppSpacing.smallVerticalSpacing(context)),
          if (isLocationValid)
            FutureBuilder<Object?>(
              future: Geolocator.getLastKnownPosition(),
              builder: (context, snapshot) {
                final userPos = snapshot.data as Position?;
                return Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ShopLocationWidget(
                    shopName: fullShop.shopName ?? 'Shop',
                    shopAddress: fullShop.shopAddress ?? '',
                    latitude: fullShop.shopLatitude!,
                    longitude: fullShop.shopLongitude!,
                    userLatitude: userPos?.latitude,
                    userLongitude: userPos?.longitude,
                  ),
                );
              },
            )
          else
            Container(
              height: 120,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off_rounded,
                    color: theme.disabledColor,
                    size: 36,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Interactive map location not available.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.disabledColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderPlaceholder(BuildContext context, String shopName) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withValues(alpha: 0.15),
            theme.primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storefront_rounded,
              size: 64,
              color: theme.primaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              shopName,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.textTheme.titleMedium?.color?.withValues(
                  alpha: 0.6,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage(BuildContext context, Shop fullShop) {
    final theme = Theme.of(context);
    final coverUrl = fullShop.coverImageUrl ?? shop.coverImageUrl;
    final shopName = fullShop.shopName ?? shop.shopName ?? 'Shop';
    return SizedBox(
      height: AppSpacing.screenHeight(context) * 0.35,
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          if (coverUrl != null && coverUrl.isNotEmpty) {
            AppNavigator.push(
              context,
              ImageViewerScreen(imageUrls: [coverUrl]),
            );
          }
        },
        child: coverUrl != null && coverUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: coverUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => ColoredBox(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                  child: const Center(child: LoadingAnimation()),
                ),
                errorWidget: (context, error, stackTrace) =>
                    _buildHeaderPlaceholder(context, shopName),
              )
            : _buildHeaderPlaceholder(context, shopName),
      ),
    );
  }

  Widget _buildSellerCard(BuildContext context, Shop fullShop) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.mediumHorizontalSpacing(context),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(width: 100, height: 60),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullShop.shopName ?? 'Shop',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                      ),
                    ),
                    Text(
                      fullShop.businessCategory ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    _buildTimingSection(context, fullShop),
                    if (fullShop.shopAddress != null &&
                        fullShop.shopAddress!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              fullShop.shopAddress!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color
                                    ?.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (fullShop.isVerifiedBadge ?? false)
                Icon(
                  Icons.verified_rounded,
                  size: 20,
                  color: theme.primaryColor,
                ),
            ],
          ),
          Positioned(
            left: 0,
            top: -50,
            child: GestureDetector(
              onTap: () {
                final logoUrl = fullShop.storeLogoUrl;
                if (logoUrl != null && logoUrl.isNotEmpty) {
                  AppNavigator.push(
                    context,
                    ImageViewerScreen(imageUrls: [logoUrl]),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: theme.cardColor,
                  backgroundImage: fullShop.storeLogoUrl != null &&
                          fullShop.storeLogoUrl!.isNotEmpty
                      ? CachedNetworkImageProvider(fullShop.storeLogoUrl!)
                      : null,
                  child: fullShop.storeLogoUrl == null ||
                          fullShop.storeLogoUrl!.isEmpty
                      ? Icon(
                          Icons.storefront_rounded,
                          size: 45,
                          color: theme.primaryColor.withValues(alpha: 0.5),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingSection(BuildContext context, Shop fullShop) {
    final theme = Theme.of(context);
    final openingHoursMap = fullShop.openingHours;
    if (openingHoursMap == null || openingHoursMap.isEmpty) {
      return const SizedBox.shrink();
    }

    final shopOpeningHours = ShopOpeningHours.fromJson(openingHoursMap);
    final statusInfo = shopOpeningHours.getStatusInfo();
    bool isExpanded = false;

    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: StatefulBuilder(
        builder: (context, setStateExpanded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setStateExpanded(() {
                    isExpanded = !isExpanded;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_filled_rounded,
                      size: 14,
                      color: statusInfo.statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusInfo.statusText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusInfo.statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        ' • ${statusInfo.timeDetails}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (isExpanded) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ShopTimingView(openingHours: shopOpeningHours),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildShopAds(
    BuildContext context,
    Shop fullShop,
    List<Product> inventory,
  ) {
    final theme = Theme.of(context);
    final state = context.read<ShopDetailCubit>().state;
    final isLoadingInventory =
        state is ShopDetailSuccess && state.isLoadingInventory;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.mediumHorizontalSpacing(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Inventory',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${inventory.length} items',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.smallVerticalSpacing(context)),
          if (isLoadingInventory)
            const ShopInventoryShimmerLoading()
          else if (inventory.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text('No items available in this shop'),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.82,
              ),
              itemCount: inventory.length,
              itemBuilder: (context, index) {
                return _ShopProductCard(
                  item: inventory[index],
                  shopName: fullShop.shopName ?? 'Shop',
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionPill(BuildContext context, Shop shop) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLocationValid = _isValidLatLng(
      shop.shopLatitude,
      shop.shopLongitude,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C34) : Colors.black87,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            if (shop.shopContactPhone?.isNotEmpty ?? false)
              _buildPillIconButton(
                context,
                icon: Icons.call_rounded,
                color: Colors.white,
                onTap: () => launchCaller(shop.shopContactPhone!, context),
              ),
            if (shop.whatsappNumber?.isNotEmpty ?? false)
              _buildPillIconButton(
                context,
                icon: Icons.chat_rounded,
                color: Colors.white,
                onTap: () => launchWhatsApp(shop.whatsappNumber!, context),
              ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: isLocationValid
                    ? () => _launchMap(
                        shop.shopLatitude!,
                        shop.shopLongitude!,
                        shop.shopName ?? 'Shop',
                      )
                    : () {
                        AppAlerts.showError(
                          context,
                          'Directions map is not available for this shop.',
                        );
                      },
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: isLocationValid
                        ? theme.colorScheme.primary
                        : theme.disabledColor,
                    borderRadius: BorderRadius.circular(27),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.directions_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Directions',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildPillIconButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: IconButton(
        onPressed: onTap,
        icon: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3)),
            color: color.withValues(alpha: 0.1),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  Future<void> _launchMap(double lat, double lon, String title) async {
    final url = Uri.parse('google.navigation:q=$lat,$lon');
    final fallbackUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else if (await canLaunchUrl(fallbackUrl)) {
      await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
    }
  }

  void _showSafetyMenu(BuildContext context, Shop shop) {
    AppBottomSheet.showBottomSheet(
      context: context,
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: Colors.orange),
              title: const Text('Report Shop'),
              subtitle: const Text('Report inappropriate content or behavior'),
              onTap: () {
                AppNavigator.pop(context);
                AppBottomSheet.showBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  child: SafetyReportBottomSheet(
                    targetId: shop.id ?? '',
                    targetType: ReportTargetType.shop,
                    targetName: shop.shopName ?? 'Shop',
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_flipped, color: Colors.red),
              title: const Text('Block Shop'),
              subtitle: Text(
                'Stop seeing content from ${shop.shopName ?? 'Shop'}',
              ),
              onTap: () async {
                AppNavigator.pop(context);
                if (shop.id == null) return;
                final result = await SafetyServices().blockShop(
                  blockedShopId: shop.id!,
                );
                if (context.mounted) {
                  if (result.success == true) {
                    AppAlerts.showSuccess(
                      context,
                      '${shop.shopName ?? 'Shop'} has been blocked.',
                    );
                    AppNavigator.pop(context);
                  } else {
                    AppAlerts.showError(
                      context,
                      result.message ?? 'Failed to block shop',
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopProductCard extends StatelessWidget {
  final Product item;
  final String shopName;

  const _ShopProductCard({required this.item, required this.shopName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return VisibilityDetector(
      key: Key('item-shop-details-${item.id}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.5) {
          context.read<ShopDetailCubit>().trackImpression(item.id);
        }
      },
      child: GestureDetector(
        onTap: () {
          AppNavigator.push(context, ProductDetailScreen(product: item));
        },
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: isDark ? 0.1 : 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorWidget: (context, error, stackTrace) => ColoredBox(
                      color: ColorName.primary.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: ColorName.primary,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      shopName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        fontSize: 9,
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PKR ${item.price.toStringAsFixed(0)}',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (item.discount != null && item.discount! > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '-${item.discount}%',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }
}
