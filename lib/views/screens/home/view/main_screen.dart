import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/constants/default_location.dart';
import 'package:nearvendorapp/views/screens/home/cubit/main_screen_cubit.dart';
import 'package:nearvendorapp/views/screens/home/cubit/map_cubit.dart';
import 'package:nearvendorapp/views/screens/home/view/home_screen.dart';
import 'package:nearvendorapp/views/screens/home/view/map_screen.dart';
import 'package:nearvendorapp/views/screens/home/widgets/custom_bottom_bar.dart';
import 'package:nearvendorapp/views/screens/search/view/search_screen.dart';
import 'package:nearvendorapp/views/screens/wishlist/view/wishlist_main_screen.dart';
import 'package:nearvendorapp/views/widgets/lazy_load_wrapper.dart';

class MainScreen extends StatelessWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => MainScreenCubit(initialIndex)),
      ],
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
                LazyLoadWrapper(
                  isVisible: currentIndex == 2,
                  child: ValueListenableBuilder(
                    valueListenable: AppData().locationNotifier,
                    builder: (context, appLocation, _) {
                      final lat =
                          appLocation?.latitude ?? DefaultLocation.latitude;
                      final lon =
                          appLocation?.longitude ?? DefaultLocation.longitude;
                      return BlocProvider(
                        create: (context) => MapCubit(lat: lat, lon: lon),
                        child: MapScreen(initialLat: lat, initialLon: lon),
                      );
                    },
                  ),
                ),
                LazyLoadWrapper(
                  isVisible: currentIndex == 3,
                  child: const WishlistMainScreen(),
                ),
              ],
            ),
            bottomNavigationBar: CustomBottomBar(
              currentIndex: currentIndex,
              onTap: (index) =>
                  context.read<MainScreenCubit>().switchTab(index),
            ),
          );
        },
      ),
    );
  }
}
