import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nearvendorapp/cubits/connectivity/connectivity_cubit.dart';
import 'package:nearvendorapp/firebase_options.dart';
import 'package:nearvendorapp/services/app_location_service.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/globals.dart';
import 'package:nearvendorapp/utils/hive/hive_manager.dart';
import 'package:nearvendorapp/utils/push_notification_controller.dart';
import 'package:nearvendorapp/utils/theme/app_theme_data.dart';
import 'package:nearvendorapp/views/screens/common/no_internet_screen.dart';
import 'package:nearvendorapp/views/screens/common/splash_screen.dart';
import 'package:nearvendorapp/views/screens/home/view/main_screen.dart';
import 'package:nearvendorapp/views/screens/onboarding/view/welcome_screen.dart';
import 'package:nearvendorapp/views/screens/profile_screen/cubit/profile_cubit.dart';
import 'package:upgrader/upgrader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await PushNotificationController.initPushNotifications();
  await HiveManager.init();
  await AppData().loadPersistedData();
  AppData().initializeSession();
  await AppLocationService.instance.resolvePlaceNameIfMissing();
  await dotenv.load();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ConnectivityCubit()),
        BlocProvider(create: (context) => ProfileCubit()),
      ],
      child: BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
        builder: (context, connectivity) {
          return MaterialApp(
            title: 'NearVendor',
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: AppThemeData.normalLightTheme,
            themeMode: ThemeMode.light,
            home: connectivity == ConnectivityStatus.disconnected
                ? NoInternetScreen(
                    onRetry: () => context.read<ConnectivityCubit>().retry(),
                  )
                : SplashScreen(
                    nextRoute: UpgradeAlert(
                      upgrader: Upgrader(
                        minAppVersion: '0.0.0',
                        durationUntilAlertAgain: const Duration(hours: 1),
                      ),
                      showIgnore: false,
                      showLater: false,
                      dialogStyle: Platform.isIOS
                          ? UpgradeDialogStyle.cupertino
                          : UpgradeDialogStyle.material,
                      child: (AppData().isLoggedIn || AppData().hasOnboarded)
                          ? const MainScreen()
                          : const WelcomeScreen(),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
