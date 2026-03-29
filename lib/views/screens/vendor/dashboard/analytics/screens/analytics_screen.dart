import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/api_responses/analytics_response.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart';
import 'package:nearvendorapp/utils/app_alerts.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/analytics/cubit/analytics_cubit.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/cubit/vendor_shop_cubit.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/constants/hive_keys.dart';
import 'package:nearvendorapp/utils/hive/hive_manager.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedDays = 7;
  String? _selectedShopId;

  @override
  void initState() {
    super.initState();
    _loadSelectedDays();
    context.read<AnalyticsCubit>().fetchPortfolioAnalytics(days: _selectedDays);
  }

  void _loadSelectedDays() {
    final storedDays = HiveManager.currentUserBox.get(
      HiveKeys.analyticsDaysSelectionKey,
      defaultValue: 7,
    );
    setState(() {
      _selectedDays = (storedDays as int).clamp(1, 30);
    });
  }

  void _saveSelectedDays(int days) {
    HiveManager.currentUserBox.put(HiveKeys.analyticsDaysSelectionKey, days);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        appBar: AppBar(
          title: const Text(
            'Performance Insights',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
          ),
          elevation: 0,
          backgroundColor: theme.scaffoldBackgroundColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => AppNavigator.pop(context),
          ),
          actions: const [
            SizedBox(width: 8),
          ],
          bottom: TabBar(
            indicatorColor: theme.primaryColor,
            labelColor: theme.primaryColor,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'PORTFOLIO'),
              Tab(text: 'SHOP INSIGHTS'),
            ],
          ),
        ),
        body: BlocConsumer<AnalyticsCubit, AnalyticsState>(
          listener: (context, state) {
            if (state is AnalyticsFailure) {
              AppAlerts.showErrorSnackBar(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is AnalyticsLoading && state is! AnalyticsSuccess) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AnalyticsSuccess) {
              return Column(
                children: [
                  _buildDaysSlider(context),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildPortfolioTab(context, state),
                        _buildInsightsTab(context, state),
                      ],
                    ),
                  ),
                ],
              );
            }

            return const Center(child: Text('Initialize analytics...'));
          },
        ),
      ),
    );
  }

  Widget _buildDaysSlider(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      color: theme.scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TIME RANGE',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_selectedDays DAYS',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: theme.primaryColor,
              inactiveTrackColor: theme.primaryColor.withValues(alpha: 0.1),
              thumbColor: theme.primaryColor,
              overlayColor: theme.primaryColor.withValues(alpha: 0.1),
              valueIndicatorColor: theme.primaryColor,
              valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            child: Slider(
              value: _selectedDays.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              label: '$_selectedDays Days',
              onChanged: (value) {
                setState(() => _selectedDays = value.round());
              },
              onChangeEnd: (value) {
                final days = value.round();
                _saveSelectedDays(days);
                if (_selectedShopId != null) {
                  context.read<AnalyticsCubit>().fetchShopDetails(_selectedShopId!, days: days);
                } else {
                  context.read<AnalyticsCubit>().fetchPortfolioAnalytics(days: days);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioTab(BuildContext context, AnalyticsSuccess state) {
    final portfolio = state.portfolio;

    if (portfolio.isEmpty) {
      return const Center(child: Text('No portfolio data available'));
    }

    final Map<String, int> shopImpressions = {};
    for (var entry in portfolio) {
      if (entry.type == 'IMPRESSION') {
        shopImpressions[entry.shopId] = (shopImpressions[entry.shopId] ?? 0) + entry.count;
      }
    }

    final sortedEntries = shopImpressions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Network Exposure'),
          const SizedBox(height: 16),
          _buildBarChart(context, sortedEntries),
          const SizedBox(height: 32),
          _buildSectionTitle('Portfolio Breakdown'),
          const SizedBox(height: 16),
          ...sortedEntries.map((e) => _buildShopStatRow(context, e)),
        ],
      ),
    );
  }

  Widget _buildInsightsTab(BuildContext context, AnalyticsSuccess state) {
    return BlocBuilder<VendorShopCubit, VendorShopState>(
      builder: (context, shopState) {
        List<Shop> shops = [];
        if (shopState is VendorShopSuccess) shops = shopState.shops;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShopSelector(context, shops),
              const SizedBox(height: 24),
              if (state.selectedShopInsights != null) ...[
                _buildInsightsSummary(context, state.selectedShopInsights!.summary),
                const SizedBox(height: 32),
                _buildSectionTitle('Trend Analysis'),
                const SizedBox(height: 16),
                _buildLineChart(context, state.selectedShopStats ?? []),
                const SizedBox(height: 32),
                _buildSectionTitle('Neighborhood Demand'),
                const SizedBox(height: 16),
                _buildDemandList(context, state.selectedShopMarket?.neighborhoodDemand ?? []),
              ] else if (_selectedShopId == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Text('Select a shop to view detailed insights'),
                  ),
                )
              else
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShopSelector(BuildContext context, List<Shop> shops) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Text('Select Shop'),
          value: _selectedShopId,
          items: shops.map((s) {
            return DropdownMenuItem<String>(
              value: s.id,
              child: Text(s.shopName),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedShopId = value);
              context.read<AnalyticsCubit>().fetchShopDetails(value, days: _selectedDays);
            }
          },
        ),
      ),
    );
  }

  Widget _buildInsightsSummary(BuildContext context, InsightsSummary summary) {
    return Row(
      children: [
        _buildSummaryCard(
          context,
          'Impressions',
          summary.impressions.toString(),
          Icons.visibility_outlined,
          Colors.blue,
        ),
        const SizedBox(width: 12),
        _buildSummaryCard(
          context,
          'Views',
          summary.views.toString(),
          Icons.ads_click_rounded,
          Colors.orange,
        ),
        const SizedBox(width: 12),
        _buildSummaryCard(
          context,
          'CTR',
          '${summary.ctr}%',
          Icons.analytics_outlined,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, List<MapEntry<String, int>> data) {
    return Container(
      height: 200,
      padding: const EdgeInsets.only(top: 20, right: 20),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: data.isEmpty ? 10 : data.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: const FlTitlesData(show: false),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: data.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.value.toDouble(),
                  color: Theme.of(context).primaryColor,
                  width: 18,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLineChart(BuildContext context, List<AnalyticsStatEntry> stats) {
    if (stats.isEmpty) return const Center(child: Text('No data for trends'));

    final impressions = stats.where((s) => s.type == 'IMPRESSION').toList();
    final views = stats.where((s) => s.type == 'VIEW').toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.only(top: 20, right: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: impressions.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.count.toDouble());
              }).toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withValues(alpha: 0.1),
              ),
            ),
            LineChartBarData(
              spots: views.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.count.toDouble());
              }).toList(),
              isCurved: true,
              color: Colors.orange,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.orange.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemandList(BuildContext context, List<DemandEntry> demand) {
    if (demand.isEmpty) return const Center(child: Text('Evaluating neighborhood demand...'));

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: demand.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = demand[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            entry.query.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: const Text('High search volume in your area'),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${entry.count} Hits',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShopStatRow(BuildContext context, MapEntry<String, int> entry) {
    return BlocBuilder<VendorShopCubit, VendorShopState>(
      builder: (context, shopState) {
        String shopName = 'Shop ${entry.key.substring(0, 5)}...';
        if (shopState is VendorShopSuccess) {
          final shop = shopState.shops.cast<Shop?>().firstWhere(
                (s) => s?.id == entry.key,
                orElse: () => null,
              );
          if (shop != null) shopName = shop.shopName;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.storefront_rounded, 
                  color: Theme.of(context).primaryColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shopName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Total impressions this period',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                entry.value.toString(),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    );
  }
}
