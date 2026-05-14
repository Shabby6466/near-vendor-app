import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/enums/auth_status.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/utils/app_alerts.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/home/cubit/home_screen_cubit.dart';
import 'package:nearvendorapp/views/screens/home/widgets/category_selector.dart';
import 'package:nearvendorapp/views/screens/home/widgets/shop_grid.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:nearvendorapp/views/widgets/app_search_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeScreenCubit(),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);

          return BlocListener<HomeScreenCubit, HomeScreenState>(
            listenWhen: (previous, current) => current is HomeScreenNoLocation,
            listener: (context, state) {
              if (state is HomeScreenNoLocation) {
                AppAlerts.showErrorSnackBar(
                  context,
                  state.message,
                );
                AppBottomSheet.openLocationSet();
              }
            },
            child: AppScaffold(
              bgColor: theme.scaffoldBackgroundColor,
              body: SafeArea(
                bottom: false,
                child: RefreshIndicator(
                  onRefresh: () => context.read<HomeScreenCubit>().refreshShops(),
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
                                              style: theme.textTheme.titleLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w900,
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
                                                        ?.withValues(alpha: 0.6),
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
                                  AppSpacing.mediumVerticalSpacing(context) * 1.6,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    AppSpacing.mediumHorizontalSpacing(
                                  context,
                                ),
                              ),
                              child: AppSearchBar(
                                hintText: 'Search Shops Near You',
                                padding: EdgeInsets.zero,
                                onSearch: (value) {
                                  if (value.isNotEmpty) {
                                    context.read<HomeScreenCubit>().searchShops(
                                      value,
                                    );
                                  } else {
                                    context.read<HomeScreenCubit>().clearSearch();
                                  }
                                },
                                onChanged: (value) {
                                  if (value.isEmpty) {
                                    context.read<HomeScreenCubit>().clearSearch();
                                  }
                                },
                                onClear: () {
                                  context.read<HomeScreenCubit>().clearSearch();
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
                                      theme.primaryColor.withValues(alpha: 0.05),
                                    ],
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: theme.primaryColor.withValues(alpha: 0.2),
                                      ),
                                      child: Icon(
                                        Icons.location_on_outlined,
                                        size: 40,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Set Your Location',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Find vendors near you',
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        AppBottomSheet.openLocationSet();
                                      },
                                      child: Text(
                                        'SET',
                                        style: TextStyle(
                                          color: theme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
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
