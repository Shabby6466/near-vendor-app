import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearvendorapp/cubits/explore_item_detail/explore_item_detail_cubit.dart';
import 'package:nearvendorapp/cubits/explore_item_detail/explore_item_detail_state.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class ExploreItemDetailScreen extends StatefulWidget {
  final String itemId;

  const ExploreItemDetailScreen({super.key, required this.itemId});

  @override
  State<ExploreItemDetailScreen> createState() => _ExploreItemDetailScreenState();
}

class _ExploreItemDetailScreenState extends State<ExploreItemDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ExploreItemDetailCubit>().fetchDetails(widget.itemId);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: BlocBuilder<ExploreItemDetailCubit, ExploreItemDetailState>(
        builder: (context, state) {
          if (state is ExploreItemDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ExploreItemDetailSuccess) {
            return _buildMainContent(context, state.item, state.shop);
          }
          if (state is ExploreItemDetailFailure) {
            return _buildError(context, state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, Item item, Shop shop) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // 1. Scrollable Content
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Header
              Stack(
                children: [
                  Hero(
                    tag: 'item_img_${item.id}',
                    child: Container(
                      height: size.height * 0.5,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.05),
                      ),
                      child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: item.imageUrl!,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.inventory_2_rounded, size: 100, color: theme.primaryColor.withValues(alpha: 0.2)),
                    ),
                  ),
                  // Bottom Gradient Fade
                  Positioned(
                    bottom: 0,
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
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Poppins',
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                shop.businessCategory,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                                  fontFamily: 'Poppins',
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
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: theme.primaryColor,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 24),


                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description.isNotEmpty ? item.description : 'Explore this amazing product at ${shop.shopName}.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    // Vendor Info Small Card
                    _buildVendorMiniCard(context, shop),

                    const SizedBox(height: 120), // Bottom padding for floating bar
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
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 10),
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
            child: Row(
              children: [
                const SizedBox(width: 16),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Product Details',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                // Spacer for centering
                const SizedBox(width: 56),
              ],
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

  Widget _buildFloatingActionPill(BuildContext context, Shop shop) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
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
          // Left Side: Call & WhatsApp
          _buildPillIconButton(
            context,
            icon: Icons.call_rounded,
            color: Colors.blue,
            onTap: () => _launchCaller(shop.shopContactPhone),
          ),
          _buildPillIconButton(
            context,
            icon: Icons.chat_rounded,
            color: Colors.green,
            onTap: () => _launchWhatsApp(shop.whatsappNumber),
          ),
          
          const SizedBox(width: 8),
          
          // Right Side: Directions Button (Full width expansion)
          Expanded(
            child: GestureDetector(
              onTap: () => _launchMap(shop.shopLatitude, shop.shopLongitude, shop.shopName),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB300),
                  borderRadius: BorderRadius.circular(27),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_rounded, color: Colors.black, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Directions',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        fontFamily: 'Poppins',
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
    );
  }

  Widget _buildPillIconButton(BuildContext context, {required IconData icon, required Color color, required VoidCallback onTap}) {
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

  Widget _buildVendorMiniCard(BuildContext context, Shop shop) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
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
            backgroundImage: shop.storeLogoUrl != null && shop.storeLogoUrl!.isNotEmpty
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
                  shop.shopName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Vendor',
                  style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }

  Widget _buildDistanceBadge(BuildContext context, Shop shop) {
    return FutureBuilder<Position?>(
      future: Geolocator.getLastKnownPosition(),
      builder: (context, snapshot) {
        String distanceText = '---';
        if (snapshot.hasData && snapshot.data != null) {
          final distance = Geolocator.distanceBetween(
            snapshot.data!.latitude,
            snapshot.data!.longitude,
            shop.shopLatitude,
            shop.shopLongitude,
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
            color: const Color(0xFFFFB300).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFB300).withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on_rounded, size: 12, color: Color(0xFFFFB300)),
              const SizedBox(width: 4),
              Text(
                distanceText,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFFB300),
                ),
              ),
            ],
          ),
        );
      },
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
    final fallbackUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else if (await canLaunchUrl(fallbackUrl)) {
      await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<ExploreItemDetailCubit>().fetchDetails(widget.itemId),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
