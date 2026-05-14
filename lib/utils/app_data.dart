import 'package:flutter/foundation.dart';
import 'package:nearvendorapp/enums/auth_status.dart';
import 'package:nearvendorapp/models/data_models/user.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';
import 'package:nearvendorapp/utils/hive/hive_manager.dart';

class AppData {

  // Factory constructor immediately after
  factory AppData() => _instance;
  // Unnamed constructor FIRST (required by lint)
  AppData._();

  // Static members after all constructors
  static final AppData _instance = AppData._();

  // Reactive user — widgets use ValueListenableBuilder to auto-update
  final ValueNotifier<User?> userNotifier = ValueNotifier(null);
  final ValueNotifier<AuthStatus> authStatusNotifier = ValueNotifier(AuthStatus.guest);
  final ValueNotifier<bool> hasOnboardedNotifier = ValueNotifier(false);
  final ValueNotifier<bool> showMainScreenNotifier = ValueNotifier(false);

  User? get currentUser => userNotifier.value;
  String? get token => CurrentUserStorage.getUserAuthToken();
  String? get refreshToken => CurrentUserStorage.getUserRefreshAuthToken();
  bool get isLoggedIn => token != null && currentUser != null;
  AuthStatus get authStatus => authStatusNotifier.value;
  bool get hasOnboarded => hasOnboardedNotifier.value;

  // Location data
  double? _latitude;
  double? _longitude;
  String? _cityName;
  double? _discoveryRadiusKm;

  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get cityName => _cityName;
  double? get discoveryRadius => _discoveryRadiusKm;

  // Called on login / session restore
  Future<void> setUser(User? user, {String? token, String? refreshToken}) async {
    userNotifier.value = user;
    if (user != null) {
      authStatusNotifier.value = AuthStatus.authenticated;
      await CurrentUserStorage.storeUserData(user);
    } else {
      authStatusNotifier.value = AuthStatus.guest;
    }
    if (token != null) {
      await CurrentUserStorage.storeUserAuthToken(token, refreshToken);
    }
    _updateShowMainScreen();
  }

  // Called on profile update — notifies all ValueListenableBuilder listeners
  void updateUser(User updatedUser) {
    userNotifier.value = updatedUser;
    CurrentUserStorage.storeUserData(updatedUser);
  }

  Future<void> setLocation(double lat, double lon, {String? cityName}) async {
    _latitude = lat;
    _longitude = lon;
    if (cityName != null) _cityName = cityName;
    await CurrentUserStorage.setLastLocation(lat, lon);
  }

  Future<void> setDiscoveryRadius(double radiusKm) async {
    _discoveryRadiusKm = radiusKm;
    await CurrentUserStorage.setDiscoveryRadius(radiusKm);
  }

  Future<void> loadHasOnboarded() async {
    hasOnboardedNotifier.value = CurrentUserStorage.getHasOnboarded();
    _updateShowMainScreen();
  }

  void setHasOnboarded(bool value) {
    hasOnboardedNotifier.value = value;
    CurrentUserStorage.setHasOnboarded(value);
    _updateShowMainScreen();
  }

  void _updateShowMainScreen() {
    showMainScreenNotifier.value = authStatus == AuthStatus.authenticated || hasOnboarded;
  }

  Future<void> clear() async {
    userNotifier.value = null;
    authStatusNotifier.value = AuthStatus.guest;
    _latitude = null;
    _longitude = null;
    _cityName = null;
    _discoveryRadiusKm = null;
    await CurrentUserStorage.clearUserData();
    HiveManager.onLogout();
    _updateShowMainScreen();
  }
}
