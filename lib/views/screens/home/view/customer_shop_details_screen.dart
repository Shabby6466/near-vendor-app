import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nearvendorapp/models/data_models/shop.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';

class CustomerShopDetailsScreen extends StatelessWidget {
  final Shop shop;

  const CustomerShopDetailsScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(shop.shopName ?? 'Shop Details')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Logo
            Center(
              child: shop.storeLogoUrl != null && shop.storeLogoUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: shop.storeLogoUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Icon(
                      Icons.storefront_rounded,
                      size: 100,
                      color: theme.primaryColor,
                    ),
            ),
            const SizedBox(height: 16),
            // Shop Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                shop.shopName ?? 'Unknown Shop',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Shop Address
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                shop.shopAddress ?? 'Address not available',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            // Contact Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone, color: theme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        shop.shopContactPhone ?? 'No phone number',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.chat, color: theme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        shop.whatsappNumber ?? 'No WhatsApp',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  AppElevatedButton(
                    text: 'Call Shop',
                    onPressed: () {
                      // Implement call functionality
                    },
                  ),
                  const SizedBox(height: 8),
                  AppElevatedButton(
                    text: 'Message on WhatsApp',
                    onPressed: () {
                      // Implement WhatsApp message
                    },
                  ),
                  const SizedBox(height: 8),
                  AppElevatedButton(
                    text: 'Get Directions',
                    onPressed: () {
                      // Implement directions
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
