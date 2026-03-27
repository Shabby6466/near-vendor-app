import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/cubit/vendor_shop_cubit.dart';
import 'package:nearvendorapp/views/screens/vendor/widgets/shop_card.dart';
import 'package:nearvendorapp/views/screens/vendor/widgets/shop_form_bottom_sheet.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/item_management/screens/item_management_screen.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:nearvendorapp/views/widgets/shimmer_effect.dart';

class VendorDashboardScreen extends StatelessWidget {
  const VendorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = CurrentUserStorage.getCurrentUser();
    final firstName = user?.fullName?.split(' ').first ?? 'Vendor';
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => VendorShopCubit()..fetchShops(),
      child: AppScaffold(
        bgColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 240), // Space for glass header
                Expanded(
                  child: BlocBuilder<VendorShopCubit, VendorShopState>(
                    builder: (context, state) {
                      if (state is VendorShopLoading) {
                        return _buildSkeletonList();
                      }
                      if (state is VendorShopFailure) {
                        return _buildErrorState(context, state.message);
                      }
                      if (state is VendorShopSuccess) {
                        if (state.shops.isEmpty) {
                          return _buildEmptyState(context);
                        }
                        return _buildShopList(context, state.shops);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildGlassHeader(context, firstName),
            ),
          ],
        ),
        floatingActionButtonLocation: const _OffsetFloatingActionButtonLocation(
          offset: Offset(0, -90),
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton.extended(
            onPressed: () => _showShopForm(context),
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 8,
            icon: const Icon(Icons.add_rounded, size: 24),
            label: const Text(
              'New Shop',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 15),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassHeader(BuildContext context, String name) {
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top;
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.fromLTRB(28, topPadding + 16, 28, 28),
          decoration: BoxDecoration(
            color: theme.cardColor.withOpacity(isDark ? 0.7 : 0.85),
            border: Border(
              bottom: BorderSide(color: theme.dividerColor.withOpacity(0.1), width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning,',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        name,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                          color: theme.textTheme.headlineLarge?.color,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.15),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: theme.cardColor,
                      child: CircleAvatar(
                        radius: 23,
                        backgroundColor: theme.primaryColor.withOpacity(0.1),
                        child: Icon(Icons.person_rounded, color: theme.primaryColor, size: 26),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildModernStats(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernStats(BuildContext context) {
    return BlocBuilder<VendorShopCubit, VendorShopState>(
      builder: (context, state) {
        int totalShops = 0;
        int activeShops = 0;
        if (state is VendorShopSuccess) {
          totalShops = state.shops.length;
          activeShops = state.shops.where((s) => s.isActive).length;
        }

        return Row(
          children: [
            _buildInfoCard(context, 'Active Shops', activeShops.toString(), const Color(0xFF34C759)),
            const SizedBox(width: 16),
            _buildInfoCard(context, 'Total Shops', totalShops.toString(), Theme.of(context).primaryColor),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value, Color accentColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: accentColor.withOpacity(isDark ? 0.3 : 0.1), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(isDark ? 0.1 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Icon(Icons.circle, color: accentColor.withOpacity(0.03), size: 60),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.titleLarge?.color,
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

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      itemCount: 3,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
          ),
          child: const ShimmerEffect(),
        ),
      ),
    );
  }

  Widget _buildShopList(BuildContext context, List<Shop> shops) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 120),
      physics: const BouncingScrollPhysics(),
      itemCount: shops.length,
      itemBuilder: (context, index) {
        final shop = shops[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: ShopCard(
            shop: shop,
            onEdit: () => _showShopForm(context, shop: shop),
            onDelete: () => _confirmDelete(context, shop),
            onTap: () => AppNavigator.push(context, ItemManagementScreen(shop: shop)),
          ),
        );
      },
    );
  }

  void _showShopForm(BuildContext context, {Shop? shop}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<VendorShopCubit>(),
        child: ShopFormBottomSheet(shop: shop),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Shop shop) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: AlertDialog(
          backgroundColor: theme.cardColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          contentPadding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.red.shade50.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade600, size: 32),
              ),
              const SizedBox(height: 24),
              Text(
                'Remove Shop?',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700, color: theme.textTheme.titleLarge?.color),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete "${shop.shopName}"? This cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => AppNavigator.pop(context),
                      child: Text('Cancel', style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.4), fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<VendorShopCubit>().deleteShop(shop.id);
                        AppNavigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.store_mall_directory_rounded, size: 80, color: theme.primaryColor),
            ),
            const SizedBox(height: 40),
            Text(
              'No Shops Yet',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w700, color: theme.textTheme.titleLarge?.color),
            ),
            const SizedBox(height: 12),
            Text(
              'Start your journey by launching your first digital retail space.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 15, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6), height: 1.5),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => _showShopForm(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 10,
                shadowColor: theme.primaryColor.withOpacity(0.3),
              ),
              child: const Text(
                'Establish First Shop',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 24),
            Text(
              'Connection Lost',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700, color: theme.textTheme.titleLarge?.color),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
            ),
            const SizedBox(height: 32),
            TextButton.icon(
              onPressed: () => context.read<VendorShopCubit>().fetchShops(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
              style: TextButton.styleFrom(foregroundColor: theme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _OffsetFloatingActionButtonLocation extends FloatingActionButtonLocation {
  final Offset offset;

  const _OffsetFloatingActionButtonLocation({required this.offset});

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final Offset standardOffset = FloatingActionButtonLocation.centerFloat.getOffset(scaffoldGeometry);
    return standardOffset + offset;
  }
}
