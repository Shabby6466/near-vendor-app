import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart' hide ShimmerEffect;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/enums/auth_status.dart';
import 'package:nearvendorapp/models/data_models/app_location.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/views/screens/auth/view/login_screen.dart';
import 'package:nearvendorapp/views/screens/home/cubit/main_screen_cubit.dart';
import 'package:nearvendorapp/views/screens/search/cubit/search_cubit.dart';
import 'package:nearvendorapp/views/screens/search/utils/search_navigation.dart';
import 'package:nearvendorapp/views/screens/search/widgets/recent_items_section.dart';
import 'package:nearvendorapp/views/screens/search/widgets/recent_search_section.dart';
import 'package:nearvendorapp/views/screens/search/widgets/search_bar_trigger.dart';
import 'package:nearvendorapp/views/screens/search/widgets/search_header.dart';
import 'package:nearvendorapp/views/screens/search/widgets/visual_search_launcher.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  void _openSearchResults() {
    SearchNavigation.openResults(context);
  }

  void _handleMakeAWish() {
    final session = context.read<SessionCubit>().state;
    if (session.status != AuthStatus.authenticated) {
      AppBottomSheet.showConfirmationBottomSheet(
        context: context,
        title: 'Sign In Required',
        message: 'You need to sign in to make a wish and alert local vendors.',
        confirmButtonText: 'Sign In',
        onConfirm: () {
          Navigator.pop(context);
          AppNavigator.push(context, const LoginScreen());
        },
      );
      return;
    }
    context.read<MainScreenCubit>().switchTab(3);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => SearchCubit(),
      child: _SearchLocationListener(
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                const SearchHeader()
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.2, end: 0),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [
                      const SizedBox(height: 16),
                      const SearchBarTrigger()
                          .animate()
                          .fadeIn(delay: 80.ms)
                          .slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 24),
                      _HowToSearchSection(
                        onExactSearch: _openSearchResults,
                        onVisualSearch: () =>
                            VisualSearchLauncher.showPicker(context),
                        onMakeAWish: _handleMakeAWish,
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 32),
                      const RecentSearchSection().animate().fadeIn(
                        delay: 500.ms,
                      ),
                      const SizedBox(height: 32),
                      const RecentItemsSection().animate().fadeIn(
                        delay: 650.ms,
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchLocationListener extends StatefulWidget {
  final Widget child;

  const _SearchLocationListener({required this.child});

  @override
  State<_SearchLocationListener> createState() =>
      _SearchLocationListenerState();
}

class _SearchLocationListenerState extends State<_SearchLocationListener> {
  double? _lastLat;
  double? _lastLon;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLocation?>(
      valueListenable: AppData().locationNotifier,
      builder: (context, location, child) {
        if (location != null &&
            (location.latitude != _lastLat || location.longitude != _lastLon)) {
          _lastLat = location.latitude;
          _lastLon = location.longitude;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.read<SearchCubit>().loadInitialData();
          });
        }
        return child!;
      },
      child: widget.child,
    );
  }
}

class _HowToSearchSection extends StatelessWidget {
  final VoidCallback onExactSearch;
  final VoidCallback onVisualSearch;
  final VoidCallback onMakeAWish;

  const _HowToSearchSection({
    required this.onExactSearch,
    required this.onVisualSearch,
    required this.onMakeAWish,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How to find what you need',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : theme.primaryColor.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.primaryColor.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              children: [
                _SearchTipItem(
                  icon: Icons.search_rounded,
                  title: 'Exact Search',
                  subtitle: 'Type the name of the product you are looking for',
                  theme: theme,
                  onTap: onExactSearch,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, thickness: 0.5),
                ),
                _SearchTipItem(
                  icon: Icons.camera_alt_rounded,
                  title: 'Visual Search',
                  subtitle: 'Search your product via photo',
                  theme: theme,
                  onTap: onVisualSearch,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, thickness: 0.5),
                ),
                _SearchTipItem(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Make a Wish',
                  subtitle: "Add unavailable items to your wish list",
                  theme: theme,
                  onTap: onMakeAWish,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchTipItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ThemeData theme;
  final Color? iconColor;
  final VoidCallback onTap;

  const _SearchTipItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.theme,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? theme.primaryColor).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? theme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black54,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: (isDark ? Colors.white : Colors.black).withValues(
                alpha: 0.2,
              ),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
