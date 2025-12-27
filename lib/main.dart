import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/gen/fonts.gen.dart';
import 'package:nearvendorapp/utils/globals.dart';
import 'package:nearvendorapp/utils/hive/hive_manager.dart';
import 'package:nearvendorapp/views/screens/home/view/main_screen.dart';
import 'package:nearvendorapp/views/screens/onboarding/views/welcome_screen.dart';
import 'package:upgrader/upgrader.dart';

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
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        highlightColor: ColorName.primary.withValues(alpha: 0.02),
        splashColor: ColorName.primary.withValues(alpha: 0.05),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leadingWidth: 45,
          centerTitle: true,
          scrolledUnderElevation: 0,
        ),
        primarySwatch: ColorName.primary,
        colorScheme: ColorScheme.fromSwatch(
          brightness: Brightness.dark,
          primarySwatch: ColorName.primary,
          accentColor: ColorName.primary,
        ),
        fontFamily: FontFamily.poppins,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
          bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        ),
        dividerTheme: const DividerThemeData(color: ColorName.primary),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorName.secondary.shade400,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            textStyle: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.black),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
              side: const BorderSide(color: ColorName.primary),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.black.withValues(alpha: 0.7)),
          hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.5)),
          filled: false,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
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
        // child: CurrentUserStorage.getUserAuthToken() != null
        //     ? const MainScreen()
        //     : const WelcomeScreen(),
        child: const MainScreen(),
      ),
    );
  }
}

// FirebaseImp class removed due to iOS dependency conflicts with mobile_scanner
