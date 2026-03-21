import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/models/ui_models/shop_model.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/home/view/shop_details_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ShopModel shop;

  const ProductDetailsScreen({super.key, required this.shop});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopImageSection(context),
            SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
            _buildDetailsSection(context),
            SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
            _buildLocationSection(context),
            SizedBox(height: AppSpacing.mediumVerticalSpacing(context) * 2),
            Center(
              child: Text(
                'NearVendor',
                style: TextStyle(
                  color: ColorName.primary,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.mediumVerticalSpacing(context) * 2),
          ],
        ),
      ),
    );
  }

  Widget _buildTopImageSection(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: AppSpacing.screenHeight(context) * 0.45,
          color: Colors.grey.shade200,
          child: Image.network(
            widget.shop.image,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.mediumHorizontalSpacing(context),
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
                      color: ColorName.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isLiked = !_isLiked;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: _isLiked ? Colors.red : Colors.black26,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShopDetailsScreen(shop: widget.shop),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.store, color: Colors.black26, size: 24),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Text(
              '92,000 PKR',
              style: TextStyle(
                color: ColorName.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.mediumHorizontalSpacing(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ad Posted At: 10:35 pm - 14/08/2025',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  for (int i = 0; i < 5; i++)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == 0 ? ColorName.primary : Colors.grey.shade400,
                      ),
                    ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.smallVerticalSpacing(context)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.shop.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.ios_share, color: ColorName.primary, size: 28),
            ],
          ),
          SizedBox(height: AppSpacing.smallVerticalSpacing(context)),
          const Text(
            '#8 x 2 1/2 Inch Stainless Steel Wood Screw, 200 Count\n#8 x 2 1/2 Inch Stainless Steel Wood Screw, 200 Count',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.mediumHorizontalSpacing(context)),
          child: Row(
            children: [
              const Text(
                'Shop Location',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '5 KMs Away',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.mediumHorizontalSpacing(context)),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: ColorName.primary, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: FlutterMap(
                    options: const MapOptions(
                      initialCenter: LatLng(33.6844, 73.0479), // Islamabad example coordinate
                      initialZoom: 13.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.nearvendorapp.app',
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                left: 16,
                right: 16,
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'), // Fallback avatar
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Rana Faraz Asad',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'i10 khokha',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFF004AAD), // Dark Blue for whatsapp/chat
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.message, color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse('tel:+1234567890')),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFFADFF2F), // Green yellow
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.phone, color: Colors.black, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
