import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nearvendorapp/enums/wishlist_status.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/models/data_models/product_model.dart';
import 'package:nearvendorapp/models/data_models/wishlist_model.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/views/screens/common/no_internet_screen.dart';
import 'package:nearvendorapp/views/screens/product_detail_screen/cubit/product_detail_cubit.dart';
import 'package:nearvendorapp/views/screens/product_detail_screen/view/product_detail_screen.dart';
import 'package:nearvendorapp/views/screens/wishlist/cubit/user_wishlist_cubit.dart';
import 'package:nearvendorapp/views/widgets/app_animate_list.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class MyWishesView extends StatefulWidget {
  final WishlistStatus filterStatus;
  const MyWishesView({super.key, required this.filterStatus});

  @override
  State<MyWishesView> createState() => _MyWishesViewState();
}

class _MyWishesViewState extends State<MyWishesView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final cubit = context.read<UserWishlistCubit>();
      final state = cubit.state;
      if (state is UserWishlistLoaded &&
          state.hasMore &&
          !state.isFetchingMore) {
        cubit.getMyWishlists();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<UserWishlistCubit, UserWishlistState>(
      builder: (context, state) {
        if (state is UserWishlistInitial || state is UserWishlistLoading) {
          return _buildShimmerLoading(context, isDark);
        }

        if (state is UserWishlistError) {
          final isConnectionError =
              state.message.toLowerCase().contains('socketexception') ||
              state.message.toLowerCase().contains('connection error');

          if (isConnectionError) {
            return NoInternetScreen(
              onRetry: () => context.read<UserWishlistCubit>().getMyWishlists(
                refresh: true,
              ),
            );
          }
          return _buildErrorState(context, isDark, state.message);
        }

        if (state is UserWishlistLoaded) {
          final wishlists = state.wishlists
              .where((w) => w.status == widget.filterStatus)
              .toList();

          if (wishlists.isEmpty) {
            return _buildEmptyState(context, isDark);
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<UserWishlistCubit>().getMyWishlists(refresh: true);
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                if (widget.filterStatus == WishlistStatus.pending)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ColorName.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: ColorName.primary.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: ColorName.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Your wishes are visible to nearby vendors. When they stock a matching item, it appears here automatically.',
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 120,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      ...AppAnimateList.stagger(
                        wishlists
                            .map(
                              (wish) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _WishlistCard(
                                  wish: wish,
                                  isDark: isDark,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      if (state.hasMore)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: LoadingAnimation(size: 16),
                          ),
                        ),
                    ]),
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildShimmerLoading(BuildContext context, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            interval: const Duration(milliseconds: 200),
            color: isDark ? const Color(0xFF2D3748) : Colors.grey[300]!,
            colorOpacity: 0.2,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E242B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
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
              size: 64,
              color: Colors.red.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 20),
            Text(
              'Oops!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<UserWishlistCubit>().getMyWishlists(refresh: true);
              },
              icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
              label: const Text(
                'Try Again',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorName.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.filterStatus == WishlistStatus.fulfilled
                    ? Icons.check_circle_outline_rounded
                    : Icons.auto_awesome,
                size: 56,
                color: theme.primaryColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.filterStatus == WishlistStatus.fulfilled
                  ? 'No Completed Wishes'
                  : 'No Wishes Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.filterStatus == WishlistStatus.fulfilled
                  ? "When you buy or find a wishlisted product, mark it as completed to keep your feed clean."
                  : "Can't find what you're looking for nearby?\nMake a wish and local vendors will be notified — if they stock it, you'll see it here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? Colors.white60 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final WishlistItem wish;
  final bool isDark;

  const _WishlistCard({required this.wish, required this.isDark});

  void _showShopSelectorSheet(
    BuildContext context,
    String productName,
    List<Product> options,
  ) {
    AppBottomSheet.showBottomSheet(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Select option for $productName',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...options.map((item) {
            final distanceText = item.distanceM != null
                ? '${(item.distanceM! / 1000).toStringAsFixed(1)} km away'
                : 'Nearby';

            Widget leadingWidget;
            if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
              leadingWidget = ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey.shade800,
                    child: const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey.shade800,
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            } else {
              leadingWidget = Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: ColorName.primary,
                ),
              );
            }

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 8,
              ),
              leading: leadingWidget,
              title: Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Rs. ${item.price.toStringAsFixed(0)} • $distanceText',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.of(context).pop();
                AppNavigator.push(
                  context,
                  BlocProvider(
                    create: (_) => ProductDetailCubit(),
                    child: ProductDetailScreen(product: item),
                  ),
                );
              },
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = wish.createdAt != null
        ? DateFormat('MMM d').format(wish.createdAt!)
        : null;

    // Group matches by barcode or name to display duplicates only once
    final Map<String, List<Product>> groupedMatches = {};
    for (final item in wish.matchedItems) {
      final key = item.barcode?.trim().isNotEmpty == true
          ? 'barcode:${item.barcode!.trim().toLowerCase()}'
          : 'name:${item.name.trim().toLowerCase()}';
      groupedMatches.putIfAbsent(key, () => []).add(item);
    }
    final groupedProducts = groupedMatches.values
        .map((list) => list.first)
        .toList();
    final hasMatches = groupedProducts.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E242B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Main content row ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
            child: Row(
              children: [
                // Status indicator dot
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: wish.status == WishlistStatus.fulfilled
                        ? Colors.green.withValues(alpha: 0.12)
                        : hasMatches
                        ? Colors.blue.withValues(alpha: 0.12)
                        : ColorName.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    wish.status == WishlistStatus.fulfilled
                        ? Icons.check_circle_rounded
                        : hasMatches
                        ? Icons.star_rounded
                        : Icons.auto_awesome,
                    color: wish.status == WishlistStatus.fulfilled
                        ? Colors.green
                        : hasMatches
                        ? Colors.blue
                        : ColorName.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                // Title + meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wish.itemName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (dateStr != null) ...[
                            Text(
                              dateStr,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white38
                                    : Colors.grey.shade500,
                              ),
                            ),
                            Container(
                              width: 3,
                              height: 3,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? Colors.white24
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ],
                          Text(
                            wish.status == WishlistStatus.fulfilled
                                ? 'Fulfilled ✓'
                                : hasMatches
                                ? '${groupedProducts.length} match${groupedProducts.length > 1 ? 'es' : ''} found'
                                : 'Searching vendors…',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: wish.status == WishlistStatus.fulfilled
                                  ? Colors.green.shade600
                                  : hasMatches
                                  ? Colors.blue.shade600
                                  : (isDark
                                        ? Colors.white38
                                        : Colors.grey.shade500),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                Row(
                  children: [
                    if (wish.status != WishlistStatus.fulfilled)
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: IconButton(
                          icon: Icon(
                            Icons.check_circle_outline_rounded,
                            color: ColorName.primary.withValues(alpha: 0.6),
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          tooltip: 'Mark as Fulfilled',
                          onPressed: () => _showCompleteDialog(context),
                        ),
                      ),
                    const SizedBox(width: 4),
                    // Delete button
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: isDark ? Colors.white30 : Colors.grey.shade400,
                          size: 18,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () => _showDeleteDialog(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Description (if present) ──
          if (wish.description != null && wish.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Text(
                wish.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : const Color(0xFF6B7280),
                ),
              ),
            ),

          // ── Matched items carousel ──
          if (hasMatches) ...[
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                color: isDark
                    ? Colors.black.withValues(alpha: 0.15)
                    : const Color(0xFFF9FAFB),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      scrollDirection: Axis.horizontal,
                      itemCount: groupedProducts.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final item = groupedProducts[index];
                        final key = item.barcode?.trim().isNotEmpty == true
                            ? 'barcode:${item.barcode!.trim().toLowerCase()}'
                            : 'name:${item.name.trim().toLowerCase()}';
                        final itemOptions = groupedMatches[key] ?? [item];

                        return GestureDetector(
                          onTap: () {
                            if (itemOptions.length > 1) {
                              _showShopSelectorSheet(
                                context,
                                item.name,
                                itemOptions,
                              );
                            } else {
                              AppNavigator.push(
                                context,
                                BlocProvider(
                                  create: (_) => ProductDetailCubit(),
                                  child: ProductDetailScreen(product: item),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: 170,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2D3748)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white10
                                    : Colors.grey.shade200,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Row(
                              children: [
                                // Thumbnail
                                SizedBox(
                                  width: 60,
                                  child: item.imageUrl != null
                                      ? CachedNetworkImage(
                                          imageUrl: item.imageUrl!,
                                          fit: BoxFit.cover,
                                          height: double.infinity,
                                        )
                                      : ColoredBox(
                                          color: isDark
                                              ? Colors.black26
                                              : Colors.grey.shade100,
                                          child: const Center(
                                            child: LoadingAnimation(size: 16),
                                          ),
                                        ),
                                ),
                                // Info
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 6,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          item.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            height: 1.2,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF111827),
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
                                        if (itemOptions.length > 1) ...[
                                          const SizedBox(height: 2),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: ColorName.primary
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '${itemOptions.length} shops',
                                              style: const TextStyle(
                                                fontSize: 9,
                                                color: ColorName.primary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                                // Arrow
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Icon(
                                    Icons.chevron_right_rounded,
                                    size: 16,
                                    color: isDark
                                        ? Colors.white24
                                        : Colors.grey.shade400,
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
            ),
          ] else ...[
            // No matches yet — informative footer
            if (wish.status != WishlistStatus.fulfilled)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? Colors.white10
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.1)
                      : const Color(0xFFFFFBEB),
                ),
                child: const Text(
                  'No matches yet — vendors near you will be notified and can add this item to their shop.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    AppBottomSheet.showConfirmationBottomSheet(
      context: context,
      title: 'Delete Wish',
      message: 'Are you sure? Local vendors will no longer see this request.',
      confirmButtonText: 'Delete',
      confirmButtonColor: Colors.red.shade600,
      icon: Icons.delete_outline_rounded,
      iconColor: Colors.red.shade600,
      onConfirm: () {
        context.read<UserWishlistCubit>().deleteWishlist(wish.id);
      },
    );
  }

  void _showCompleteDialog(BuildContext context) {
    AppBottomSheet.showConfirmationBottomSheet(
      context: context,
      title: 'Mark as Fulfilled',
      message:
          'Did you find what you were looking for? Marking this as fulfilled stops open demand for vendors.',
      confirmButtonText: 'Fulfill Wish',
      confirmButtonColor: ColorName.primary,
      icon: Icons.check_circle_outline_rounded,
      iconColor: ColorName.primary,
      onConfirm: () {
        context.read<UserWishlistCubit>().completeWishlist(wish.id);
      },
    );
  }
}
