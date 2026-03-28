import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/item_management/cubit/item_detail_cubit.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';

class ItemScreen extends StatefulWidget {
  final String? itemId;

  const ItemScreen({super.key, this.itemId});

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.itemId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ItemDetailCubit>().fetchItemById(widget.itemId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: BlocBuilder<ItemDetailCubit, ItemDetailState>(
        builder: (context, state) {
          if (state is ItemDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ItemDetailSuccess) {
            return _buildItemDetail(context, state.item);
          }
          if (state is ItemDetailFailure) {
            return _buildErrorState(context, state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildItemDetail(BuildContext context, Item item) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              ),
              backgroundColor: theme.scaffoldBackgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: 'item_img_${item.id}',
                  child:
                      item.imageUrl != null &&
                          item.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.imageUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: theme.primaryColor.withValues(
                            alpha: 0.05,
                          ),
                          child: Icon(
                            Icons.inventory_2_rounded,
                            size: 80,
                            color: theme.primaryColor.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                                color: theme
                                    .textTheme
                                    .headlineLarge
                                    ?.color,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildStockBadge(
                              context,
                              item.stockCount,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'PKR ${item.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: theme.primaryColor,
                            ),
                          ),
                          if (item.unit.isNotEmpty)
                            Text(
                              'per ${item.unit}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: theme
                                    .textTheme
                                    .bodySmall
                                    ?.color
                                    ?.withValues(alpha: 0.5),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  _buildSectionTitle(context, 'DESCRIPTION'),
                  Text(
                    item.description.isNotEmpty
                        ? item.description
                        : 'No description provided.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      height: 1.6,
                      color: theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.7),
                    ),
                  ),

                  const SizedBox(height: 32),
                  _buildSectionTitle(context, 'SPECIFICATIONS'),
                  _buildSpecRow(
                    context,
                    Icons.inventory_2_outlined,
                    'Availability',
                    item.isAvailable ? 'In Stock' : 'Out of Stock',
                  ),
                  _buildSpecRow(
                    context,
                    Icons.reorder_rounded,
                    'Total Stock',
                    '${item.stockCount} units',
                  ),
                  if (item.discount != null && item.discount! > 0)
                    _buildSpecRow(
                      context,
                      Icons.percent_rounded,
                      'Current Discount',
                      '${item.discount}% OFF',
                    ),
                ]),
              ),
            ),
          ],
        ),

        // Bottom Action Bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.scaffoldBackgroundColor.withValues(alpha: 0),
                  theme.scaffoldBackgroundColor,
                ],
              ),
            ),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Open Edit Form
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                shadowColor: theme.primaryColor.withValues(
                  alpha: 0.3,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_rounded, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Edit Product Details',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStockBadge(BuildContext context, int stock) {
    final isInStock = stock > 0;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: (isInStock ? Colors.green : Colors.red).withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isInStock ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isInStock ? 'AVAILABLE' : 'OUT OF STOCK',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: isInStock ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSpecRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1C1C23)
            : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.primaryColor.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color?.withValues(
                alpha: 0.5,
              ),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load details',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(
                  context,
                ).textTheme.headlineSmall?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => context
                  .read<ItemDetailCubit>()
                  .fetchItemById(widget.itemId!),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
