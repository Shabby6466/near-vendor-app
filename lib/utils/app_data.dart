import 'package:flutter/foundation.dart';
import 'package:nearvendorapp/enums/auth_status.dart';
import 'package:nearvendorapp/models/data_models/app_location.dart';
import 'package:nearvendorapp/models/data_models/user.dart';
import 'package:nearvendorapp/services/auth_services.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';

/// Singleton app cache. [locationNotifier] is the single source of truth for
/// the user's last known coordinates and display name.
class AppData {
  factory AppData() => _instance;
  AppData._();

  static final AppData _instance = AppData._();

  final ValueNotifier<User?> userNotifier = ValueNotifier(null);

  /// Reactive last-known location — read this everywhere instead of Hive/Map.
  final ValueNotifier<AppLocation?> locationNotifier = ValueNotifier(null);

  User? get currentUser => userNotifier.value;
  String? get token => CurrentUserStorage.getUserAuthToken();
  String? get refreshToken => CurrentUserStorage.getUserRefreshAuthToken();
  bool get isLoggedIn => token != null && currentUser != null;
  AuthStatus get authStatus => isLoggedIn ? AuthStatus.authenticated : AuthStatus.guest;
  bool get hasOnboarded => CurrentUserStorage.getHasOnboarded();

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
      await CurrentUserStorage.storeUserData(user);
    }
    if (token != null) {
      await CurrentUserStorage.storeUserAuthToken(token, refreshToken);
    }
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
  }

  Future<void> loadHasOnboarded() async {
    await loadPersistedData();
  }

  void setHasOnboarded(bool value) {
    CurrentUserStorage.setHasOnboarded(value);
  }

  Future<void> initializeSession() async {
    final token = CurrentUserStorage.getUserAuthToken();
    final user = CurrentUserStorage.getCurrentUser();

    if (token != null && user != null) {
      userNotifier.value = user;
      try {
        final response = await AuthServices().getMe();
        if (response.user != null) {
          await setUser(response.user);
        } else {
          await clear();
        }
      } catch (e) {
        debugPrint('Session refresh failed: $e');
      }
    }
  }

  Future<void> clear() async {
    userNotifier.value = null;
    locationNotifier.value = null;
    _discoveryRadiusKm = null;
    await CurrentUserStorage.clearUserData();
  }
}
