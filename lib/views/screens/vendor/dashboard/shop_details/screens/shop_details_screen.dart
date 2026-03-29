import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart';
import 'package:nearvendorapp/utils/app_alerts.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/item_management/cubit/item_management_cubit.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/item_management/screens/add_product_screen.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/analytics/cubit/analytics_cubit.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/analytics/screens/analytics_screen.dart';
import 'package:nearvendorapp/models/api_responses/analytics_response.dart';
import 'package:nearvendorapp/utils/constants/hive_keys.dart';
import 'package:nearvendorapp/utils/hive/hive_manager.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nearvendorapp/views/widgets/shimmer_effect.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/screens/edit_shop_screen.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/cubit/vendor_shop_cubit.dart';
import 'package:fl_chart/fl_chart.dart';

class ShopDetailsScreen extends StatefulWidget {
  final Shop shop;
  const ShopDetailsScreen({super.key, required this.shop});

  @override
  State<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Load persisted days
    final storedDays = HiveManager.currentUserBox.get(
      HiveKeys.analyticsDaysSelectionKey,
      defaultValue: 7,
    );
    final days = (storedDays as int).clamp(1, 30);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ItemManagementCubit(shopId: widget.shop.id)..fetchItems(),
        ),
        BlocProvider(
          create: (context) => AnalyticsCubit()..fetchShopDetails(widget.shop.id, days: days),
        ),
      ],
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
                      const SizedBox(height: 32),
                      _buildAnalyticsSection(context),
                      const SizedBox(height: 32),
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
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text(
                'Add',
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
      BlocProvider.value(
        value: context.read<ItemManagementCubit>(),
        child: AddProductScreen(shopId: widget.shop.id, item: item),
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
          child: widget.shop.coverImageUrl != null && widget.shop.coverImageUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: widget.shop.coverImageUrl!,
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
                  widget.shop.storeLogoUrl != null && widget.shop.storeLogoUrl!.isNotEmpty
                  ? NetworkImage(widget.shop.storeLogoUrl!)
                  : null,
              child: widget.shop.storeLogoUrl == null || widget.shop.storeLogoUrl!.isEmpty
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
                  widget.shop.shopName,
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

          const SizedBox(width: 8),
          
          _buildActionButton(
            context,
            icon: Icons.edit_note_rounded,
            color: Colors.blue,
            onTap: () => _showEditForm(context),
          ),
          
          const SizedBox(width: 8),
          
          _buildActionButton(
            context,
            icon: Icons.delete_outline_rounded,
            color: Colors.red,
            onTap: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  void _showEditForm(BuildContext context) {
    AppNavigator.push(
      context,
      BlocProvider.value(
        value: context.read<VendorShopCubit>(),
        child: EditShopScreen(shop: widget.shop),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: theme.cardColor.withValues(alpha: 0.9),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          contentPadding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_sweep_rounded,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Delete Shop?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete "${widget.shop.shopName}"?\nAll inventory will be permanently removed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  height: 1.5,
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.6,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => AppNavigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.4,
                          ),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<VendorShopCubit>().deleteShop(widget.shop.id);
                        AppNavigator.pop(context);
                        AppNavigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(fontWeight: FontWeight.w800),
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
  }

  Widget _buildAnalyticsSection(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AnalyticsCubit, AnalyticsState>(
      builder: (context, state) {
        if (state is AnalyticsLoading) {
          return _buildAnalyticsSkeleton(context);
        }
        if (state is AnalyticsSuccess && state.selectedShopInsights != null) {
          final insights = state.selectedShopInsights!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle(
                    context: context,
                    title: 'Performance',
                    fontSize: 18,
                  ),
                  TextButton(
                    onPressed: () {
                      AppNavigator.push(
                        context,
                        MultiBlocProvider(
                          providers: [
                            BlocProvider(create: (context) => AnalyticsCubit()..fetchShopDetails(widget.shop.id, days: state.days)),
                            BlocProvider.value(value: context.read<VendorShopCubit>()),
                          ],
                          child: const AnalyticsScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'All Insights',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildMetricCards(context, insights.summary),
              const SizedBox(height: 24),
              _buildSectionTitle(
                context: context,
                title: 'Performance Trend',
                fontSize: 14,
              ),
              const SizedBox(height: 12),
              _buildMiniTrendChart(context, state.selectedShopStats ?? []),
              const SizedBox(height: 24),
              if (state.selectedShopMarket != null && state.selectedShopMarket!.neighborhoodDemand.isNotEmpty) ...[
                _buildSectionTitle(
                  context: context,
                  title: 'Local Demand',
                  fontSize: 14,
                ),
                const SizedBox(height: 12),
                _buildMarketDemandList(context, state.selectedShopMarket!.neighborhoodDemand.take(3).toList()),
              ],
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMiniTrendChart(BuildContext context, List<AnalyticsStatEntry> stats) {
    if (stats.isEmpty) return const SizedBox.shrink();
    
    final data = stats.where((s) => s.type == 'IMPRESSION').toList();
    if (data.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 100,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.count.toDouble());
              }).toList(),
              isCurved: true,
              color: Theme.of(context).primaryColor,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSkeleton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context: context, title: 'Performance', fontSize: 18),
        const SizedBox(height: 12),
        Row(
          children: List.generate(3, (i) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < 2 ? 8.0 : 0),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const ShimmerEffect(borderRadius: 16),
              ),
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildMetricCards(BuildContext context, InsightsSummary summary) {
    return Row(
      children: [
        _buildMiniMetricCard(
          context,
          'Impressions',
          summary.impressions.toString(),
          Icons.visibility_outlined,
          Colors.blue,
        ),
        const SizedBox(width: 8),
        _buildMiniMetricCard(
          context,
          'Views',
          summary.views.toString(),
          Icons.ads_click_rounded,
          Colors.orange,
        ),
        const SizedBox(width: 8),
        _buildMiniMetricCard(
          context,
          'CTR',
          '${summary.ctr}%',
          Icons.analytics_outlined,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildMiniMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketDemandList(BuildContext context, List<DemandEntry> demand) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: demand.asMap().entries.map((e) {
          final entry = e.value;
          final isLast = e.key == demand.length - 1;
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.query.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${entry.count} Hits',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              if (!isLast) const Divider(height: 16),
            ],
          );
        }).toList(),
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: isDark ? 0.1 : 0.05),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _showItemForm(context, item: item);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const ShimmerEffect(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.image_not_supported_rounded),
                        )
                      : Container(
                          color: theme.primaryColor.withValues(alpha: 0.05),
                          child: Icon(
                            Icons.inventory_2_rounded,
                            color: theme.primaryColor.withValues(alpha: 0.4),
                            size: 32,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Content Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 0.5,
                        color: theme.textTheme.titleMedium?.color,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PRICE',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: theme.textTheme.bodySmall?.color
                                    ?.withValues(alpha: 0.4),
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              'PKR ${item.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
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
