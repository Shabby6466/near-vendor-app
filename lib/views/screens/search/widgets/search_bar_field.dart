import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/utils/location_picker_launcher.dart';
import 'package:nearvendorapp/views/screens/search/cubit/search_cubit.dart';
import 'package:nearvendorapp/views/screens/search/widgets/visual_search_launcher.dart';
import 'package:nearvendorapp/views/widgets/app_search_bar.dart';

class SearchBarField extends StatefulWidget {
  final FocusNode? focusNode;
  final String? initialQuery;
  final bool autofocus;

  const SearchBarField({
    super.key,
    this.focusNode,
    this.initialQuery,
    this.autofocus = false,
  });

  @override
  State<SearchBarField> createState() => SearchBarFieldState();
}

class SearchBarFieldState extends State<SearchBarField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      if (mounted) setState(() => isFocused = _focusNode.hasFocus);
    });
  }

  void setQuery(String query) {
    _controller.text = query;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _onSearch(String query) async {
    HapticFeedback.mediumImpact();
    final location = await LocationPickerLauncher.ensureLocation(context);
    if (!mounted || location == null) return;

    context.read<SearchCubit>().searchItems(
      lat: location.latitude,
      lon: location.longitude,
      query: query,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppSearchBar(
      controller: _controller,
      focusNode: _focusNode,
      hintText: 'Search high-value items...',
      showVisualSearch: true,
      autofocus: widget.autofocus,
      onVisualSearchTap: () => VisualSearchLauncher.showPicker(context),
      onSearch: _onSearch,
      onChanged: (value) {
        setState(() {});
        if (value.isEmpty) {
          context.read<SearchCubit>().clearSearch();
        }
      },
      onClear: () {
        context.read<SearchCubit>().clearSearch();
      },
    );
  }
}
