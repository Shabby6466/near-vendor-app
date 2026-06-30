import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/data_models/product_model.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/views/screens/product_detail_screen/cubit/product_detail_cubit.dart';
import 'package:nearvendorapp/views/screens/product_detail_screen/view/product_detail_screen.dart';
import 'package:nearvendorapp/views/screens/search/search_screen/cubit/search_cubit.dart';

class RecentItemsSection extends StatelessWidget {
  const RecentItemsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SearchCubit, SearchState>(
      buildWhen: (previous, current) => current is SearchInitial,
      builder: (context, state) {
        if (state is! SearchInitial || state.recentProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        final recentItems = state.recentProducts;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Recent searches',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LAST SEEN',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: theme.primaryColor.withValues(alpha: 0.6),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: recentItems.length,
                separatorBuilder: (context, index) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  return _MemoryCard(product: recentItems[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final Product product;
  const _MemoryCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        AppNavigator.push(
          context,
          BlocProvider(
            create: (context) => ProductDetailCubit(),
            child: ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.shade100,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: 'item_img_${product.id}_memory',
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl ?? '',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => ColoredBox(
                        color: isDark ? Colors.black26 : Colors.grey.shade50,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                          size: 24,
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
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.white,
                            size: 10,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${product.stockCount} left',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 13,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rs. ${product.price.toStringAsFixed(0)}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 12,
                      color: theme.primaryColor,
                    ),
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
