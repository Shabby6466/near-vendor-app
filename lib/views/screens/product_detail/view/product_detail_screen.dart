import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/enums/auth_status.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';
import 'package:nearvendorapp/models/data_models/shop.dart';
import 'package:nearvendorapp/views/screens/home/view/customer_shop_details_screen.dart';
import 'package:nearvendorapp/utils/helper_functions.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/views/screens/auth/view/login_screen.dart';
import 'package:nearvendorapp/views/screens/product_detail/cubit/product_detail_cubit.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';
import 'package:nearvendorapp/views/widgets/app_loading_indicator.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';
import 'package:nearvendorapp/views/widgets/safety_report_dialog.dart';

class ProductDetailScreen extends StatefulWidget {
  final String itemId;

  const ProductDetailScreen({super.key, required this.itemId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    context.read<ProductDetailCubit>().fetchDetails(widget.itemId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }

  Widget _buildMainContent(BuildContext context, Item item, Shop? shop) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final images = item.imageUrls.isNotEmpty
        ? item.imageUrls
        : (item.imageUrl != null ? [item.imageUrl!] : <String>[]);

    return Stack(
      children: [
        // 1. Scrollable Content
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Header (Carousel)
              Stack(
                children: [
                  Container(
                    height:
                        size.height * 0.55, // Slightly taller for better impact
                    width: double.infinity,
                    color: theme.primaryColor.withValues(alpha: 0.05),
                    child: images.isNotEmpty
                        ? PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              final content = CachedNetworkImage(
                                imageUrl: images[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                placeholder: (context, url) => ColoredBox(
                                  color: theme.primaryColor.withValues(
                                    alpha: 0.05,
                                  ),
                                  child: const LoadingAnimation(size: 16),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.image_not_supported_rounded,
                                  size: 50,
                                  color: theme.primaryColor.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              );

                              // Only apply Hero to the first image to match the incoming transition
                              return index == 0
                                  ? Hero(
                                      tag: 'item_img_${item.id}',
                                      child: content,
                                    )
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
                  if (images.length > 1)
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
                                images.length,
                                (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
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
                  if (images.length > 1)
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
                              '${_currentPage + 1}/${images.length}',
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
                    // Vendor Info Small Card
                    _buildVendorMiniCard(context, shop),

                    const SizedBox(
                      height: 120,
                    ), // Bottom padding for floating bar
                  ],
                ),
              ),
            ],
          ),
        ),

        // 2. Custom App Bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 10,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.black,
                        size: 18,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(
                        Icons.flag_outlined,
                        color: ColorName.secondary,
                        size: 20,
                      ),
                      onPressed: () {
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
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 3. Floating Bottom Action Pill
        Positioned(
          bottom: 30,
          left: 24,
          right: 24,
          child: _buildFloatingActionPill(context, shop),
        ),
      ],
    );
  }

  Widget _buildFloatingActionPill(BuildContext context, Shop? shop) {
    if (shop == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
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
                // Left Side: Call & WhatsApp
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
                // Right Side: Directions Button (Full width expansion)
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
              ]
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

  Widget _buildVendorMiniCard(BuildContext context, Shop? shop) {
    if (shop == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        AppNavigator.push(context, CustomerShopDetailsScreen(shop: shop));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C23) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage:
                  shop.storeLogoUrl != null && shop.storeLogoUrl!.isNotEmpty
                  ? CachedNetworkImageProvider(shop.storeLogoUrl!)
                  : null,
              child: shop.storeLogoUrl == null || shop.storeLogoUrl!.isEmpty
                  ? const Icon(Icons.storefront_rounded)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                     shop.shopName ?? 'Unknown Shop',
                     style: theme.textTheme.titleSmall?.copyWith(
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                  Text('Vendor', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceBadge(BuildContext context, Shop? shop) {
    if (shop == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return FutureBuilder<Position?>(
      future: Geolocator.getLastKnownPosition(),
      builder: (context, snapshot) {
         String distanceText = '---';
         if (snapshot.hasData &&
             snapshot.data != null &&
             shop.shopLatitude != null &&
             shop.shopLongitude != null) {
           final distance = Geolocator.distanceBetween(
             snapshot.data!.latitude,
             snapshot.data!.longitude,
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
            onPressed: () =>
                context.read<ProductDetailCubit>().fetchDetails(widget.itemId),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
