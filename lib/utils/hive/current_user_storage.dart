import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:nearvendorapp/models/data_models/app_location.dart';
import 'package:nearvendorapp/models/data_models/user.dart';
import 'package:nearvendorapp/utils/constants/hive_keys.dart';
import 'package:nearvendorapp/utils/hive/hive_manager.dart';

class CurrentUserStorage {
  CurrentUserStorage._();

  static Box get _userBox => HiveManager.currentUserBox;
  static Box get _preferencesBox => HiveManager.preferencesBox;

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

  static Future<void> storeUserAuthToken(
    String token,
    String? refreshToken,
  ) async {
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
    return _userBox.get(HiveKeys.currentUserAuthTokenKey, defaultValue: null)
        as String?;
  }

  static String? getUserRefreshAuthToken() {
    return _userBox.get(HiveKeys.currentUserRefreshTokenKey, defaultValue: null)
        as String?;
  }

  static Future<void> clearUserData() async {
    try {
      await _userBox.delete(HiveKeys.currentUserKey);
      await _userBox.delete(HiveKeys.currentUserAuthTokenKey);
      await _userBox.delete(HiveKeys.currentUserRefreshTokenKey);
      await _userBox.delete(HiveKeys.lastLatitudeKey);
      await _userBox.delete(HiveKeys.lastLongitudeKey);
      await _userBox.delete(HiveKeys.lastLocationNameKey);
    } catch (e) {
      debugPrint('Error clearing user data: $e');
    }
  }

  static Future<void> setHasOnboarded(bool value) async {
    try {
      await _preferencesBox.put(HiveKeys.hasOnboardedKey, value);
    } catch (e) {
      debugPrint('Error storing onboarding status: $e');
    }
  }

  static bool getHasOnboarded() {
    return _preferencesBox.get(HiveKeys.hasOnboardedKey, defaultValue: false) as bool;
  }

  static Future<void> setDiscoveryRadius(double radius) async {
    try {
      await _preferencesBox.put(HiveKeys.discoveryRadiusKey, radius);
    } catch (e) {
      debugPrint('Error storing discovery radius: $e');
    }
  }

  static double getDiscoveryRadius() {
    return _preferencesBox.get(HiveKeys.discoveryRadiusKey, defaultValue: 10.0)
        as double;
  }

  static Future<void> setLastLocation(
    AppLocation location,
  ) async {
    try {
      await _userBox.put(HiveKeys.lastLatitudeKey, location.latitude);
      await _userBox.put(HiveKeys.lastLongitudeKey, location.longitude);
      if (location.hasPlaceName) {
        await _userBox.put(
          HiveKeys.lastLocationNameKey,
          location.placeName!.trim(),
        );
      } else {
        await _userBox.delete(HiveKeys.lastLocationNameKey);
      }
    } catch (e) {
      debugPrint('Error storing last location: $e');
    }
  }

  static AppLocation? getLastLocation() {
    final lat = _userBox.get(HiveKeys.lastLatitudeKey);
    final lon = _userBox.get(HiveKeys.lastLongitudeKey);
    if (lat != null && lon != null) {
      final name = _userBox.get(HiveKeys.lastLocationNameKey) as String?;
      return AppLocation(
        latitude: lat as double,
        longitude: lon as double,
        placeName: name,
      );
    }
    return null;
  }
}
