class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.nearvendor.pro/s';

  ///AUTH
  static const String createUser = 'api/auth/create';
  static const String verifyOTP = 'api/auth/verify-otp';
  static const String login = 'api/auth/login';
  static const String changePassword = 'api/users/change-password';
  static const String getMe = 'api/users/me';
  static const String registerVendor = 'api/vendor/register';
  static const String updateVendor = 'api/vendor/update';
  static const String createShop = 'api/shops/create';
  static const String updateShopProfile = 'api/shops/update';
  static const String deleteShop = 'api/shops/delete';
  static const String getMyShops = 'api/shops/me/shops';

  ///ITEMS
  static const String createItem = 'api/item/create';
  static const String updateItem = 'api/item/update/'; // Append {id}
  static const String deleteItem = 'api/item/delete/'; // Append {id}
  static const String getItemsByShopId = 'api/item/get-all-by-shop-id';
}
