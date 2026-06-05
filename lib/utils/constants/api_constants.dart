import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'https://api.nearvendor.pro/';
  // static String baseurl = 'http://10.0.2.2:3837';

  ///AUTH
  static const String createUser = 'api/auth/create';
  static const String resendOtp = 'api/auth/resend-otp';
  static const String verifyOTP = 'api/auth/verify-otp';
  static const String login = 'api/auth/login';
  static const String refreshToken = 'api/auth/refresh-token';
  static const String changePassword = 'api/users/change-password';
  static const String getMe = 'api/users/me';
  static const String updateUser = 'api/users/update';
  static const String deleteAccount = 'api/users/delete-account';
  static const String uploadMedia = 'api/media/upload-simple';
  static const String getNearbyShops = 'api/explore/shops/nearby';
  static const String getShopsByMap = 'api/explore/shops/map';

  ///ITEMS
  static const String createItem = 'api/item/create';
  static const String updateItem = 'api/item/update/';
  static const String deleteItem = 'api/item/delete/';
  static const String getItemsByShop = 'api/item/get-all-by-shop';
  static const String getItemById = 'api/item/';
  static const String getCategoriesNames = 'api/shops/categories';
  static const String searchItems = 'api/explore/items/search';
  static const String searchShops = 'api/explore/shops/search';
  static const String getShopById = 'api/shops/';
  static const String getRecentItems = 'api/explore/recent-items';
  static const String batchAnalytics = 'api/analytics/batch';
  static const String updateUserLocation = 'api/users/location';
  static const String visualSearch = 'api/explore/search/visual';

  ///WISHLIST
  static const String createWishlist = 'api/wishlist';
  static const String getMyWishlists = 'api/wishlist/me';
  static const String deleteWishlist = 'api/wishlist/';
  static const String completeWishlist = 'api/wishlist/'; // + id + '/complete'
  static const String exploreWishlists = 'api/wishlist/explore';

  // Analytics
  static const String getAnalyticsStats = 'api/analytics/stats/';

  /// SAFETY
  static const String reportContent = 'api/safety/report';
  static const String blockUser = 'api/safety/block';
}
