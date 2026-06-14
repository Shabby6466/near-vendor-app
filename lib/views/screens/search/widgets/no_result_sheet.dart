import 'package:flutter/material.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/models/data_models/category_model.dart';
import 'package:nearvendorapp/services/shop_services.dart';
import 'package:nearvendorapp/services/wishlist_services.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/category_utils.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/navigation/location_picker_launcher.dart';
import 'package:nearvendorapp/views/screens/auth/view/login_screen.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';
import 'package:toasty_box/toast_service.dart';

class NoResultSheet extends StatefulWidget {
  final String? message;
  final String? searchQuery;
  final VoidCallback onIncreaseRadius;
  final VoidCallback onDismiss;
  final double? radiusUsed;
  final bool hasMoreBeyondRadius;

  const NoResultSheet({
    super.key,
    this.message,
    this.searchQuery,
    required this.onIncreaseRadius,
    required this.onDismiss,
    this.radiusUsed,
    this.hasMoreBeyondRadius = false,
  });

  @override
  State<NoResultSheet> createState() => _NoResultSheetState();
}

class _NoResultSheetState extends State<NoResultSheet> {
  bool _isCreatingWish = false;

  Future<void> _showCategoryPickerAndCreateWish() async {
    if (widget.searchQuery == null || widget.searchQuery!.isEmpty) return;

    final location = await LocationPickerLauncher.ensureLocation(context);
    if (!mounted || location == null) return;

    // Fetch categories
    final categories = await ShopServices().getCategoryNames();
    if (!mounted) return;

    // Show category picker
    final selectedCategory = await showModalBottomSheet<CategoryModel>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _CategoryPickerSheet(
        categories: [CategoryModel(id: '', name: 'None / Skip'), ...categories],
      ),
    );
    if (!mounted || selectedCategory == null) return;

    setState(() => _isCreatingWish = true);

    final input = CreateWishlistInput(
      itemName: widget.searchQuery!,
      description: '',
      categoryId: selectedCategory.id.isNotEmpty ? selectedCategory.id : null,
      lat: location.latitude,
      lon: location.longitude,
    );

    try {
      final response = await WishlistServices().createWishlist(input);
      if (!mounted) return;
      setState(() => _isCreatingWish = false);

      if (response.success == true) {
        ToastService.showSuccessToast(
          context,
          message: '✨ Wish added! Local vendors will be notified.',
        );
        widget.onDismiss();
      } else {
        ToastService.showErrorToast(
          context,
          message: (response.message) ?? 'Failed to create wish.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCreatingWish = false);
      ToastService.showErrorToast(
        context,
        message: 'Failed to create wish. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAuthenticated = AppData().isLoggedIn;
    final hasQuery =
        widget.searchQuery != null && widget.searchQuery!.isNotEmpty;

    final double? radiusKm = widget.radiusUsed != null
        ? widget.radiusUsed! / 1000.0
        : null;
    final double? expandedRadiusKm = radiusKm != null
        ? (radiusKm * 3.0).clamp(1.0, 50.0)
        : null;

    final String titleText;
    final String bodyText;
    final String actionText;
    final bool showIncreaseAction;

    if (radiusKm != null) {
      titleText = 'No matches within ${radiusKm.toStringAsFixed(0)}km';
      bodyText = widget.hasMoreBeyondRadius
          ? 'Would you like to expand your search to ${expandedRadiusKm!.toStringAsFixed(0)}km?'
          : "No matching products found nearby.";
      actionText = 'Expand search';
      showIncreaseAction = widget.hasMoreBeyondRadius;
    } else {
      titleText = hasQuery
          ? '"${widget.searchQuery}" not found nearby'
          : 'No Items Found Nearby';
      bodyText =
          widget.message ??
          "We couldn't find this product within your discovery radius.";
      actionText = 'Increase Discovery Radius';
      showIncreaseAction = true;
    }

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Icon(
              Icons.search_off_rounded,
              size: 52,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              titleText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              bodyText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            if (showIncreaseAction) ...[
              ElevatedButton.icon(
                onPressed: widget.onIncreaseRadius,
                icon: const Icon(
                  Icons.radar_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  actionText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004AAD),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: isDark ? Colors.white12 : Colors.grey.shade300,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white38 : Colors.grey.shade500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: isDark ? Colors.white12 : Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (!showIncreaseAction) const SizedBox(height: 12),

            // Option 2: Wishlist CTA
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorName.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: ColorName.primary.withValues(alpha: 0.12),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: ColorName.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Make a Wish Instead',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Notify nearby vendors that you need this item. When they stock it, you'll be matched automatically.",
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (isAuthenticated && hasQuery)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isCreatingWish
                            ? null
                            : _showCategoryPickerAndCreateWish,
                        icon: _isCreatingWish
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: LoadingAnimation(
                                  color: Colors.white,
                                  size: 28,
                                ),
                              )
                            : const Icon(
                                Icons.add_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                        label: Text(
                          _isCreatingWish
                              ? 'Adding…'
                              : 'Wish for "${widget.searchQuery}"',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                        ),
                      ),
                    )
                  else if (!isAuthenticated)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          AppNavigator.pop(context);
                          AppNavigator.push(context, const LoginScreen());
                        },
                        icon: const Icon(Icons.login_rounded, size: 16),
                        label: const Text(
                          'Sign in to make a wish',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ColorName.primary,
                          side: BorderSide(
                            color: ColorName.primary.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            TextButton(
              onPressed: widget.onDismiss,
              child: Text(
                'Dismiss',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPickerSheet extends StatelessWidget {
  final List<CategoryModel> categories;

  const _CategoryPickerSheet({required this.categories});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171D25) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorName.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.category_rounded,
                    color: ColorName.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pick a Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Helps vendors match your wish faster',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final iconPath = CategoryUtils.getCategoryIcon(cat.name);
                return ListTile(
                  dense: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: cat.id.isEmpty
                      ? const Icon(
                          Icons.do_not_disturb_on_rounded,
                          color: ColorName.primary,
                          size: 20,
                        )
                      : (iconPath != null
                          ? iconPath.svg(
                              colorFilter: const ColorFilter.mode(
                                ColorName.primary,
                                BlendMode.srcIn,
                              ),
                              width: 20,
                              height: 20,
                            )
                          : Icon(
                              CategoryUtils.getDefaultIcon(cat.name),
                              color: ColorName.primary,
                              size: 20,
                            )),
                  title: Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: isDark ? Colors.white24 : Colors.grey.shade400,
                  ),
                  onTap: () => AppNavigator.pop(context, cat),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
