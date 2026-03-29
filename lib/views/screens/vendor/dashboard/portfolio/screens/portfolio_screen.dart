import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/portfolio/cubit/portfolio_cubit.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/portfolio/cubit/portfolio_state.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return AppScaffold(
      appBar: AppBar(
        title: const Text(
          'Portfolio Insights',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<PortfolioCubit, PortfolioState>(
        builder: (context, state) {
          if (state is PortfolioLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PortfolioFailure) {
            return Center(child: Text(state.message));
          }

          if (state is PortfolioSuccess) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildSearchBar(context),
                  ),
                ),

                // Performance Section (only show if not searching)
                if (state.searchQuery == null || state.searchQuery!.isEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: _buildPerformanceHeader(context, state),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildPerformanceSection(context, state),
                  ),
                ],

                // Search Results
                if (state.searchQuery != null && state.searchQuery!.isNotEmpty) ...[
                  if (state.shops.isNotEmpty) ...[
                    _buildSectionHeader('Shops found'),
                    _buildShopsGrid(state.shops),
                  ],
                  if (state.items.isNotEmpty) ...[
                    _buildSectionHeader('Items found'),
                    _buildItemsList(state.items),
                  ],
                  if (state.shops.isEmpty && state.items.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'No matches found in your portfolio',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
                        ),
                      ),
                    ),
                ],
                
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => context.read<PortfolioCubit>().searchPortfolio(val),
        decoration: InputDecoration(
          hintText: 'Search shops or items...',
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
          ),
          prefixIcon: Icon(Icons.search_rounded, color: theme.primaryColor),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                    context.read<PortfolioCubit>().searchPortfolio('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildPerformanceHeader(BuildContext context, PortfolioSuccess state) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Performance',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            _buildTimeRangePicker(context, state),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Insights based on customer engagement',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeRangePicker(BuildContext context, PortfolioSuccess state) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<int>(
        value: state.days,
        underline: const SizedBox(),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.primaryColor, size: 20),
        items: [1, 7, 30].map((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(
              'Last $value days',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: theme.primaryColor,
              ),
            ),
          );
        }).toList(),
        onChanged: (val) {
          if (val != null) context.read<PortfolioCubit>().changeTimeRange(val);
        },
      ),
    );
  }

  Widget _buildPerformanceSection(BuildContext context, PortfolioSuccess state) {
    return Column(
      children: [
        _buildPerformanceList(
          context,
          title: 'Best Performers',
          subtitle: 'High engagement items',
          items: state.bestPerformers,
          isPositive: true,
        ),
        _buildPerformanceList(
          context,
          title: 'Needs Attention',
          subtitle: 'Lower engagement items',
          items: state.poorPerformers,
          isPositive: false,
        ),
      ],
    );
  }

  Widget _buildPerformanceList(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<Item> items,
    required bool isPositive,
  }) {
    final theme = Theme.of(context);
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) => _buildPerformanceCard(context, items[index], isPositive),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceCard(BuildContext context, Item item, bool isPositive) {
    final theme = Theme.of(context);
    final indicatorColor = isPositive ? Colors.green : Colors.orange;

    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (item.imageUrl != null)
                    CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(color: theme.primaryColor.withValues(alpha: 0.05)),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: indicatorColor.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive ? Icons.trending_up_rounded : Icons.trending_flat_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.count ?? 0}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.shop?['shopName'] ?? 'No Shop',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildShopsGrid(List<Shop> shops) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final shop = shops[index];
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
              ),
              child: Stack(
                children: [
                  if (shop.coverImageUrl != null)
                   ClipRRect(
                     borderRadius: BorderRadius.circular(16),
                     child: Opacity(
                       opacity: 0.2,
                       child: CachedNetworkImage(
                         imageUrl: shop.coverImageUrl!,
                         fit: BoxFit.cover,
                         width: double.infinity,
                         height: double.infinity,
                       ),
                     ),
                   ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          shop.shopName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          shop.shopAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          childCount: shops.length,
        ),
      ),
    );
  }

  Widget _buildItemsList(List<Item> items) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: item.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 50,
                            height: 50,
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            child: Icon(Icons.inventory_2_rounded, color: Theme.of(context).primaryColor, size: 24),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          item.shop?['shopName']?.toString() ?? '',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'PKR ${item.price}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }
}
