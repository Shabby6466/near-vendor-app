import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/enums/auth_status.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/models/data_models/opening_hours.dart';
import 'package:nearvendorapp/models/data_models/product_model.dart';
import 'package:nearvendorapp/models/data_models/shop.dart';
import 'package:nearvendorapp/utils/helper_functions.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/views/screens/auth/view/login_screen.dart';
import 'package:nearvendorapp/views/screens/product_detail_screen/cubit/product_detail_cubit.dart';
import 'package:nearvendorapp/views/screens/shop_detail_screen/view/shop_detail_screen.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';
import 'package:nearvendorapp/views/widgets/app_loading_indicator.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';
import 'package:nearvendorapp/views/widgets/safety_report_dialog.dart';
import 'package:nearvendorapp/views/widgets/shop_timing_view.dart';

class ProductDetailScreen extends StatelessWidget {
  final String? productId;
  final Product? product;

  const ProductDetailScreen({super.key, this.productId, this.product});

  String get _effectiveItemId => productId ?? product?.id ?? '';

  bool _shouldPreventLoading(Product? prod) {
    if (prod == null) return false;
    final hasProductInfo = prod.id.isNotEmpty && prod.name.isNotEmpty;
    final shopMap = prod.shop;
    final hasShopInfo =
        shopMap != null &&
        (shopMap['id']?.toString().isNotEmpty ?? false) &&
        (shopMap['shopName']?.toString().isNotEmpty ?? false);

    return hasProductInfo && hasShopInfo;
  }

