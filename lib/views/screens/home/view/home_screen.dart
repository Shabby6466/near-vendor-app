import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/home/cubit/home_screen_cubit.dart';
import 'package:nearvendorapp/views/screens/home/widgets/category_selector.dart';
import 'package:nearvendorapp/views/screens/home/widgets/shop_grid.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/views/screens/home/cubit/map_cubit.dart';
import 'package:nearvendorapp/views/screens/home/view/map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeScreenCubit(),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          return AppScaffold(
            extendBody: true,
            bgColor: theme.scaffoldBackgroundColor,
            body: Stack(
              children: [
                Opacity(
                  opacity: isDark ? 0.15 : 0.45,
                  child: Image.asset(
                    Assets.images.nearVendorRightCut.path,
                    color: isDark
                        ? theme.primaryColor.withValues(alpha: (0.5))
                        : null,
                    colorBlendMode: isDark ? BlendMode.srcIn : null,
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: RefreshIndicator(
                    onRefresh: () =>
                        context.read<HomeScreenCubit>().refreshShops(),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: AppSpacing.smallVerticalSpacing(
                                  context,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      AppSpacing.mediumHorizontalSpacing(
                                        context,
                                      ),
                                ),
                                child: BlocBuilder<SessionCubit, SessionState>(
                                  builder: (context, state) {
                                    final isGuest =
                                        state.status == AuthStatus.guest;
                                    final firstName =
                                        state.userName?.split(' ').first ?? '';

                                    return Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                isGuest
                                                    ? 'Discover Shops'
                                                    : 'Hello, $firstName',
                                                style: theme
                                                    .textTheme
                                                    .titleLarge
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      letterSpacing: -0.5,
                                                    ),
                                              ),
                                              Text(
                                                isGuest
                                                    ? 'Find specialized vendors near you'
                                                    : 'Find local vendors near you',
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: theme
                                                          .textTheme
                                                          .bodySmall
                                                          ?.color
                                                          ?.withValues(
                                                            alpha: 0.6,
                                                          ),
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Assets.icons.nearVendorBlueText.svg(
                                          height: 24,
                                          colorFilter: ColorFilter.mode(
                                            theme.primaryColor,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              SizedBox(
                                height: AppSpacing.smallVerticalSpacing(
                                  context,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      AppSpacing.mediumHorizontalSpacing(
                                        context,
                                      ),
                                ),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: theme.cardColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: isDark ? 0.2 : 0.05,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: isDark
                                          ? theme.dividerColor.withValues(
                                              alpha: 0.1,
                                            )
                                          : Colors.grey.shade100,
                                    ),
                                  ),
                                  child: TextField(
                                    onSubmitted: (value) {
                                      if (value.isNotEmpty) {
                                        context
                                            .read<HomeScreenCubit>()
                                            .searchShops(value);
                                      } else {
                                        context
                                            .read<HomeScreenCubit>()
                                            .clearSearch();
                                      }
                                    },
                                    onChanged: (value) {
                                      if (value.isEmpty) {
                                        context
                                            .read<HomeScreenCubit>()
                                            .clearSearch();
                                      }
                                    },
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                    ),
                                    decoration: InputDecoration(
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Assets.icons.searchIcon.svg(
                                          height: 18,
                                          colorFilter: ColorFilter.mode(
                                            theme.iconTheme.color?.withValues(
                                                  alpha: 0.4,
                                                ) ??
                                                Colors.grey,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                      hintText: 'Search Shops Near You',
                                      hintStyle: TextStyle(
                                        color: theme.textTheme.bodySmall!.color!
                                            .withValues(alpha: 0.4),
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: AppSpacing.smallVerticalSpacing(
                                  context,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      AppSpacing.mediumHorizontalSpacing(
                                        context,
                                      ),
                                ),
                                child: Container(
                                  width: double.infinity,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.primaryColor,
                                        theme.primaryColor.withValues(
                                          alpha: 0.7,
                                        ),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.primaryColor.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 12,
                                        right: 16,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Text(
                                            'Sponsored',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Center(
                                        child: Text(
                                          'Premium Banner Ad',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w800,
                                            fontSize: 20,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: AppSpacing.mediumVerticalSpacing(
                                  context,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      AppSpacing.mediumHorizontalSpacing(
                                        context,
                                      ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Nearby Vendors',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -0.5,
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    BlocBuilder<
                                      HomeScreenCubit,
                                      HomeScreenState
                                    >(
                                      builder: (context, state) {
                                        if (state is HomeScreenSuccess) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: theme.primaryColor
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${state.shops.length}',
                                              style: TextStyle(
                                                color: theme.primaryColor,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: AppSpacing.smallVerticalSpacing(
                                  context,
                                ),
                              ),
                              const CategorySelector(),
                            ],
                          ),
                        ),
                        const ShopGrid(),
                      ],
                    ),
                  ),
                ),
                // Floating Map Button
                Positioned(
                  bottom: 100,
                  right: 20,
                  child: FloatingActionButton.extended(
                    heroTag: 'home_map_btn',
                    onPressed: () => _openMapBottomSheet(context),
                    backgroundColor: theme.primaryColor,
                    icon: const Icon(Icons.map_outlined, color: Colors.white),
                    label: const Text(
                      'Search on Map',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openMapBottomSheet(BuildContext context) {
    final session = context.read<SessionCubit>().state;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (context) => MapCubit(
          lat: session.latitude ?? 33.68,
          lon: session.longitude ?? 73.04,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: MapScreen(
              initialLat: session.latitude ?? 33.68,
              initialLon: session.longitude ?? 73.04,
            ),
          ),
        ),
      ),
    );
  }
}
