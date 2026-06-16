import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:nearvendorapp/services/auth_services.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/globals.dart';
import 'package:nearvendorapp/utils/ui/app_alerts.dart';

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
      await authServices.updateNotificationToken(null);
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      debugPrint('onLogout() error: $e');
    }
  }

  static void _handleMessage(RemoteMessage message) {
    if (message.messageId == _previousNotificationId) return;
    _previousNotificationId = message.messageId;
    try {
      // final notification = PushNotification.fromJson(message.data);

      // switch (notification.type) {
      //   case PushNotificationType.chat:
      //     if (notification.message?.senderProfile != null &&
      //         _openedChatScreen != notification.message?.sessionId) {
      //       AppNavigator.push(
      //         navigatorKey.currentContext!,
      //         ChatScreen(otherUser: notification.message?.senderProfile),
      //       );
      //     }

      //   case PushNotificationType.order:
      //     if (notification.orderId != null) {
      //       AppNavigator.push(
      //         navigatorKey.currentContext!,
      //         OrderDetailScreen(Order(id: notification.orderId)),
      //       );
      //     }
      //   case null:
      // }
    } catch (e) {
      debugPrint('_handleMessage $e');
    }
  }

  // ignore: use_setters_to_change_properties
  static void onChatScreenOpened(String chatId) {
    _openedChatScreen = chatId;
  }

  static void onChatScreenClosed() {
    _openedChatScreen = null;
  }
}
