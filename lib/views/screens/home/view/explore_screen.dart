import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/models/data_models/user.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/theme/app_spacing.dart';
import 'package:nearvendorapp/views/screens/home/cubit/explore_screen_cubit.dart';
import 'package:nearvendorapp/views/screens/home/widgets/category_selector.dart';
import 'package:nearvendorapp/views/screens/home/widgets/shop_grid.dart';
import 'package:nearvendorapp/views/widgets/app_search_bar.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExploreScreenCubit(),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);

          return Scaffold(
              body: SafeArea(
                bottom: false,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 200) {
                      context.read<ExploreScreenCubit>().loadNextPage();
                    }
                    return false;
                  },
                  child: RefreshIndicator(
                  onRefresh: () =>
                      context.read<ExploreScreenCubit>().refreshShops(),
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
                              height: AppSpacing.smallVerticalSpacing(context),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.mediumHorizontalSpacing(
                                  context,
                                ),
                              ),
                              child: ValueListenableBuilder<User?>(
                                valueListenable: AppData().userNotifier,
                                builder: (context, user, _) {
                                  final isGuest = user == null;
                                  final firstName =
                                      user?.fullName?.split(' ').first ?? '';

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
                                              style: theme.textTheme.titleLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: -0.5,
                                                  ),
                                            ),
                                            Text(
                                              isGuest
                                                  ? 'Find vendors near you'
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
                                      Assets.icons.nearVendorText.svg(
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
                              height:
                                  AppSpacing.mediumVerticalSpacing(context) *
                                  1.6,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.mediumHorizontalSpacing(
                                  context,
                                ),
                              ),
                              child: AppSearchBar(
                                hintText: 'Search Shops Near You',
                                padding: EdgeInsets.zero,
                                onSearch: (value) {
                                  if (value.isNotEmpty) {
                                    context
                                        .read<ExploreScreenCubit>()
                                        .searchShops(value);
                                  } else {
                                    context
                                        .read<ExploreScreenCubit>()
                                        .clearSearch();
                                  }
                                },
                                onChanged: (value) {
                                  if (value.isEmpty) {
                                    context
                                        .read<ExploreScreenCubit>()
                                        .clearSearch();
                                  }
                                },
                                onClear: () {
                                  context
                                      .read<ExploreScreenCubit>()
                                      .clearSearch();
                                },
                              ),
                            ),
                            SizedBox(
                              height:
                                  AppSpacing.mediumVerticalSpacing(context) *
                                  1.5,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    AppSpacing.mediumHorizontalSpacing(
                                      context,
                                    ) *
                                    1.5,
                              ),
                              child: Container(
                                width: double.infinity,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.primaryColor.withValues(alpha: 0.1),
                                      theme.primaryColor.withValues(
                                        alpha: 0.05,
                                      ),
                                    ],
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    'assets/images/header_img.png',
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height:
                                  AppSpacing.mediumVerticalSpacing(context) *
                                  1.5,
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
            ),
          );
        },
      ),
    );
  }
}
