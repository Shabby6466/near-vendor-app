import 'package:flutter/material.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/search/view/visual_search_screen.dart';

class SearchFilterChips extends StatefulWidget {
  const SearchFilterChips({super.key});

  @override
  State<SearchFilterChips> createState() => _SearchFilterChipsState();
}

class _SearchFilterChipsState extends State<SearchFilterChips> {
  String selectedFilter = 'All';
  final List<String> filters = ['Text', 'Camera Search'];

  @override
  Widget build(BuildContext context) {
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

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                if (filter == 'Camera Search') {
                  AppNavigator.push(context, VisualSearchScreen());
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
}
