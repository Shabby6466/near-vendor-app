import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearvendorapp/cubits/explore_item_detail/explore_item_detail_cubit.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart';
import 'package:nearvendorapp/models/ui_models/shop_model.dart' as ui;
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/home/cubit/shop_details_cubit.dart';
import 'package:nearvendorapp/views/screens/home/widgets/shop_location_widget.dart';
import 'package:nearvendorapp/views/screens/search/view/explore_item_detail_screen.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ShopDetailsScreen extends StatelessWidget {
  final ui.ShopModel shop;

  const ShopDetailsScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        // Defensive check for potential null id issues during development/hot-reload
        final shopId = shop.id;
        return ShopDetailsCubit()..loadShopData(shopId);
      },
      child: AppScaffold(
        bgColor: Colors.white,
        body: BlocBuilder<ShopDetailsCubit, ShopDetailsState>(
          builder: (context, state) {
            if (state is ShopDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ShopDetailsFailure) {
              return Center(child: Text('Error: ${state.message}'));
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
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.mediumHorizontalSpacing(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shop Location',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
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
    return Stack(
      children: [
        SizedBox(
          height: AppSpacing.screenHeight(context) * 0.35,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: fullShop.coverImageUrl ?? shop.image,
            fit: BoxFit.cover,
            errorWidget: (context, error, stackTrace) => Container(
              color: Colors.grey.shade300,
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
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: ColorName.primary,
                      size: 20,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star_border,
                        color: ColorName.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.ios_share,
                        color: ColorName.primary,
                        size: 24,
                      ),
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

  Widget _buildSellerCard(BuildContext context, Shop fullShop) {
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
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      fullShop.businessCategory,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (fullShop.isVerifiedBadge ?? false)
                const Icon(Icons.verified, color: Colors.blue, size: 20),
            ],
          ),
          Positioned(
            left: 0,
            top: -50,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: CircleAvatar(
                radius: 45,
                backgroundImage: NetworkImage(
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
              const Text(
                'Shop Inventory',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                '${inventory.length} items',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
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
    return Positioned(
      bottom: 30,
      left: 24,
      right: 24,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.9),
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
            _buildActionIcon(
              Icons.call_rounded,
              Colors.blue,
              () => _launchCaller(shop.shopContactPhone),
            ),
            const SizedBox(width: 8),
            _buildActionIcon(
              Icons.chat_rounded,
              Colors.green,
              () => _launchWhatsApp(shop.whatsappNumber),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _launchMap(
                  shop.shopLatitude,
                  shop.shopLongitude,
                  shop.shopName,
                ),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB300),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_rounded,
                        color: Colors.black,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Directions',
                        style: TextStyle(
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
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Icon(icon, color: color, size: 22),
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
}

class ItemCard extends StatelessWidget {
  final Item item;
  final String shopName;

  const ItemCard({super.key, required this.item, required this.shopName});

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('item-shop-details-${item.id}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.5) {
          context.read<ShopDetailsCubit>().trackImpression(item.id);
        }
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => ExploreItemDetailCubit(),
                child: ExploreItemDetailScreen(itemId: item.id),
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
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
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      shopName,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.price} PKR',
                          style: const TextStyle(
                            color: ColorName.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (item.discount != null)
                          Text(
                            '-${item.discount}%',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
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
