import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:3837/';
  // static String baseurl = 'http://10.0.2.2:3837';

  ///AUTH
  static const String createUser = 'api/auth/create';
  static const String verifyOTP = 'api/auth/verify-otp';
  static const String login = 'api/auth/login';
  static const String changePassword = 'api/users/change-password';
  static const String getMe = 'api/users/me';
  static const String updateUser = 'api/users/update';
  static const String uploadMedia = 'api/media/upload-simple';
  static const String registerVendor = 'api/vendor/register';
  static const String getVendorStatus = 'api/vendor/me/status';
  static const String updateVendor = 'api/vendor/update';
  static const String createShop = 'api/shops/create';
  static const String updateShopProfile = 'api/shops/update';
  static const String deleteShop = 'api/shops/delete';
  static const String getMyShops = 'api/shops/me/shops';
  static const String getNearbyShops = 'api/explore/shops/nearby';

  ///ITEMS
  static const String createItem = 'api/item/create';
  static const String updateItem = 'api/item/update/';
  static const String deleteItem = 'api/item/delete/';
  static const String getItemsByShop = 'api/item/get-all-by-shop';
  static const String getItemById = 'api/item/';
  static const String getCategoriesNames = 'api/categories/get-all-names';
  static const String searchItems = 'api/explore/items/search';
  static const String getShopById = 'api/shops/';
  static const String getRecentItems = 'api/explore/recent-items';
}
