import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nearvendorapp/cubits/connectivity/connectivity_cubit.dart';
import 'package:nearvendorapp/cubits/location/location_cubit.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/app_theme_data.dart';
import 'package:nearvendorapp/utils/globals.dart';
import 'package:nearvendorapp/utils/hive/hive_manager.dart';
import 'package:nearvendorapp/views/screens/common/no_internet_screen.dart';
import 'package:nearvendorapp/views/screens/home/view/main_screen.dart';
import 'package:nearvendorapp/views/screens/onboarding/views/welcome_screen.dart';
import 'package:nearvendorapp/views/screens/profile/cubit/profile_cubit/profile_cubit.dart';
import 'package:upgrader/upgrader.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await HiveManager.init();
    await AppData().loadHasOnboarded();
    await dotenv.load();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    runApp(const MainApp());
  }, (error, stack) {});
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SessionCubit()..initialize()),
        BlocProvider(create: (context) => ConnectivityCubit()),
        // ProfileCubit is app-level so LocationCubit can inject it
        BlocProvider(create: (context) => ProfileCubit()),
        BlocProvider(
          create: (context) =>
              LocationCubit(profileCubit: context.read<ProfileCubit>()),
        ),
      ],
      child: BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
        builder: (context, connectivity) {
          return ValueListenableBuilder<bool>(
            valueListenable: AppData().showMainScreenNotifier,
            builder: (context, showMain, child) {
              Widget home;
              if (connectivity == ConnectivityStatus.disconnected) {
                home = NoInternetScreen(
                  onRetry: () => context.read<ConnectivityCubit>().retry(),
                );
              } else {
                home = showMain ? const MainScreen() : const WelcomeScreen();
              }

              return MaterialApp(
                navigatorKey: navigatorKey,
                debugShowCheckedModeBanner: false,
                theme: AppThemeData.normalLightTheme,
                darkTheme: AppThemeData.normalDarkTheme,
                home: UpgradeAlert(
                  upgrader: Upgrader(
                    minAppVersion: '0.0.0',
                    durationUntilAlertAgain: const Duration(hours: 1),
                  ),
                  showIgnore: false,
                  showLater: false,
                  dialogStyle: Platform.isIOS
                      ? UpgradeDialogStyle.cupertino
                      : UpgradeDialogStyle.material,
                  child: home,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
