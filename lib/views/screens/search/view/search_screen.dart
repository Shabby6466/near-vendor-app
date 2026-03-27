import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/profile/view/profile_screen.dart';
import 'package:nearvendorapp/views/screens/search/view/visual_search_screen.dart';
import 'package:nearvendorapp/views/widgets/circular_cached_network_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Camera Search', 'Audio Search'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(context),
            SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
            _buildSearchBar(context),
            SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
            _buildFilterChips(context),
            SizedBox(height: AppSpacing.largeVerticalSpacing(context)),
            _buildRecentSearchHeader(context),
            SizedBox(height: AppSpacing.smallVerticalSpacing(context)),
            _buildRecentSearchList(context),
            SizedBox(height: AppSpacing.extraLargeVerticalSpacing(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.mediumHorizontalSpacing(context),
        vertical: 12.0,
      ),
      child: BlocBuilder<SessionCubit, SessionState>(
        builder: (context, state) {
          final locationText =
              state.cityName ??
              (state.latitude != null && state.longitude != null
                  ? '${state.latitude!.toStringAsFixed(4)}, ${state.longitude!.toStringAsFixed(4)}'
                  : 'Select Location');

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.read<SessionCubit>().updateLocation();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Current Location',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color?.withValues(
                              alpha: 0.5,
                            ),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: theme.primaryColor.withValues(alpha: .5),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          locationText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleMedium?.color,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Profile Section (Moved from Home)
              const _ProfileHeader(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.mediumHorizontalSpacing(context),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isDark
              ? Border.all(color: theme.dividerColor.withValues(alpha: 0.1))
              : Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          autofocus: false,
          style: const TextStyle(fontFamily: 'Poppins'),
          decoration: InputDecoration(
            hintText: 'Search Item',
            hintStyle: TextStyle(
              color: theme.textTheme.bodySmall!.color!.withValues(alpha: 0.4),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: theme.iconTheme.color?.withValues(alpha: 0.5),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VisualSearchScreen(),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: theme.iconTheme.color?.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.mic_none,
                  color: theme.iconTheme.color?.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 16),
              ],
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.mediumHorizontalSpacing(context),
      ),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          IconData? icon;
          if (filter == 'Camera Search') icon = Icons.camera_enhance_outlined;
          if (filter == 'Audio Search') icon = Icons.mic_none_outlined;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                if (filter == 'Camera Search') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VisualSearchScreen(),
                    ),
                  );
                } else {
                  setState(() {
                    selectedFilter = filter;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? theme.primaryColor : theme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? theme.primaryColor
                        : (isDark
                              ? theme.dividerColor.withValues(alpha: 0.1)
                              : Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : theme.iconTheme.color?.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      filter,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: isSelected
                            ? Colors.white
                            : theme.textTheme.bodyMedium?.color,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentSearchHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.mediumHorizontalSpacing(context),
      ),
      child: Text(
        'Recent Search',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildRecentSearchList(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 250,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.mediumHorizontalSpacing(context),
        ),
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final title = index == 0 ? 'MasleDar Fries' : 'WJNC #9 : Gator';
          final imageUrl = index == 0
              ? 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=400'
              : 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&q=80&w=400';
          return SizedBox(
            width: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: theme.dividerColor.withValues(alpha: 0.05),
                        child: Center(
                          child: Icon(
                            Icons.map,
                            size: 40,
                            color: theme.iconTheme.color?.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  'NYC, USA',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.5,
                    ),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        final String name = state.userName ?? 'Guest';

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            AppNavigator.push(context, const ProfileScreen());
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hello',
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.5,
                      ),
                      fontSize: 11,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    name,
                    style: TextStyle(
                      color: theme.textTheme.titleMedium?.color,
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: CircularCachedNetworkImage(
                  imageUrl: state.photoUrl,
                  size: 36,
                  placeholder: Assets.icons.profileIcon.svg(
                    height: 18,
                    width: 18,
                    colorFilter: ColorFilter.mode(
                      theme.primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
