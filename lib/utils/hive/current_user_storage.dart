import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:nearvendorapp/models/data_models/user.dart';
import 'package:nearvendorapp/utils/constants/hive_keys.dart';
import 'package:nearvendorapp/utils/hive/hive_manager.dart';

class CurrentUserStorage {
  CurrentUserStorage._();

  static Box get _userBox => HiveManager.currentUserBox;

  static Future<void> storeUserData(User? user) async {
    if (user == null) return;
    try {
      _userBox.put(HiveKeys.currentUserKey, user.toJson());
    } catch (e) {
      debugPrint('Error storing user data: $e');
    }
  }

  static User? getCurrentUser() {
    try {
      final userData = _userBox.get(
        HiveKeys.currentUserKey,
        defaultValue: null,
      );
      if (userData is Map) {
        return User.fromJson(userData);
      }
    } catch (e) {
      debugPrint('Error getting user ID: $e');
    }
    return null;
  }

  static Future<void> storeUserAuthToken(String token,
      String? refreshToken,) async {
    try {
      await _userBox.put(HiveKeys.currentUserAuthTokenKey, token);
      if (refreshToken != null) {
        await _userBox.put(HiveKeys.currentUserRefreshTokenKey, refreshToken);
      }
    } catch (e) {
      debugPrint('Error storing user data: $e');
    }
  }

  static String? getUserAuthToken() {
    return _userBox.get(
      HiveKeys.currentUserAuthTokenKey,
      defaultValue: null,
    )
    as String?;
  }

  static String? getUserRefreshAuthToken() {
    return _userBox.get(
      HiveKeys.currentUserRefreshTokenKey,
      defaultValue: null,
    )
    as String?;
  }
  static Future<void> clearUserData() async {
    try {
      await _userBox.delete(HiveKeys.currentUserKey);
      await _userBox.delete(HiveKeys.currentUserAuthTokenKey);
      await _userBox.delete(HiveKeys.currentUserRefreshTokenKey);
      await _userBox.delete(HiveKeys.vendorStatusKey);
    } catch (e) {
      debugPrint('Error clearing user data: $e');
    }
  }

  static Future<void> storeVendorStatus(String? status) async {
    try {
      if (status != null) {
        await _userBox.put(HiveKeys.vendorStatusKey, status);
      } else {
        await _userBox.delete(HiveKeys.vendorStatusKey);
      }
    } catch (e) {
      debugPrint('Error storing vendor status: $e');
    }
  }

  static String? getVendorStatus() {
    return _userBox.get(
      HiveKeys.vendorStatusKey,
      defaultValue: null,
    ) as String?;
  }

  static Future<void> setHasOnboarded(bool value) async {
    try {
      await _userBox.put(HiveKeys.hasOnboardedKey, value);
    } catch (e) {
      debugPrint('Error storing onboarding status: $e');
    }
  }

  static bool getHasOnboarded() {
    return _userBox.get(
      HiveKeys.hasOnboardedKey,
      defaultValue: false,
    ) as bool;
  }
}
