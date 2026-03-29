import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/widgets/app_text_field.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  String selectedFilter = 'Distance';
  final List<String> filters = ['Distance', 'Rating', 'Price'];
  bool isProductFound = true; // Toggle for demo purposes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Background
          Positioned.fill(
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(
                  33.6844,
                  73.0479,
                ), // Islamabad coordinates
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.nearvendorapp.app',
                ),
                if (!isProductFound)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: const LatLng(33.6844, 73.0479),
                        radius: 1200,
                        useRadiusInMeter: true,
                        color: Colors.blue.withValues(alpha: 0.15),
                        borderColor: Colors.blue.withValues(alpha: 0.7),
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Top Branding and Search Bar
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => setState(() => isProductFound = !isProductFound),
                  child: Assets.icons.nearVendorBlueText.svg(height: 32),
                ),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 12),
                _buildRadiusBadge(),
              ],
            ),
          ),

          // Bottom Sheet for Results
          _buildResultsSheet(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.mediumHorizontalSpacing(context),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AppTextField(
          prefixIcon: const Icon(Icons.search, color: Colors.black54),
          hint: 'Jimmy ke jootay',
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.camera_enhance_outlined, color: Colors.black54),
              const SizedBox(width: 12),
              const Icon(Icons.mic_none, color: Colors.black54),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadiusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.gps_fixed, size: 16, color: Colors.black54),
          SizedBox(width: 6),
          Text(
            '3km Expanded Radius',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.2,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isProductFound
                          ? 'Colgate (150 ml) - 4 vendors nearby.'
                          : 'Colgate not found nearby ☹️',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (!isProductFound) ...[
                      const SizedBox(height: 8),
                      Text(
                        'But here are similar products available near you:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (isProductFound) ...[
                _buildFilterChips(),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return _buildVendorItem(index == 3);
                    },
                  ),
                ),
              ] else ...[
                _buildSimilarProductsList(),
                const SizedBox(height: 24),
                _buildViewAllButton(),
                const SizedBox(height: 24),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (val) => setState(() => selectedFilter = filter),
              backgroundColor: Colors.grey.shade200,
              selectedColor: const Color(0xFFC6FF00), // Lime green
              checkmarkColor: Colors.black,
              labelStyle: TextStyle(
                color: Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide.none,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVendorItem(bool isHighlighted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: isHighlighted ? const Color(0xFF004AAD) : Colors.grey.shade100,
          width: isHighlighted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: const CachedNetworkImageProvider(
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?fit=crop&q=80&w=200',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      const TextSpan(text: 'Al Fateh Store - '),
                      TextSpan(
                        text: '130 PKR',
                        style: const TextStyle(color: Color(0xFF004AAD)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'In Stock',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ' - 5 KM - 4.5',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFC6FF00), // Lime green
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.call_outlined, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarProductsList() {
    return SizedBox(
      height: 240,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildSimilarProductCard(
            'Signal Strong Teeth',
            '200m away',
            '95% Match',
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS8XfOn5Y_996_Xv1_fD6hO6y18_7vJ9S7JpA&s',
          ),
          const SizedBox(width: 12),
          _buildSimilarProductCard(
            'Sensodyne',
            '450m away',
            '80% Match',
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR_x_v-9p9zBUPz7bY_G5cR8n5nJ5Y-f6Z9lA&s',
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarProductCard(
    String title,
    String distance,
    String match,
    String imageUrl,
  ) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
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
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: match.contains('95')
                          ? const Color(0xFF1EC091)
                          : Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      match,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                distance,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFC6FF00).withValues(alpha: 0.3),
              ),
            ),
            alignment: Alignment.center,
            child: const Text(
              'AVAILABLE',
              style: TextStyle(
                color: Color(0xFF1EC091),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D1B2A),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('View All Nearby Options'),
            SizedBox(width: 12),
            Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ),
    );
  }
}
