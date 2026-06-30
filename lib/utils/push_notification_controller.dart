import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:nearvendorapp/services/auth_services.dart';
import 'package:nearvendorapp/services/shop_services.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/globals.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/ui/app_alerts.dart';
import 'package:nearvendorapp/views/screens/shop_detail_screen/view/shop_detail_screen.dart';

String? _previousNotificationId;

class PushNotificationController {
  PushNotificationController._();

  // ignore: unused_field
  static String? _openedChatScreen;

  static Future<void> initPushNotifications() async {
    final firebaseMessaging = FirebaseMessaging.instance;
    await firebaseMessaging.requestPermission();
    await firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await clearBadge();
    WidgetsBinding.instance.addObserver(_BadgeLifecycleObserver());

    firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessage(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleMessage(message);
    });

    FirebaseMessaging.onMessage.listen((message) {
      try {
        final notification = message.notification;
        if (notification != null && navigatorKey.currentContext != null) {
          AppAlerts.showInfo(
            navigatorKey.currentContext!,
            notification.body ?? '',
            title: notification.title ?? 'Notification',
          );
        }
      } catch (e) {
        debugPrint('FirebaseMessaging.onMessage error: $e');
      }
    });
  }

  static Future<void> updateNotificationToken() async {
    // Only call the API if the user is logged in
    if (!AppData().isLoggedIn) {
      debugPrint(
        'updateNotificationToken(): User is not logged in. Skipping FCM token sync.',
      );
      return;
    }

    final AuthServices authServices = AuthServices();
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      debugPrint('FCM Token---------------------$fcmToken');

      if (fcmToken != null) {
        await authServices.updateNotificationToken(fcmToken);
      }
    } catch (e) {
      debugPrint('updateNotificationToken() error: $e');
    }
  }

  static Future<void> onLogout() async {
    try {
      final AuthServices authServices = AuthServices();
      await authServices.deleteNotificationToken();
      await FirebaseMessaging.instance.deleteToken();
      await clearBadge();
    } catch (e) {
      debugPrint('onLogout() error: $e');
    }
  }

  static void _handleMessage(RemoteMessage message) {
    if (message.messageId == _previousNotificationId) return;
    _previousNotificationId = message.messageId;
    try {
      final data = message.data;
      final type = data['type'];

      if (type == 'review_comment') {
        final shopId = data['shopId'] as String?;
        if (shopId != null && navigatorKey.currentContext != null) {
          _navigateToShopReview(navigatorKey.currentContext!, shopId);
        }
      }
    } catch (e) {
      debugPrint('_handleMessage $e');
    }
  }

  static Future<void> _navigateToShopReview(
    BuildContext context,
    String shopId,
  ) async {
    final shopResponse = await ShopServices().getShopById(shopId);
    if (shopResponse.shop != null && context.mounted) {
      AppNavigator.push(context, ShopDetailScreen(shop: shopResponse.shop!));
    }
  }

  // ignore: use_setters_to_change_properties
  static void onChatScreenOpened(String chatId) {
    _openedChatScreen = chatId;
  }

  static void onChatScreenClosed() {
    _openedChatScreen = null;
  }

  static Future<void> clearBadge() async {
    try {
      if (await AppBadgePlus.isSupported()) {
        await AppBadgePlus.updateBadge(0);
      }
    } catch (e) {
      debugPrint('clearBadge() error: $e');
    }
  }
}

class _BadgeLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      PushNotificationController.clearBadge();
    }
  }
}
