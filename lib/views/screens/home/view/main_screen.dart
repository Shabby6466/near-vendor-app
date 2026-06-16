import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/services/app_location_service.dart';
import 'package:nearvendorapp/utils/push_notification_controller.dart';
import 'package:nearvendorapp/views/screens/home/cubit/main_screen_cubit.dart';
import 'package:nearvendorapp/views/screens/home/view/explore_screen.dart';
import 'package:nearvendorapp/views/screens/home/widgets/custom_bottom_bar.dart';
import 'package:nearvendorapp/views/screens/map_screen/view/map_screen.dart';
import 'package:nearvendorapp/views/screens/search/view/search_screen.dart';
import 'package:nearvendorapp/views/screens/wishlist/view/wishlist_main_screen.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';
import 'package:nearvendorapp/views/widgets/lazy_load_wrapper.dart';
import 'package:nearvendorapp/views/widgets/location_permission_sheet.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static bool _hasPromptedLocation = false;

  @override
  void initState() {
    super.initState();
    _checkLocation();
    PushNotificationController.updateNotificationToken();
  }

  void _checkLocation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 1), () async {
        if (!mounted) return;
        if (_hasPromptedLocation) return;
        final isResolved = await AppLocationService.instance
            .tryAutoResolveLocation();
        if (!isResolved && mounted) {
          _hasPromptedLocation = true;
          AppBottomSheet.showBottomSheet(
            context: context,
            child: const LocationPermissionSheet(),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => MainScreenCubit(widget.initialIndex)),
      ],
      child: BlocBuilder<MainScreenCubit, int>(
        builder: (context, currentIndex) {
          return Scaffold(
            extendBody: true,
            body: IndexedStack(
              index: currentIndex,
              children: [
                LazyLoadWrapper(
                  isVisible: currentIndex == 0,
                  child: const SearchScreen(),
                ),
                LazyLoadWrapper(
                  isVisible: currentIndex == 1,
                  child: const ExploreScreen(),
                ),
                LazyLoadWrapper(
                  isVisible: currentIndex == 2,
                  child: const MapScreen(),
                ),
                LazyLoadWrapper(
                  isVisible: currentIndex == 3,
                  child: const WishlistMainScreen(),
                ),
              ],
            ),
            bottomNavigationBar: SafeArea(
              top: false,
              left: false,
              right: false,
              child: CustomBottomBar(
                currentIndex: currentIndex,
                onTap: (index) =>
                    context.read<MainScreenCubit>().switchTab(index),
              ),
            ),
          );
        },
      ),
    );
  }
}
