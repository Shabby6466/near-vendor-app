import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/search/search_cubit.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/search/view/visual_search_screen.dart';

class SearchBarField extends StatefulWidget {
  const SearchBarField({super.key});

  @override
  State<SearchBarField> createState() => _SearchBarFieldState();
}

class _SearchBarFieldState extends State<SearchBarField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final sessionState = context.read<SessionCubit>().state;
    final lat = sessionState.latitude ?? 0.0;
    final lon = sessionState.longitude ?? 0.0;

    context.read<SearchCubit>().searchItems(
          lat: lat,
          lon: lon,
          query: query,
        );
  }

  @override
  Widget build(BuildContext context) {
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
          controller: _controller,
          autofocus: false,
          style: const TextStyle(fontFamily: 'Poppins'),
          onSubmitted: _onSearch,
          onChanged: (value) {
            if (value.isEmpty) {
              context.read<SearchCubit>().clearSearch();
            }
          },
          decoration: InputDecoration(
            hintText: 'Search Item',
            hintStyle: TextStyle(
              color: theme.textTheme.bodySmall!.color!.withValues(alpha: 0.4),
            ),
            prefixIcon: IconButton(
              icon: Icon(
                Icons.search,
                color: theme.iconTheme.color?.withValues(alpha: 0.5),
              ),
              onPressed: () => _onSearch(_controller.text),
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
}
