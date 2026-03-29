import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/search/search_cubit.dart';
import 'package:nearvendorapp/views/screens/search/widgets/recent_items_section.dart';
import 'package:nearvendorapp/views/screens/search/widgets/recent_search_section.dart';
import 'package:nearvendorapp/views/screens/search/widgets/search_bar_field.dart';
import 'package:nearvendorapp/views/screens/search/widgets/search_header.dart';
import 'package:nearvendorapp/views/screens/search/widgets/search_results_list.dart';

import 'package:flutter_animate/flutter_animate.dart' hide ShimmerEffect;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => SearchCubit(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              const SearchHeader().animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 16),
                    const SearchBarField().animate().fadeIn(delay: 80.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 24),
                    
                    BlocBuilder<SearchCubit, SearchState>(
                      builder: (context, state) {
                        return AnimatedSwitcher(
                          duration: 300.ms,
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.05),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: _buildStateContent(context, state),
                        );
                      },
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateContent(BuildContext context, SearchState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (state is SearchInitial) {
      return Column(
        key: const ValueKey('search_initial'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Discovery Chips Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Popular Categories',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildDiscoveryChip('Electronics', Icons.devices_other_rounded, theme),
                _buildDiscoveryChip('Fashion', Icons.checkroom_rounded, theme),
                _buildDiscoveryChip('Furniture', Icons.chair_rounded, theme),
                _buildDiscoveryChip('Groceries', Icons.shopping_basket_rounded, theme),
                _buildDiscoveryChip('Health', Icons.health_and_safety_rounded, theme),
              ],
            ),
          ).animate().fadeIn(delay: 350.ms).slideX(begin: 0.1, end: 0),
          
          const SizedBox(height: 32),
          const RecentSearchSection().animate().fadeIn(delay: 500.ms),
          const SizedBox(height: 32),
          const RecentItemsSection().animate().fadeIn(delay: 650.ms),
        ],
      );
    }
    
    return const SearchResultsList(key: ValueKey('search_results'));
  }

  Widget _buildDiscoveryChip(String label, IconData icon, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Future: Trigger search by category
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : theme.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.primaryColor.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : Colors.black87,
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

