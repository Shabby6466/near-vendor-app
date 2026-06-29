import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/utils/ui/app_alerts.dart';
import 'package:nearvendorapp/views/screens/profile_screen/view/blocked_shops_screen/cubit/blocked_shops_cubit.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';

class BlockedShopsScreen extends StatelessWidget {
  const BlockedShopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => BlockedShopsCubit()..fetchBlockedShops(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Blocked Shops')),
        body: BlocConsumer<BlockedShopsCubit, BlockedShopsState>(
          listener: (context, state) {
            if (state is BlockedShopsFailure) {
              AppAlerts.showError(context, state.error);
            }
          },
          builder: (context, state) {
            if (state is BlockedShopsLoading) {
              return const Center(child: LoadingAnimation());
            }

            if (state is BlockedShopsSuccess) {
              final shops = state.shops;
              if (shops.isEmpty) {
                return _buildEmptyState(context);
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: shops.length,
                itemBuilder: (context, index) {
                  final shop = shops[index];
                  return _buildShopCard(context, shop, isDark);
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.block_flipped, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No Blocked Shops',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Shops you block will appear here.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildShopCard(BuildContext context, BlockedShop shop, bool isDark) {
    final theme = Theme.of(context);
    final cubit = context.read<BlockedShopsCubit>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: shop.shopLogoUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: shop.shopLogoUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => ColoredBox(
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => ColoredBox(
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.store, color: Colors.grey),
                  ),
                )
              : Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.store, color: Colors.grey),
                ),
        ),
        title: Text(
          shop.shopName,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: OutlinedButton(
          onPressed: () {
            AppBottomSheet.showConfirmationBottomSheet(
              context: context,
              title: 'Unblock Shop',
              message: 'Are you sure you want to unblock ${shop.shopName}?',
              confirmButtonText: 'Unblock',
              confirmButtonColor: theme.colorScheme.primary,
              onConfirm: () async {
                final success = await cubit.unblockShop(shop.blockedShopId);
                if (success && context.mounted) {
                  AppAlerts.showSuccess(
                    context,
                    '${shop.shopName} has been unblocked.',
                  );
                } else if (context.mounted) {
                  AppAlerts.showError(
                    context,
                    'Failed to unblock ${shop.shopName}',
                  );
                }
              },
            );
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: Text(
            'Unblock',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
