import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/data_models/app_location.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/views/screens/search/cubit/search_cubit.dart';
import 'package:nearvendorapp/views/screens/search/widgets/search_bar_field.dart';
import 'package:nearvendorapp/views/screens/search/widgets/search_results_list.dart';
import 'package:nearvendorapp/views/widgets/location_display_row.dart';

class SearchResultsScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchResultsScreen({super.key, this.initialQuery});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey<SearchBarFieldState> _searchBarKey =
      GlobalKey<SearchBarFieldState>();

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performInitialSearch(widget.initialQuery!);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }
  }

  void _performInitialSearch(String query) {
    final location = AppData().location;
    _searchBarKey.currentState?.setQuery(query);
    if (location == null) return;
    context.read<SearchCubit>().searchItems(
      lat: location.latitude,
      lon: location.longitude,
      query: query,
    );
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _SearchResultsLocationListener(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back_rounded),
                          tooltip: 'Back',
                        ),
                        Expanded(
                          child: Text(
                            'Search',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: LocationDisplayRow(
                        label: 'Searching near',
                        compact: true,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),
              const SizedBox(height: 8),
              SearchBarField(
                key: _searchBarKey,
                focusNode: _searchFocusNode,
                initialQuery: widget.initialQuery,
                autofocus: widget.initialQuery == null,
              ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<SearchCubit, SearchState>(
                  builder: (context, state) {
                    if (state is SearchInitial) {
                      return _buildIdleState(context);
                    }

                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      children: [
                        AnimatedSwitcher(
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
                          child: const SearchResultsList(
                            key: ValueKey('search_results'),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdleState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 56,
              color: isDark ? Colors.white24 : Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Search for items nearby',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                ),
            ),
            const SizedBox(height: 8),
            Text(
              'Type what you need and press search to see matches from local vendors.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white54 : Colors.black54,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultsLocationListener extends StatefulWidget {
  final Widget child;

  const _SearchResultsLocationListener({required this.child});

  @override
  State<_SearchResultsLocationListener> createState() =>
      _SearchResultsLocationListenerState();
}

class _SearchResultsLocationListenerState
    extends State<_SearchResultsLocationListener> {
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
            if (!mounted) return;
            final searchCubit = context.read<SearchCubit>();
            final searchState = searchCubit.state;
            if (searchState is SearchSuccess && searchState.query != null) {
              searchCubit.searchItems(
                lat: location.latitude,
                lon: location.longitude,
                query: searchState.query!,
              );
            }
          });
        }
        return child!;
      },
      child: widget.child,
    );
  }
}
