import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart';
import 'package:nearvendorapp/utils/app_alerts.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/item_management/cubit/item_management_cubit.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/item_management/widgets/item_form_bottom_sheet.dart';
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
                // Header with Cover Image and Logo
                _buildHeader(context),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shop Info Row
                      _buildShopInfo(context),
                      
                      const SizedBox(height: 32),
                      
                      // Shop Ratings Section
                      _buildSectionTitle(context, 'Shop Ratings'),
                      const SizedBox(height: 16),
                      _buildRatingsCard(context),
                      
                      const SizedBox(height: 32),
                      
                      // Shop Items Section
                      _buildItemsSection(context),
                      
                      const SizedBox(height: 100), // Reserve space for bottom bar
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
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 15),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
      ),
    );
  }

  void _showItemForm(BuildContext context, {Item? item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ItemManagementCubit>(),
        child: ItemFormBottomSheet(shopId: shop.id, item: item),
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
                  errorWidget: (context, url, error) => const Icon(Icons.error_outline),
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
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
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
              backgroundImage: shop.storeLogoUrl != null && shop.storeLogoUrl!.isNotEmpty
                  ? NetworkImage(shop.storeLogoUrl!)
                  : null,
              child: shop.storeLogoUrl == null || shop.storeLogoUrl!.isEmpty
                  ? Icon(Icons.storefront_rounded, size: 40, color: theme.primaryColor)
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
      padding: const EdgeInsets.only(top: 48), // Padding for floating logo
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
                    letterSpacing: -0.8,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
                Text(
                  'Vendor Profile', // Could be dynamic owner name
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.grid_view_rounded, size: 18),
            label: const Text(
              'Share',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0056C0), // Deep blue from screenshot
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 22,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(context, 'Shop Items'),
            BlocBuilder<ItemManagementCubit, ItemManagementState>(
              builder: (context, state) {
                int count = 0;
                if (state is ItemManagementSuccess) {
                  count = state.items.length;
                }
                return Text(
                  '$count items',
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
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
              return _buildErrorState(context, state.message);
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildSkeletonList(BuildContext context) {
    return Column(
      children: List.generate(3, (index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
          ),
          child: const ShimmerEffect(borderRadius: 24),
        ),
      )),
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
              child: Icon(Icons.inventory_2_rounded, size: 48, color: theme.primaryColor),
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: () => _showItemForm(context, item: item),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
                  ),
                  child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const ShimmerEffect(),
                          errorWidget: (context, url, error) => const Icon(Icons.image_not_supported_rounded),
                        )
                      : Icon(Icons.inventory_2_rounded, color: theme.iconTheme.color?.withValues(alpha: 0.4), size: 28),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(height: 4),
                    Text(
                      '${item.stockCount} ${item.unit} in stock',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'PKR ${item.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              _buildItemActions(context, item),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemActions(BuildContext context, Item item) {
    final theme = Theme.of(context);
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
      onSelected: (value) {
        if (value == 'edit') {
          _showItemForm(context, item: item);
        } else if (value == 'delete') {
          _confirmDeleteItem(context, item);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_rounded, size: 20, color: Colors.blue.shade600),
              const SizedBox(width: 12),
              Text('Edit', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, color: theme.textTheme.bodyMedium?.color)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red.shade600),
              const SizedBox(width: 12),
              const Text('Delete', style: TextStyle(fontFamily: 'Poppins', color: Colors.red, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDeleteItem(BuildContext context, Item item) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text('Delete Item?', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to delete "${item.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins')),
            ),
            TextButton(
              onPressed: () {
                context.read<ItemManagementCubit>().deleteItem(item.id);
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(fontFamily: 'Poppins', color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingsCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '0 Reviews',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star_rounded,
                    color: theme.dividerColor.withValues(alpha: 0.1),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'No Reviews',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        children: [
          Text(
            'Error: $message',
            style: TextStyle(color: Colors.red, fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.read<ItemManagementCubit>().fetchItems(),
            child: const Text('Retry', style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }
}
