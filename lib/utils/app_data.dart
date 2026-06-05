import 'package:flutter/foundation.dart';
import 'package:nearvendorapp/enums/auth_status.dart';
import 'package:nearvendorapp/models/data_models/app_location.dart';
import 'package:nearvendorapp/models/data_models/user.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';
import 'package:nearvendorapp/utils/hive/hive_manager.dart';

/// Singleton app cache. [locationNotifier] is the single source of truth for
/// the user's last known coordinates and display name.
class AppData {
  factory AppData() => _instance;
  AppData._();

  static final AppData _instance = AppData._();

  final ValueNotifier<User?> userNotifier = ValueNotifier(null);
  final ValueNotifier<AuthStatus> authStatusNotifier = ValueNotifier(
    AuthStatus.guest,
  );
  final ValueNotifier<bool> hasOnboardedNotifier = ValueNotifier(false);
  final ValueNotifier<bool> showMainScreenNotifier = ValueNotifier(false);

  /// Reactive last-known location — read this everywhere instead of Hive/Map.
  final ValueNotifier<AppLocation?> locationNotifier = ValueNotifier(null);

  User? get currentUser => userNotifier.value;
  String? get token => CurrentUserStorage.getUserAuthToken();
  String? get refreshToken => CurrentUserStorage.getUserRefreshAuthToken();
  bool get isLoggedIn => token != null && currentUser != null;
  AuthStatus get authStatus => authStatusNotifier.value;
  bool get hasOnboarded => hasOnboardedNotifier.value;

  AppLocation? get location => locationNotifier.value;
  double? get latitude => location?.latitude;
  double? get longitude => location?.longitude;
  String? get cityName => location?.placeName;
  bool get hasLocation => location != null;

  double? _discoveryRadiusKm;

  double? get discoveryRadius => _discoveryRadiusKm;

  Future<void> setUser(
    User? user, {
    String? token,
    String? refreshToken,
  }) async {
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

  void updateUser(User updatedUser) {
    userNotifier.value = updatedUser;
    CurrentUserStorage.storeUserData(updatedUser);
  }

  /// Persists and broadcasts the user's location. All flows must use this.
  Future<void> setLocation(
    double lat,
    double lon, {
    String? placeName,
  }) async {
    if (!lat.isFinite || !lon.isFinite) {
      debugPrint('Warning: Attempted to set non-finite location: LatLng($lat, $lon)');
      return;
    }
    final resolvedName = placeName ?? location?.placeName;
    final appLocation = AppLocation(
      latitude: lat,
      longitude: lon,
      placeName: resolvedName,
    );
    locationNotifier.value = appLocation;
    await CurrentUserStorage.setLastLocation(appLocation);
  }

  Future<void> setDiscoveryRadius(double radiusKm) async {
    _discoveryRadiusKm = radiusKm;
    await CurrentUserStorage.setDiscoveryRadius(radiusKm);
  }

  /// Restores location and preferences from Hive. Call once at app startup.
  Future<void> loadPersistedData() async {
    final stored = CurrentUserStorage.getLastLocation();
    if (stored != null) {
      locationNotifier.value = stored;
    }
    _discoveryRadiusKm = CurrentUserStorage.getDiscoveryRadius();
    hasOnboardedNotifier.value = CurrentUserStorage.getHasOnboarded();
    _updateShowMainScreen();
  }

  Future<void> loadHasOnboarded() async {
    await loadPersistedData();
  }

  void setHasOnboarded(bool value) {
    hasOnboardedNotifier.value = value;
    CurrentUserStorage.setHasOnboarded(value);
    _updateShowMainScreen();
  }

  void _updateShowMainScreen() {
    showMainScreenNotifier.value =
        authStatus == AuthStatus.authenticated || hasOnboarded;
  }

  Future<void> clear() async {
    userNotifier.value = null;
    authStatusNotifier.value = AuthStatus.guest;
    locationNotifier.value = null;
    _discoveryRadiusKm = null;
    await CurrentUserStorage.clearUserData();
    HiveManager.onLogout();
    _updateShowMainScreen();
  }
}
