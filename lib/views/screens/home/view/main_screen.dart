import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/views/screens/home/cubit/main_screen_cubit.dart';
import 'package:nearvendorapp/views/screens/home/view/home_screen.dart';
import 'package:nearvendorapp/views/screens/home/view/coming_soon_screen.dart';
import 'package:nearvendorapp/views/screens/home/widgets/custom_bottom_bar.dart';
import 'package:nearvendorapp/views/screens/profile/view/profile_screen.dart';
import 'package:nearvendorapp/views/screens/search/view/search_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => MainScreenCubit(0)),
        BlocProvider(create: (context) => SessionCubit()..setGuest()),
      ],
      child: BlocBuilder<MainScreenCubit, int>(
        builder: (context, currentIndex) {
          return Scaffold(
            extendBody: true,
            backgroundColor: ColorName.white,
            body: [
              const HomeScreen(),
              ComingSoonScreen(
                title: 'Map View',
                iconPath: Assets.icons.mapIcon.path,
              ),
              const SearchScreen(),
              ComingSoonScreen(
                title: 'Chat Support',
                iconPath: Assets.icons.profileIcon.path,
              ),
              const ProfileScreen(),
            ].elementAt(currentIndex),
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
