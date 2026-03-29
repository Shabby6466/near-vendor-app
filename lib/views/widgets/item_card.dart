import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/explore_item_detail/explore_item_detail_cubit.dart';
import 'package:nearvendorapp/cubits/search/search_cubit.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';
import 'package:nearvendorapp/views/screens/home/cubit/home_screen_cubit.dart';
import 'package:nearvendorapp/views/screens/home/cubit/shop_details_cubit.dart';
import 'package:nearvendorapp/views/screens/search/view/explore_item_detail_screen.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final double? width;
  final double? height;

  const ItemCard({
    super.key,
    required this.item,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return VisibilityDetector(
      key: Key('item-${item.id}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.5) {
          // Try to find a cubit that has AnalyticsMixin
          try {
            context.read<SearchCubit>().trackImpression(item.id);
          } catch (_) {
            try {
              context.read<HomeScreenCubit>().trackImpression(item.id);
            } catch (_) {
              try {
                context.read<ShopDetailsCubit>().trackImpression(item.id);
              } catch (_) {
                // No compatible cubit found
              }
            }
          }
        }
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => ExploreItemDetailCubit(),
                child: ExploreItemDetailScreen(
                  itemId: item.id,
                ),
              ),
            ),
          );
        },
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
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
                child: Hero(
                  tag: 'item_img_${item.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: item.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorWidget: (context, url, error) => Container(
                              color: theme.dividerColor.withValues(alpha: 0.1),
                              child: const Center(child: Icon(Icons.image_not_supported)),
                            ),
                          )
                        : Container(
                            color: theme.dividerColor.withValues(alpha: 0.1),
                            child: const Center(child: Icon(Icons.image_not_supported)),
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PKR ${item.price.toStringAsFixed(0)} / ${item.unit}',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
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
