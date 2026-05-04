import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearvendorapp/views/widgets/animated_error_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearvendorapp/cubits/explore_item_detail/explore_item_detail_cubit.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart';
import 'package:nearvendorapp/models/ui_models/shop_model.dart' as ui;
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/home/cubit/shop_details_cubit.dart';
import 'package:nearvendorapp/views/screens/home/widgets/shop_location_widget.dart';
import 'package:nearvendorapp/views/screens/search/view/explore_item_detail_screen.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nearvendorapp/views/widgets/app_loading_indicator.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:nearvendorapp/views/widgets/safety_report_dialog.dart';
import 'package:nearvendorapp/services/safety_services.dart';
import 'package:nearvendorapp/utils/app_alerts.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';
import 'package:nearvendorapp/views/screens/auth/views/login_screen.dart';

class CustomerShopDetailsScreen extends StatelessWidget {
  final ui.ShopModel shop;

  const CustomerShopDetailsScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final shopId = shop.id;
        return ShopDetailsCubit()..loadShopData(shopId);
      },
      child: AppScaffold(
        bgColor: Theme.of(context).scaffoldBackgroundColor,
        body: BlocBuilder<ShopDetailsCubit, ShopDetailsState>(
          builder: (context, state) {
            if (state is ShopDetailsLoading) {
              return const AppLoadingIndicator();
            }

            if (state is ShopDetailsFailure) {
              return AnimatedErrorState(
                message: state.message,
                onRetry: () =>
                    context.read<ShopDetailsCubit>().loadShopData(shop.id),
              );
            }

            if (state is ShopDetailsSuccess) {
              final fullShop = state.shop;
              final inventory = state.inventory;

              return Stack(
                children: [
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderImage(context, fullShop),
                        _buildSellerCard(context, fullShop),
                        SizedBox(
                          height: AppSpacing.mediumVerticalSpacing(context),
                        ),
                        _buildMapSection(context, fullShop),
                        SizedBox(
                          height: AppSpacing.mediumVerticalSpacing(context),
                        ),
                        _buildShopAds(context, fullShop, inventory),
                      ],
                    ),
                  ),
                  _buildFloatingActionPill(context, fullShop),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildMapSection(BuildContext context, Shop fullShop) {
    final theme = Theme.of(context);
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
          SizedBox(height: AppSpacing.smallVerticalSpacing(context)),
          FutureBuilder<Position?>(
            future: Geolocator.getLastKnownPosition(),
            builder: (context, snapshot) {
              final userPos = snapshot.data;
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
                  shopName: fullShop.shopName,
                  shopAddress: fullShop.shopAddress,
                  latitude: fullShop.shopLatitude,
                  longitude: fullShop.shopLongitude,
                  userLatitude: userPos?.latitude,
                  userLongitude: userPos?.longitude,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage(BuildContext context, Shop fullShop) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        SizedBox(
          height: AppSpacing.screenHeight(context) * 0.35,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: fullShop.coverImageUrl ?? shop.image,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: theme.dividerColor.withValues(alpha: 0.1),
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, error, stackTrace) => Container(
              color: theme.dividerColor.withValues(alpha: 0.1),
              child: const Icon(Icons.store, size: 50),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleNavButton(
                  context,
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                Row(
                  children: [
                    _buildCircleNavButton(
                      context,
                      icon: Icons.more_horiz_rounded,
                      onTap: () {
                        final session = context.read<SessionCubit>().state;
                        if (session.status != AuthStatus.authenticated) {
                          AppBottomSheet.showConfirmationBottomSheet(
                            context: context,
                            title: 'Sign In Required',
                            message:
                                'You need to sign in to report content or block vendors.',
                            confirmButtonText: 'Sign In',
                            onConfirm: () {
                              Navigator.pop(context);
                              AppNavigator.push(context, const LoginScreen());
                            },
                          );
                          return;
                        }
                        _showSafetyMenu(context, fullShop);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircleNavButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isDark ? Colors.black : Colors.white).withValues(
                alpha: 0.5,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.2),
              ),
            ),
            child: Icon(
              icon,
              color: isDark ? Colors.white : Colors.black87,
              size: 20,
            ),
          ),
        ),
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
                      fullShop.shopName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                      ),
                    ),
                    Text(
                      fullShop.businessCategory,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
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
                backgroundImage: CachedNetworkImageProvider(
                  fullShop.storeLogoUrl ??
                      'https://i.pravatar.cc/150?u=a042581f4e29026704d',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopAds(
    BuildContext context,
    Shop fullShop,
    List<Item> inventory,
  ) {
    final theme = Theme.of(context);
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
          if (inventory.isEmpty)
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
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.82,
              ),
              itemCount: inventory.length,
              itemBuilder: (context, index) {
                return ItemCard(
                  item: inventory[index],
                  shopName: fullShop.shopName,
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

    return Positioned(
      bottom: 30,
      left: 24,
      right: 24,
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
            _buildPillIconButton(
              context,
              icon: Icons.call_rounded,
              color: Colors.white,
              onTap: () => _launchCaller(shop.shopContactPhone),
            ),
            _buildPillIconButton(
              context,
              icon: Icons.chat_rounded,
              color: Colors.white,
              onTap: () => _launchWhatsApp(shop.whatsappNumber),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => _launchMap(
                  shop.shopLatitude,
                  shop.shopLongitude,
                  shop.shopName,
                ),
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(27),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.directions_rounded,
                        color: Colors.black,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Directions',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.black,
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
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
            color: color.withValues(alpha: 0.1),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  Future<void> _launchCaller(String phone) async {
    final Uri url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final whatsappUrl = Uri.parse("https://wa.me/$phone");
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    }
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: Colors.orange),
              title: const Text('Report Shop'),
              subtitle: const Text('Report inappropriate content or behavior'),
              onTap: () {
                Navigator.pop(ctx);
                showDialog(
                  context: context,
                  builder: (dialogCtx) => SafetyReportDialog(
                    targetId: shop.id,
                    targetType: 'SHOP',
                    targetName: shop.shopName,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_flipped, color: Colors.red),
              title: const Text('Block Vendor'),
              subtitle: Text('Stop seeing content from ${shop.shopName}'),
              onTap: () async {
                Navigator.pop(ctx);
                final result = await SafetyServices().blockUser(
                  blockedId: shop.vendorId,
                );
                if (context.mounted) {
                  if (result.success == true) {
                    AppAlerts.showSuccessSnackBar(
                      context,
                      '${shop.shopName} has been blocked.',
                    );
                    Navigator.pop(
                      context,
                    ); // Go back as user shouldn't see this shop anymore
                  } else {
                    AppAlerts.showErrorSnackBar(
                      context,
                      result.message ?? 'Failed to block user',
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final Item item;
  final String shopName;

  const ItemCard({super.key, required this.item, required this.shopName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return VisibilityDetector(
      key: Key('item-shop-details-${item.id}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.5) {
          context.read<ShopDetailsCubit>().trackImpression(item.id);
        }
      },
      child: GestureDetector(
        onTap: () {
          AppNavigator.push(
            context,
            BlocProvider(
              create: (context) => ExploreItemDetailCubit(),
              child: ExploreItemDetailScreen(itemId: item.id),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: isDark ? 0.1 : 0.05),
              width: 1,
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
                    errorWidget: (context, error, stackTrace) => Container(
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
