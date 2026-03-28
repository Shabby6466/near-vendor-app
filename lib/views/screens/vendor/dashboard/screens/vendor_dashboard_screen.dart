import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/cubit/vendor_shop_cubit.dart';
import 'package:nearvendorapp/views/screens/vendor/widgets/shop_card.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/shop_details/screens/shop_details_screen.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/screens/create_shop_screen.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:nearvendorapp/views/widgets/shimmer_effect.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  late ScrollController _scrollController;
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final bool isCollapsed =
        _scrollController.hasClients && _scrollController.offset > (280 - 100);
    if (isCollapsed != _isCollapsed) {
      setState(() {
        _isCollapsed = isCollapsed;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = CurrentUserStorage.getCurrentUser();
    final firstName = user?.fullName?.split(' ').first ?? 'Vendor';
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => VendorShopCubit()..fetchShops(),
      child: Builder(
        builder: (context) => AppScaffold(
          bgColor: theme.scaffoldBackgroundColor,
          body: RefreshIndicator(
            onRefresh: () async {
              await context.read<VendorShopCubit>().fetchShops();
              await Future.delayed(const Duration(milliseconds: 800));
            },
            displacement: 10,
            edgeOffset: MediaQuery.of(context).padding.top,
            color: theme.primaryColor,
            backgroundColor: theme.cardColor,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                _buildSliverHeader(context, firstName),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                  ),
                ),

                _buildQuickActionsGrid(context),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Retail Spaces',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                        BlocBuilder<VendorShopCubit, VendorShopState>(
                          builder: (context, state) {
                            List<Shop>? shops;
                            if (state is VendorShopSuccess) shops = state.shops;
                            if (state is VendorShopLoading) shops = state.shops;

                            if (shops != null && shops.isNotEmpty) {
                              return Text(
                                '${shops.length} Active',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: theme.primaryColor,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                BlocBuilder<VendorShopCubit, VendorShopState>(
                  builder: (context, state) {
                    if (state is VendorShopLoading &&
                        (state.shops == null || state.shops!.isEmpty)) {
                      return _buildSliverSkeletonList();
                    }
                    if (state is VendorShopFailure) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildErrorState(context, state.message),
                      );
                    }

                    List<Shop>? shops;
                    if (state is VendorShopSuccess) shops = state.shops;
                    if (state is VendorShopLoading) shops = state.shops;

                    if (shops != null) {
                      if (shops.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmptyState(context),
                        );
                      }
                      return _buildSliverShopList(context, shops);
                    }
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context, String name) {
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return SliverAppBar(
      expandedHeight: 250,
      collapsedHeight: 60,
      pinned: true,
      stretch: true,
      backgroundColor: theme.primaryColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      titleSpacing: 0,
      title: _isCollapsed
          ? _buildCollapsedTitle(context, name, topPadding)
          : null,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              right: -50,
              top: -50,
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  Icons.dashboard_rounded,
                  size: 250,
                  color: Colors.white,
                ),
              ),
            ),
            if (!_isCollapsed) _buildExpandedHeader(context, name),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsedTitle(
    BuildContext context,
    String name,
    double topPadding,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedHeader(BuildContext context, String name) {
    return Padding(
      key: const ValueKey('expanded'),
      padding: const EdgeInsets.fromLTRB(28, 60, 28, 20),
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
                    'Command Center',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          _buildStatsRow(context),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
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
            _buildStatItem(
              'Active',
              activeShops.toString(),
              Icons.check_circle_rounded,
            ),
            const SizedBox(width: 40),
            _buildStatItem(
              'Total',
              totalShops.toString(),
              Icons.store_mall_directory_rounded,
            ),
            const SizedBox(width: 40),
            _buildStatItem('Growth', '+12%', Icons.trending_up_rounded),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.6)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.2,
        ),
        delegate: SliverChildListDelegate([
          _buildActionCard(
            context,
            'Add Shop',
            Icons.add_business_rounded,
            Theme.of(context).primaryColor,
            () {
              AppNavigator.push(context, const CreateShopScreen());
            },
          ),
          _buildActionCard(
            context,
            'Analytics',
            Icons.bar_chart_rounded,
            Colors.orange,
            () {},
          ),
          _buildActionCard(
            context,
            'Inventory',
            Icons.inventory_2_rounded,
            Colors.blue,
            () {},
          ),
          _buildActionCard(
            context,
            'Support',
            Icons.headset_mic_rounded,
            Colors.purple,
            () {},
          ),
        ]),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.1), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverSkeletonList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.68,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
              ),
            ),
            child: const ShimmerEffect(),
          ),
          childCount: 4,
        ),
      ),
    );
  }

  Widget _buildSliverShopList(BuildContext context, List<Shop> shops) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.68,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final shop = shops[index];
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 400 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.95 + (0.05 * value),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: ShopCard(
              shop: shop,
              onTap: () => AppNavigator.push(
                context,
                BlocProvider.value(
                  value: context.read<VendorShopCubit>(),
                  child: ShopDetailsScreen(shop: shop),
                ),
              ),
            ),
          );
        }, childCount: shops.length),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 180,
            width: 180,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.store_mall_directory_rounded,
                  size: 80,
                  color: theme.primaryColor.withValues(alpha: 0.2),
                ),
                Icon(
                  Icons.add_business_rounded,
                  size: 40,
                  color: theme.primaryColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Ready for your first shop?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Establish your retail presence and start managing your inventory with ease.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () {
              AppNavigator.push(context, const CreateShopScreen());
            },
            icon: const Icon(Icons.rocket_launch_rounded),
            label: const Text(
              'Establish Digital Shop',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              shadowColor: theme.primaryColor.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 80,
            color: Colors.red.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Sync Interrupted',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We encountered a problem while synchronizing your data. Please try again later.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 32),
          TextButton.icon(
            onPressed: () => context.read<VendorShopCubit>().fetchShops(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text(
              'RETRY SYNC',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: theme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
