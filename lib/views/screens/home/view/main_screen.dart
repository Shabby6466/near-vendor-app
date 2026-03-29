import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/views/screens/home/cubit/main_screen_cubit.dart';
import 'package:nearvendorapp/views/screens/home/view/home_screen.dart';
import 'package:nearvendorapp/views/screens/home/view/coming_soon_screen.dart';
import 'package:nearvendorapp/views/screens/home/widgets/custom_bottom_bar.dart';
import 'package:nearvendorapp/views/screens/search/view/search_screen.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/screens/vendor_dashboard_screen.dart';

import 'package:nearvendorapp/views/screens/home/cubit/map_cubit.dart';
import 'package:nearvendorapp/views/screens/home/view/map_screen.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/views/widgets/lazy_load_wrapper.dart';

class MainScreen extends StatelessWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => MainScreenCubit(initialIndex))],
      child: BlocBuilder<MainScreenCubit, int>(
        builder: (context, currentIndex) {
          return Scaffold(
            extendBody: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            body: IndexedStack(
              index: currentIndex,
              children: [
                LazyLoadWrapper(
                  isVisible: currentIndex == 0,
                  child: const SearchScreen(),
                ),
                LazyLoadWrapper(
                  isVisible: currentIndex == 1,
                  child: const HomeScreen(),
                ),
                BlocBuilder<SessionCubit, SessionState>(
                  builder: (context, session) {
                    return BlocProvider(
                      create: (context) => MapCubit(
                        lat: session.latitude ?? 33.68,
                        lon: session.longitude ?? 73.04,
                      ),
                      child: MapScreen(
                        initialLat: session.latitude ?? 33.68,
                        initialLon: session.longitude ?? 73.04,
                      ),
                    );
                  },
                ),
                ComingSoonScreen(
                  title: 'Chat Support',
                  iconPath: Assets.icons.profileIcon.path,
                ),
                LazyLoadWrapper(
                  isVisible: currentIndex == 4,
                  child: const VendorDashboardScreen(),
                ),
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
