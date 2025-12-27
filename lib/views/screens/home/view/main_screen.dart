import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/views/screens/home/cubit/main_screen_cubit.dart';
import 'package:nearvendorapp/views/screens/home/view/home_screen.dart';
import 'package:nearvendorapp/views/screens/home/widgets/custom_bottom_bar.dart';
import 'package:nearvendorapp/views/screens/profile/view/profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainScreenCubit(0),
      child: BlocBuilder<MainScreenCubit, int>(
        builder: (context, currentIndex) {
          return Scaffold(
            extendBody: true,
            backgroundColor: ColorName.white,
            body: [HomeScreen(), ProfileScreen()].elementAt(currentIndex),
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
