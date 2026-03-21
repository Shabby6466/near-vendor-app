import 'package:flutter/material.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/home/widgets/custom_bottom_bar.dart';
import 'package:nearvendorapp/views/screens/search/view/visual_search_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Camera Search', 'Audio Search'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background UI / Watermark
          Positioned(
            bottom: 0,
            right: 0,
            child: Opacity(
              opacity: 0.45,
              child: Image.asset(Assets.images.nearVendorRightCut.path),
            ),
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
                _buildSearchBar(context),
                SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
                _buildFilterChips(context),
                SizedBox(height: AppSpacing.largeVerticalSpacing(context)),
                _buildRecentSearchHeader(),
                SizedBox(height: AppSpacing.smallVerticalSpacing(context)),
                _buildRecentSearchList(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 0,
        onTap: (index) {},
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.mediumHorizontalSpacing(context), vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              // Usually a bottom sheet for location
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Current Location',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                  ],
                ),
                const Text(
                  'NYC, USA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorName.primary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.greenAccent.shade100.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_border, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.mediumHorizontalSpacing(context)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search Item',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: const Icon(Icons.search, color: Colors.black),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const VisualSearchScreen()),
                    );
                  },
                  child: const Icon(Icons.camera_alt_outlined, color: Colors.black54),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.mic_none, color: Colors.black54),
                const SizedBox(width: 16),
              ],
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.mediumHorizontalSpacing(context)),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          IconData? icon;
          if (filter == 'Camera Search') icon = Icons.camera_enhance_outlined;
          if (filter == 'Audio Search') icon = Icons.mic_none_outlined;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                if (filter == 'Camera Search') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const VisualSearchScreen()),
                  );
                } else {
                  setState(() {
                    selectedFilter = filter;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? ColorName.primary : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? ColorName.primary : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.black87),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentSearchHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.mediumHorizontalSpacing(context)),
      child: const Text(
        'Recent Search',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: ColorName.primary,
        ),
      ),
    );
  }

  Widget _buildRecentSearchList() {
    return SizedBox(
      height: 250,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.mediumHorizontalSpacing(context)),
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final title = index == 0 ? 'MasleDar Fries' : 'WJNC #9 : Gator';
          final imageUrl = index == 0
              ? 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=400'
              : 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&q=80&w=400';
          return SizedBox(
            width: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      imageUrl,
                      // Placeholder reference image
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(child: Icon(Icons.map, size: 40, color: Colors.grey)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorName.primary,
                  ),
                ),
                Text(
                  'NYC, USA',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
