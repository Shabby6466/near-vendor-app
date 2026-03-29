import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/explore_item_detail/explore_item_detail_cubit.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/views/screens/search/view/explore_item_detail_screen.dart';

class VendorListOverlay extends StatelessWidget {
  final List<Item> searchResults;

  const VendorListOverlay({super.key, required this.searchResults});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.15,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Shops Nearby (${searchResults.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    TextButton(
                      onPressed: () {}, // Optional: Sort logic
                      child: Text(
                        'Sort',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  itemCount: searchResults.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = searchResults[index];
                    final distanceKm = ((item.distanceM ?? 0) / 1000)
                        .toStringAsFixed(1);
                    final shopName = item.shop?['name'] ?? 'Vendor Shop';
                    final shopRating =
                        item.shop?['rating']?.toString() ?? '4.8';

                    return InkWell(
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.grey[200]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey[900]
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                image: item.imageUrl != null
                                    ? DecorationImage(
                                        image: CachedNetworkImageProvider(
                                          item.imageUrl!,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: item.imageUrl == null
                                  ? const Icon(
                                      Icons.storefront,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    shopName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  Text(
                                    'RS ${item.price.toStringAsFixed(0)} • $distanceKm km away',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 14,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        shopRating,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1EC091),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.call,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
