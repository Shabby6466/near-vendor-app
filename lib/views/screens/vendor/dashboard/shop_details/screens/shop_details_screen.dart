import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart';
import 'package:nearvendorapp/utils/app_alerts.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/item_management/cubit/item_management_cubit.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/item_management/cubit/item_detail_cubit.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/item_management/widgets/item_screen.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nearvendorapp/views/widgets/shimmer_effect.dart';

class ShopDetailsScreen extends StatelessWidget {
  final Shop shop;

  const ShopDetailsScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => ItemManagementCubit(shopId: shop.id)..fetchItems(),
      child: BlocListener<ItemManagementCubit, ItemManagementState>(
        listener: (context, state) {
          if (state is ItemActionSuccess) {
            AppAlerts.showSuccessSnackBar(context, state.message);
          } else if (state is ItemManagementFailure) {
            AppAlerts.showErrorSnackBar(context, state.message);
          }
        },
        child: AppScaffold(
          bgColor: theme.scaffoldBackgroundColor,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(context),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShopInfo(context),

                      const SizedBox(height: 20),

                      _buildItemsSection(context),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: Builder(
            builder: (context) => FloatingActionButton.extended(
              onPressed: () => _showItemForm(context),
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 8,
              icon: const Icon(Icons.add_rounded, size: 24),
              label: const Text(
                'Add Item',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showItemForm(BuildContext context, {Item? item}) {
    AppNavigator.push(
      context, 
      BlocProvider(
        create: (context) => ItemDetailCubit(),
        child: ItemScreen(itemId: item?.id),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Cover Image
        Container(
          height: 260,
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.dividerColor.withValues(alpha: 0.05),
          ),
          child: shop.coverImageUrl != null && shop.coverImageUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: shop.coverImageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const ShimmerEffect(),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error_outline),
                )
              : Center(
                  child: Icon(
                    Icons.store_rounded,
                    size: 80,
                    color: theme.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
        ),

        // Back Button
        Positioned(
          top: topPadding + 12,
          left: 20,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => AppNavigator.pop(context),
                ),
              ),
            ),
          ),
        ),

        // Floating Logo
        Positioned(
          bottom: -40,
          left: 24,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 54,
              backgroundColor: theme.scaffoldBackgroundColor,
              backgroundImage:
                  shop.storeLogoUrl != null && shop.storeLogoUrl!.isNotEmpty
                  ? NetworkImage(shop.storeLogoUrl!)
                  : null,
              child: shop.storeLogoUrl == null || shop.storeLogoUrl!.isEmpty
                  ? Icon(
                      Icons.storefront_rounded,
                      size: 40,
                      color: theme.primaryColor,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShopInfo(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 36),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shop.shopName,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
              ],
            ),
          ),

          ElevatedButton.icon(
            onPressed: () {},
            label: const Text(
              'Share',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0056C0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required BuildContext context,
    required String title,
    double? fontSize,
  }) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: fontSize ?? 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: Theme.of(context).textTheme.titleLarge?.color,
      ),
    );
  }

  Widget _buildItemsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionTitle(
              context: context,
              title: 'Inventory',
              fontSize: 18,
            ),
            SizedBox(width: 16),
            BlocBuilder<ItemManagementCubit, ItemManagementState>(
              builder: (context, state) {
                int count = 0;
                if (state is ItemManagementSuccess) {
                  count = state.meta?.totalItems ?? state.items.length;
                }
                return Text(
                  '$count items',
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.5,
                    ),
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                );
              },
            ),
          ],
        ),
        SizedBox(height: 10),
        BlocBuilder<ItemManagementCubit, ItemManagementState>(
          builder: (context, state) {
            if (state is ItemManagementLoading) {
              return _buildSkeletonList(context);
            }
            if (state is ItemManagementSuccess) {
              if (state.items.isEmpty) {
                return _buildEmptyItemsState(context);
              }
              return _buildItemList(context, state.items);
            }
            if (state is ItemManagementFailure) {
              return _buildErrorState(context);
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildSkeletonList(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
              ),
            ),
            child: const ShimmerEffect(borderRadius: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyItemsState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_rounded,
                size: 48,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No items found',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start adding products to your shop.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemList(BuildContext context, List<Item> items) {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemCard(context, item);
      },
    );
  }

  Widget _buildItemCard(BuildContext context, Item item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: () => _showItemForm(context, item: item),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey.shade50,
                  ),
                  child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const ShimmerEffect(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.image_not_supported_rounded),
                        )
                      : Icon(
                          Icons.inventory_2_rounded,
                          color: theme.iconTheme.color?.withValues(alpha: 0.4),
                          size: 28,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    Text(
                      '${item.stockCount} ${item.unit} in stock',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.5,
                        ),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'PKR ${item.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
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


  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error, size: 48, color: theme.primaryColor),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<ItemManagementCubit>().fetchItems();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
