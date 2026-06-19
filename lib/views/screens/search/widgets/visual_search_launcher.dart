import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/views/screens/search/cubit/visual_search_cubit.dart';
import 'package:nearvendorapp/views/screens/search/view/visual_search_screen.dart';

class VisualSearchLauncher {
  VisualSearchLauncher._();

  static void showPicker(BuildContext context) {
    HapticFeedback.mediumImpact();
    AppNavigator.push(
      context,
      BlocProvider(
        create: (_) => VisualSearchCubit(),
        child: const VisualSearchScreen(),
      ),
    );
  }
}
