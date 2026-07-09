import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/enums/wishlist_status.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/models/data_models/user.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/views/screens/auth/view/login_screen.dart';
import 'package:nearvendorapp/views/screens/wishlist/create_wish_screen/view/create_wish_screen.dart';
import 'package:nearvendorapp/views/screens/wishlist/cubit/user_wishlist_cubit.dart';
import 'package:nearvendorapp/views/screens/wishlist/widgets/my_wishes_view.dart';

class WishlistMainScreen extends StatelessWidget {
  const WishlistMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<User?>(
      valueListenable: AppData().userNotifier,
      builder: (context, user, child) {
        if (user == null) {
          return Scaffold(
            appBar: _buildAppBar(),
            body: const _GuestStateView(),
          );
        }

        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return BlocProvider(
          create: (context) => UserWishlistCubit()..getMyWishlists(),
          child: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: _buildAppBar(
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: _SegmentedTabBar(isDark: isDark, theme: theme),
                  ),
                ),
              ),
              body: Stack(
                children: [
                  const TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      MyWishesView(filterStatus: WishlistStatus.pending),
                      MyWishesView(filterStatus: WishlistStatus.fulfilled),
                    ],
                  ),
                  Positioned(
                    bottom: 10,
                    right: 24,
                    child: SafeArea(
                      top: false,
                      child: Builder(
                        builder: (context) => FloatingActionButton(
                          onPressed: () => CreateWishScreen.push(context),
                          child: const Icon(Icons.add),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar({PreferredSizeWidget? bottom}) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'My Wishes',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      bottom: bottom,
    );
  }
}

class _SegmentedTabBar extends StatefulWidget {
  final bool isDark;
  final ThemeData theme;

  const _SegmentedTabBar({required this.isDark, required this.theme});

  @override
  State<_SegmentedTabBar> createState() => _SegmentedTabBarState();
}

class _SegmentedTabBarState extends State<_SegmentedTabBar> {
  static const _labels = ['Active', 'Completed'];
  static const _height = 52.0;
  static const _padding = 5.0;

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) =>
          _buildTrack(context, controller, controller.index),
    );
  }

  Widget _buildTrack(
    BuildContext context,
    TabController controller,
    int selected,
  ) {
    final isDark = widget.isDark;
    final primary = widget.theme.primaryColor;

    // Match bottom bar: white pill with blur
    final trackColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.92);

    // Match bottom bar selected highlight: primary @ 12% opacity
    final pillColor = primary.withValues(alpha: isDark ? 0.18 : 0.12);

    final activeTextColor = primary;
    final inactiveTextColor = isDark ? Colors.white38 : const Color(0xFF8E8E93);

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: _height,
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(999),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          padding: const EdgeInsets.all(_padding),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final pillWidth = totalWidth / _labels.length;
              final pillLeft = selected * pillWidth;

              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOutCubic,
                    left: pillLeft,
                    top: 0,
                    width: pillWidth,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: pillColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  // Labels
                  Positioned.fill(
                    child: Row(
                      children: List.generate(_labels.length, (i) {
                        final isActive = i == selected;
                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => controller.animateTo(i),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Small primary dot — matches bottom bar active indicator feel
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: isActive ? 1.0 : 0.0,
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: BoxDecoration(
                                      color: primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: isActive
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isActive
                                        ? activeTextColor
                                        : inactiveTextColor,
                                    letterSpacing: -0.1,
                                  ),
                                  child: Text(_labels[i]),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GuestStateView extends StatelessWidget {
  const _GuestStateView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_person_outlined,
              size: 80,
              color: ColorName.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Sign In Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Create a wish list to alert local vendors when you can't find what you need. Please sign in to continue.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => AppNavigator.push(context, const LoginScreen()),
              style: ElevatedButton.styleFrom(elevation: 0),
              child: const Text(
                'Sign In / Register',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
