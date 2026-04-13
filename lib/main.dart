import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/utils/globals.dart';
import 'package:nearvendorapp/utils/hive/hive_manager.dart';
import 'package:nearvendorapp/views/screens/home/view/main_screen.dart';
import 'package:nearvendorapp/views/screens/onboarding/views/welcome_screen.dart';
import 'package:upgrader/upgrader.dart';
import 'package:nearvendorapp/utils/app_theme_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:nearvendorapp/cubits/connectivity/connectivity_cubit.dart';
import 'package:nearvendorapp/views/screens/common/no_internet_screen.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await HiveManager.init();
    await dotenv.load(fileName: ".env");
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
      ],
      child: BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
        builder: (context, connectivity) {
          return BlocBuilder<SessionCubit, SessionState>(
            builder: (context, state) {
              final isApprovedVendor =
                  state.isVendor && state.vendorStatus == 'APPROVED';

              Widget home;
              if (connectivity == ConnectivityStatus.disconnected) {
                home = NoInternetScreen(
                  onRetry: () => context.read<ConnectivityCubit>().retry(),
                );
              } else {
                home = (state.status == AuthStatus.authenticated ||
                        state.hasOnboarded)
                    ? const MainScreen()
                    : const WelcomeScreen();
              }

              return MaterialApp(
                navigatorKey: navigatorKey,
                debugShowCheckedModeBanner: false,
                themeMode: ThemeMode.system,
                theme: isApprovedVendor
                    ? AppThemeData.vendorLightTheme
                    : AppThemeData.normalLightTheme,
                darkTheme: isApprovedVendor
                    ? AppThemeData.vendorDarkTheme
                    : AppThemeData.normalDarkTheme,
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
