import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/models/data_models/category_model.dart';
import 'package:nearvendorapp/services/shop_services.dart';
import 'package:nearvendorapp/services/wishlist_services.dart';
import 'package:nearvendorapp/views/screens/auth/views/login_screen.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:toasty_box/toasty_box.dart';

class NoResultSheet extends StatefulWidget {
  final String? message;
  final String? searchQuery;
  final VoidCallback onIncreaseRadius;
  final VoidCallback onDismiss;

  const NoResultSheet({
    super.key,
    this.message,
    this.searchQuery,
    required this.onIncreaseRadius,
    required this.onDismiss,
  });

  @override
  State<NoResultSheet> createState() => _NoResultSheetState();
}

class _NoResultSheetState extends State<NoResultSheet> {
  bool _isCreatingWish = false;

  void _showCategoryPickerAndCreateWish() async {
    if (widget.searchQuery == null || widget.searchQuery!.isEmpty) return;

    final session = context.read<SessionCubit>().state;
    if (session.latitude == null || session.longitude == null) {
      ToastService.showErrorToast(
        context,
        expandedHeight: 100,
        message: 'Location required to make a wish.',
      );
      return;
    }

    // Fetch categories
    final categories = await ShopServices().getCategoryNames();
    if (!mounted) return;

    // Show category picker
    final selectedCategory = await showModalBottomSheet<CategoryModel>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _CategoryPickerSheet(categories: categories),
    );
    if (!mounted || selectedCategory == null) return;

    setState(() => _isCreatingWish = true);

    final input = CreateWishlistInput(
      itemName: widget.searchQuery!,
      description: '',
      categoryId: selectedCategory.id.isNotEmpty ? selectedCategory.id : null,
      lat: session.latitude!,
      lon: session.longitude!,
    );

    try {
      final response = await WishlistServices().createWishlist(input);
      if (!mounted) return;
      setState(() => _isCreatingWish = false);

      if (response['success'] == true) {
        ToastService.showSuccessToast(
          context,
          expandedHeight: 100,
          message: '✨ Wish added! Local vendors will be notified.',
        );
        widget.onDismiss();
      } else {
        ToastService.showErrorToast(
          context,
          expandedHeight: 100,
          message: response['message'] ?? 'Failed to create wish.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCreatingWish = false);
      ToastService.showErrorToast(
        context,
        expandedHeight: 100,
        message: 'Failed to create wish. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAuthenticated = context.read<SessionCubit>().isAuthenticated;
    final hasQuery = widget.searchQuery != null && widget.searchQuery!.isNotEmpty;

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

            Icon(Icons.search_off_rounded, size: 52, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              hasQuery ? '"${widget.searchQuery}" not found nearby' : 'No Items Found Nearby',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.message ?? 'We couldn\'t find this product within your discovery radius.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontFamily: 'Poppins',
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Option 1: Increase radius
            ElevatedButton.icon(
              onPressed: widget.onIncreaseRadius,
              icon: const Icon(Icons.radar_rounded, size: 18, color: Colors.white),
              label: const Text(
                'Increase Discovery Radius',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004AAD),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),

            const SizedBox(height: 12),

            // Divider with "or"
            Row(
              children: [
                Expanded(child: Divider(color: isDark ? Colors.white12 : Colors.grey.shade300)),
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
                Expanded(child: Divider(color: isDark ? Colors.white12 : Colors.grey.shade300)),
              ],
            ),

            const SizedBox(height: 12),

            // Option 2: Wishlist CTA
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorName.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ColorName.primary.withValues(alpha: 0.12)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: ColorName.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Make a Wish Instead',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Notify nearby vendors that you need this item. When they stock it, you\'ll be matched automatically.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      fontFamily: 'Poppins',
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (isAuthenticated && hasQuery)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isCreatingWish ? null : _showCategoryPickerAndCreateWish,
                        icon: _isCreatingWish
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                        label: Text(
                          _isCreatingWish ? 'Adding…' : 'Wish for "${widget.searchQuery}"',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorName.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      ),
                    )
                  else if (!isAuthenticated)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          AppNavigator.push(context, const LoginScreen());
                        },
                        icon: const Icon(Icons.login_rounded, size: 16),
                        label: const Text(
                          'Sign in to make a wish',
                          style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Poppins', fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ColorName.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          side: BorderSide(color: ColorName.primary.withValues(alpha: 0.3)),
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
                style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
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
                  child: const Icon(Icons.category_rounded,
                      color: ColorName.primary, size: 18),
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
                          fontFamily: 'Poppins',
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Helps vendors match your wish faster',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
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
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final cat = categories[index];
                return ListTile(
                  dense: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(
                    Icons.label_outline_rounded,
                    color: ColorName.primary,
                    size: 20,
                  ),
                  title: Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: isDark ? Colors.white24 : Colors.grey.shade400,
                  ),
                  onTap: () => Navigator.pop(context, cat),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