  void _handleReport(BuildContext context) {
    final state = context.read<ProductDetailCubit>().state;
    if (state is! ProductDetailSuccess) return;

    final item = state.item;
    final session = context.read<SessionCubit>().state;
    if (session.status != AuthStatus.authenticated) {
      AppBottomSheet.showConfirmationBottomSheet(
        context: context,
        title: 'Sign In Required',
        message: 'You need to sign in to report items.',
        confirmButtonText: 'Sign In',
        onConfirm: () {
          Navigator.pop(context);
          AppNavigator.push(context, const LoginScreen());
        },
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => SafetyReportDialog(
        targetId: item.id,
        targetType: 'ITEM',
        targetName: item.name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductDetailCubit>(
      create: (context) {
        final cubit = ProductDetailCubit(initialProduct: product);
        if (!_shouldPreventLoading(product)) {
          cubit.fetchDetails(_effectiveItemId);
        }
        return cubit;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
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
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Builder(
                  builder: (context) {
                    return IconButton(
                      icon: const Icon(
                        Icons.flag_outlined,
                        color: ColorName.secondary,
                        size: 20,
                      ),
                      onPressed: () => _handleReport(context),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<ProductDetailCubit, ProductDetailState>(
          builder: (context, state) {
            if (state is ProductDetailLoading) {
              return const AppLoadingIndicator();
            }
            if (state is ProductDetailSuccess) {
              return _buildMainContent(context, state.item, state.shop);
            }
            if (state is ProductDetailFailure) {
              return _buildError(context, state.message);
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton:
            BlocBuilder<ProductDetailCubit, ProductDetailState>(
              builder: (context, state) {
                if (state is ProductDetailSuccess) {
                  return _buildFloatingActionPill(context, state.shop);
                }
                return const SizedBox.shrink();
              },
            ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, Product item, Shop? shop) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final images = item.imageUrls.isNotEmpty
        ? item.imageUrls
        : (item.imageUrl != null ? [item.imageUrl!] : <String>[]);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image Header (Carousel)
          _ProductImageCarousel(
            imageUrls: images,
            itemId: item.id,
            height: size.height * 0.55,
          ),

          // Product Info Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            shop?.businessCategory ?? '',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 16,
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildDistanceBadge(context, shop),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'PKR ${item.price.toStringAsFixed(0)}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 24),

                // Description
                Text(
                  'Description',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.description.isNotEmpty
                      ? item.description
                      : 'Explore this amazing product at ${shop?.shopName ?? ''}.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    height: 1.6,
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                // Vendor Info Card (with collapsible timing)
                _buildVendorMiniCard(context, shop),

                const SizedBox(height: 180), // Bottom padding for floating FAB
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionPill(BuildContext context, Shop? shop) {
    if (shop == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SafeArea(
        top: false,
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
              if (shop.shopLatitude != null &&
                  shop.shopLongitude != null &&
                  shop.shopName != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => launchMap(
                      shop.shopLatitude!,
                      shop.shopLongitude!,
                      shop.shopName!,
                      context,
                    ),
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
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
            ],
          ),
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

  Widget _buildVendorMiniCard(BuildContext context, Shop? shop) {
    if (shop == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final openingHours = shop.openingHours != null
        ? ShopOpeningHours.fromJson(shop.openingHours)
        : const ShopOpeningHours();

    final statusInfo = openingHours.getStatusInfo();

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C23) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: ExpansionTile(
            iconColor: isDark ? Colors.white70 : Colors.black54,
            collapsedIconColor: isDark ? Colors.white70 : Colors.black54,
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: GestureDetector(
              onTap: () {
                AppNavigator.push(context, ShopDetailScreen(shop: shop));
              },
              child: CircleAvatar(
                radius: 24,
                backgroundImage:
                    shop.storeLogoUrl != null && shop.storeLogoUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(shop.storeLogoUrl!)
                    : null,
                child: shop.storeLogoUrl == null || shop.storeLogoUrl!.isEmpty
                    ? const Icon(Icons.storefront_rounded)
                    : null,
              ),
            ),
            title: GestureDetector(
              onTap: () {
                AppNavigator.push(context, ShopDetailScreen(shop: shop));
              },
              child: Text(
                shop.shopName ?? 'Unknown Shop',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    statusInfo.statusText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusInfo.statusColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      statusInfo.timeDetails,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  bottom: 20.0,
                ),
                child: ShopTimingView(openingHours: openingHours),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceBadge(BuildContext context, Shop? shop) {
    if (shop == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return FutureBuilder<Object?>(
      future: Geolocator.getLastKnownPosition(),
      builder: (context, snapshot) {
        final positionData = snapshot.data as Position?;
        String distanceText = '---';
        if (snapshot.hasData &&
            positionData != null &&
            shop.shopLatitude != null &&
            shop.shopLongitude != null) {
          final distance = Geolocator.distanceBetween(
            positionData.latitude,
            positionData.longitude,
            shop.shopLatitude!,
            shop.shopLongitude!,
          );
          if (distance < 1000) {
            distanceText = '${distance.toStringAsFixed(0)}m';
          } else {
            distanceText = '${(distance / 1000).toStringAsFixed(1)}km';
          }
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: theme.primaryColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 12,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                distanceText,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final isThrottlerError =
        message.toLowerCase().contains('throttler') ||
        message.toLowerCase().contains('too many requests') ||
        message.toLowerCase().contains('throttle');

    final isInternetError =
        message.toLowerCase().contains('internet') ||
        message.toLowerCase().contains('socketexception') ||
        message.toLowerCase().contains('connection refused') ||
        message.toLowerCase().contains('connection error');

    final IconData errorIcon = isThrottlerError
        ? Icons.error_outline_rounded
        : (isInternetError
              ? Icons.wifi_off_rounded
              : Icons.error_outline_rounded);

    final Color errorColor = isThrottlerError
        ? Theme.of(context).primaryColor
        : Colors.red;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(errorIcon, size: 64, color: errorColor),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: errorColor),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<ProductDetailCubit>().fetchDetails(
              _effectiveItemId,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class _ProductImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final String itemId;
  final double height;

  const _ProductImageCarousel({
    required this.imageUrls,
    required this.itemId,
    required this.height,
  });

  @override
  State<_ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<_ProductImageCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Container(
          height: widget.height,
          width: double.infinity,
          color: theme.primaryColor.withValues(alpha: 0.05),
          child: widget.imageUrls.isNotEmpty
              ? PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: widget.imageUrls.length,
                  itemBuilder: (context, index) {
                    final content = CachedNetworkImage(
                      imageUrl: widget.imageUrls[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => ColoredBox(
                        color: theme.primaryColor.withValues(alpha: 0.05),
                        child: const LoadingAnimation(size: 16),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.image_not_supported_rounded,
                        size: 50,
                        color: theme.primaryColor.withValues(alpha: 0.2),
                      ),
                    );

                    return index == 0
                        ? Hero(tag: 'item_img_${widget.itemId}', child: content)
                        : content;
                  },
                )
              : Center(
                  child: Icon(
                    Icons.inventory_2_rounded,
                    size: 100,
                    color: theme.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
        ),

        // Carousel Indicators (Pill Style)
        if (widget.imageUrls.length > 1)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      widget.imageUrls.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentPage == index ? 12 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? theme.primaryColor
                              : Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Image Index Bubble (e.g., 1/5)
        if (widget.imageUrls.length > 1)
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Text(
                    '${_currentPage + 1}/${widget.imageUrls.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Bottom Gradient Fade
        Positioned(
          bottom: -2, // Slight overlap to prevent seam
          left: 0,
          right: 0,
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.scaffoldBackgroundColor.withValues(alpha: 0),
                  theme.scaffoldBackgroundColor,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
