import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/utils/globals.dart';
import 'package:nearvendorapp/utils/hive/hive_manager.dart';
import 'package:nearvendorapp/views/screens/onboarding/views/welcome_screen.dart';
import 'package:upgrader/upgrader.dart';

import 'package:nearvendorapp/views/screens/home/view/main_screen.dart';
import 'package:nearvendorapp/utils/app_theme_data.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await HiveManager.init();
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
      ],
      child: BlocBuilder<SessionCubit, SessionState>(
        builder: (context, state) {
          final isVendor = state.isVendor;
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.system,
            theme: isVendor ? AppThemeData.vendorLightTheme : AppThemeData.normalLightTheme,
            darkTheme: isVendor ? AppThemeData.vendorDarkTheme : AppThemeData.normalDarkTheme,
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
              child: state.status == AuthStatus.authenticated
                  ? const MainScreen()
                  : const WelcomeScreen(),
            ),
          );
        },
      ),
    );
  }
}

// FirebaseImp class removed due to iOS dependency conflicts with mobile_scanner
