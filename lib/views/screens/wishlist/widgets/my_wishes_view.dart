import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/models/data_models/wishlist_model.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/views/screens/search/view/explore_item_detail_screen.dart';
import 'package:nearvendorapp/cubits/explore_item_detail/explore_item_detail_cubit.dart';
import 'package:nearvendorapp/views/screens/wishlist/cubits/user_wishlist_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nearvendorapp/views/screens/wishlist/widgets/create_wish_sheet.dart'; 

class MyWishesView extends StatelessWidget {
  const MyWishesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<UserWishlistCubit, UserWishlistState>(
        builder: (context, state) {
          if (state is UserWishlistInitial || state is UserWishlistLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserWishlistError) {
            return _buildErrorState(context, isDark, state.message);
          }

          if (state is UserWishlistLoaded) {
            if (state.wishlists.isEmpty) {
              return _buildEmptyState(context, isDark);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<UserWishlistCubit>().getMyWishlists(refresh: true);
              },
              child: ListView.separated(
                padding: const EdgeInsets.only(
                    top: 20, left: 16, right: 16, bottom: 100),
                itemCount: state.wishlists.length + (state.hasMore ? 1 : 0),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  if (index == state.wishlists.length) {
                    context.read<UserWishlistCubit>().getMyWishlists();
                    return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2));
                  }

                  final wish = state.wishlists[index];
                  return _WishlistCard(wish: wish, isDark: isDark);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 110.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            CreateWishSheet.show(context, context.read<UserWishlistCubit>());
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Make a Wish',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: ColorName.primary,
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, bool isDark, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<UserWishlistCubit>().getMyWishlists(refresh: true);
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Try Again', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorName.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 80,
            color: ColorName.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No Wishes Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Looking for something specific?\nMake a wish and we will alert local vendors!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final WishlistItem wish;
  final bool isDark;

  const _WishlistCard({required this.wish, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [const Color(0xFF1E242B), const Color(0xFF161C22)] 
              : [Colors.white, const Color(0xFFF9FAFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColorName.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, color: ColorName.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wish.itemName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                      if (wish.description != null && wish.description!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          wish.description!,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF4B5563),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: isDark ? Colors.white54 : Colors.grey.shade500),
                          const SizedBox(width: 6),
                          Text(
                            wish.createdAt != null
                                ? '${wish.createdAt!.day}/${wish.createdAt!.month}/${wish.createdAt!.year}'
                                : 'Requested recently',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 22),
                    splashRadius: 24,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text('Delete Wish'),
                          content: const Text(
                            'Are you sure you want to delete this wish? Local vendors will no longer refer to your request.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                context.read<UserWishlistCubit>().deleteWishlist(wish.id);
                              },
                              child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (wish.matchedItems.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05))),
                color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0xFFF3F4F6).withValues(alpha: 0.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_mall_rounded, color: ColorName.primary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '${wish.matchedItems.length} Match${wish.matchedItems.length > 1 ? 'es' : ''} Found Nearby',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF374151),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 160,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                scrollDirection: Axis.horizontal,
                itemCount: wish.matchedItems.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final item = wish.matchedItems[index];
                  return GestureDetector(
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
                      width: 110,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2D3748) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isDark ? Colors.white10 : Colors.grey.shade200, 
                            width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 3,
                            child: item.imageUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: item.imageUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: isDark ? Colors.black26 : Colors.grey.shade100,
                                    child: const Center(
                                        child: Icon(Icons.image_outlined, color: Colors.grey)),
                                  ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? Colors.white : const Color(0xFF111827),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Rs. ${item.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: ColorName.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05))),
                color: isDark ? Colors.black.withValues(alpha: 0.1) : const Color(0xFFF9FAFB),
              ),
              child: Row(
                children: [
                   SizedBox(
                     height: 16, width: 16, 
                     child: CircularProgressIndicator(strokeWidth: 2, color: ColorName.primary.withValues(alpha: 0.5))
                   ),
                  const SizedBox(width: 12),
                  Text(
                    'Scanning local vendors for this item...',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}
