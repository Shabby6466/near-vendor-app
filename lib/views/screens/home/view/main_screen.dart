import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/views/screens/home/cubit/main_screen_cubit.dart';
import 'package:nearvendorapp/views/screens/home/view/home_screen.dart';
import 'package:nearvendorapp/views/screens/home/view/coming_soon_screen.dart';
import 'package:nearvendorapp/views/screens/home/widgets/custom_bottom_bar.dart';
import 'package:nearvendorapp/views/screens/search/view/search_screen.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/screens/vendor_dashboard_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => MainScreenCubit(0))],
      child: BlocBuilder<MainScreenCubit, int>(
        builder: (context, currentIndex) {
          return Scaffold(
            extendBody: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            body: IndexedStack(
              index: currentIndex,
              children: [
                const SearchScreen(),
                const HomeScreen(),
                ComingSoonScreen(
                  title: 'Map View',
                  iconPath: Assets.icons.mapIcon.path,
                ),
                ComingSoonScreen(
                  title: 'Chat Support',
                  iconPath: Assets.icons.profileIcon.path,
                ),
                const VendorDashboardScreen(),
              ],
            ),
            bottomNavigationBar: CustomBottomBar(
              currentIndex: currentIndex,
              onTap: (index) => context.read<MainScreenCubit>().switchTab(index),
            ),
          );
        },
      ),
    );
  }
}
