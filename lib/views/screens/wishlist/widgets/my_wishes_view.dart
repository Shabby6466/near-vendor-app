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
import 'package:intl/intl.dart';

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
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  // How-it-works banner at top
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ColorName.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: ColorName.primary.withValues(alpha: 0.12)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: ColorName.primary, size: 18),
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
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == state.wishlists.length) {
                            context.read<UserWishlistCubit>().getMyWishlists();
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          }

                          final wish = state.wishlists[index];
                          return Padding(
                            padding: EdgeInsets.only(top: index == 0 ? 8 : 0, bottom: 12),
                            child: _WishlistCard(wish: wish, isDark: isDark),
                          );
                        },
                        childCount: state.wishlists.length + (state.hasMore ? 1 : 0),
                      ),
                    ),
                  ),
                ],
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
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          label: const Text(
            'Make a Wish',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13),
          ),
          backgroundColor: ColorName.primary,
          elevation: 4,
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
            Icon(Icons.error_outline, size: 64, color: Colors.red.withValues(alpha: 0.5)),
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
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<UserWishlistCubit>().getMyWishlists(refresh: true);
              },
              icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
              label: const Text('Try Again', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorName.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ColorName.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, size: 56, color: ColorName.primary.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 24),
            Text(
              'No Wishes Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Can\'t find what you\'re looking for nearby?\nMake a wish and local vendors will be notified — if they stock it, you\'ll see it here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? Colors.white60 : Colors.black45,
              ),
            ),
            const SizedBox(height: 28),
            // How-it-works steps
            _HowItWorksStep(
              icon: Icons.edit_note_rounded,
              text: 'Describe the product you need',
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _HowItWorksStep(
              icon: Icons.storefront_rounded,
              text: 'Nearby vendors see your request',
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _HowItWorksStep(
              icon: Icons.check_circle_outline_rounded,
              text: 'Get matched when they stock it',
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _HowItWorksStep extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const _HowItWorksStep({required this.icon, required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: ColorName.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: ColorName.primary, size: 16),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final WishlistItem wish;
  final bool isDark;

  const _WishlistCard({required this.wish, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final dateStr = wish.createdAt != null
        ? DateFormat('MMM d').format(wish.createdAt!)
        : null;
    final hasMatches = wish.matchedItems.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E242B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.04),
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
                    color: wish.status == 'FULFILLED'
                        ? Colors.green.withValues(alpha: 0.12)
                        : hasMatches
                            ? Colors.blue.withValues(alpha: 0.12)
                            : ColorName.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    wish.status == 'FULFILLED'
                        ? Icons.check_circle_rounded
                        : hasMatches
                            ? Icons.star_rounded
                            : Icons.auto_awesome,
                    color: wish.status == 'FULFILLED'
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
                          color: isDark ? Colors.white : const Color(0xFF111827),
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
                                color: isDark ? Colors.white38 : Colors.grey.shade500,
                              ),
                            ),
                            Container(
                              width: 3,
                              height: 3,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? Colors.white24 : Colors.grey.shade400,
                              ),
                            ),
                          ],
                          Text(
                            wish.status == 'FULFILLED'
                                ? 'Fulfilled ✓'
                                : hasMatches
                                    ? '${wish.matchedItems.length} match${wish.matchedItems.length > 1 ? 'es' : ''} found'
                                    : 'Searching vendors…',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: wish.status == 'FULFILLED'
                                  ? Colors.green.shade600
                                  : hasMatches
                                      ? Colors.blue.shade600
                                      : (isDark ? Colors.white38 : Colors.grey.shade500),
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
                    if (wish.status != 'FULFILLED')
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: IconButton(
                          icon: Icon(Icons.check_circle_outline_rounded,
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
                        icon: Icon(Icons.close_rounded,
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
                  color: isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF6B7280),
                ),
              ),
            ),

          // ── Matched items carousel ──
          if (hasMatches) ...[
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                ),
                color: isDark ? Colors.black.withValues(alpha: 0.15) : const Color(0xFFF9FAFB),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      scrollDirection: Axis.horizontal,
                      itemCount: wish.matchedItems.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final item = wish.matchedItems[index];
                        return GestureDetector(
                          onTap: () {
                            AppNavigator.push(
                              context,
                              BlocProvider(
                                create: (_) => ExploreItemDetailCubit(),
                                child: ExploreItemDetailScreen(itemId: item.id),
                              ),
                            );
                          },
                          child: Container(
                            width: 160,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2D3748) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark ? Colors.white10 : Colors.grey.shade200,
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
                                      : Container(
                                          color: isDark ? Colors.black26 : Colors.grey.shade100,
                                          child: const Center(
                                            child: Icon(Icons.image_outlined, color: Colors.grey, size: 18),
                                          ),
                                        ),
                                ),
                                // Info
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          item.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            height: 1.2,
                                            color: isDark ? Colors.white : const Color(0xFF111827),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
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
                                // Arrow
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Icon(
                                    Icons.chevron_right_rounded,
                                    size: 16,
                                    color: isDark ? Colors.white24 : Colors.grey.shade400,
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                ),
                color: isDark ? Colors.black.withValues(alpha: 0.1) : const Color(0xFFFFFBEB),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.hourglass_top_rounded,
                    size: 14,
                    color: Colors.amber.shade700,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No matches yet — vendors near you will be notified and can add this item to their shop.',
                      style: TextStyle(
                        color: isDark ? Colors.amber.shade200 : Colors.amber.shade800,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    _showPremiumConfirmation(
      context: context,
      title: 'Delete Wish',
      content: 'Are you sure? Local vendors will no longer see this request.',
      confirmLabel: 'Delete',
      confirmColor: Colors.red,
      icon: Icons.delete_outline_rounded,
      onConfirm: () {
        context.read<UserWishlistCubit>().deleteWishlist(wish.id);
      },
    );
  }

  void _showCompleteDialog(BuildContext context) {
    _showPremiumConfirmation(
      context: context,
      title: 'Mark as Fulfilled',
      content: 'Did you find what you were looking for? Marking this as fulfilled stops open demand for vendors.',
      confirmLabel: 'Fulfill Wish',
      confirmColor: ColorName.primary,
      icon: Icons.check_circle_outline_rounded,
      onConfirm: () {
        context.read<UserWishlistCubit>().completeWishlist(wish.id);
      },
    );
  }

  void _showPremiumConfirmation({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmLabel,
    required Color confirmColor,
    required IconData icon,
    required VoidCallback onConfirm,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = Curves.easeOutBack.transform(anim1.value);
        return Transform.scale(
          scale: curve,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              backgroundColor: isDark ? const Color(0xFF1E242B) : Colors.white,
              contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: confirmColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: confirmColor, size: 40),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    content,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white30 : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onConfirm();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: confirmColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            confirmLabel,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
