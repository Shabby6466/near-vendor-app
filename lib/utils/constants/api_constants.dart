class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://';

  ///AUTH
  static const String sendOTP = 'auth/send-otp';
  static const String user = 'user';
  static const String verifyOTP = 'auth/verify-otp';
  static const String setPassword = 'auth/set-password';
  static const String password = 'user/password';
  static const String login = 'auth/login';
  static const String forgotPassword = 'auth/forgot-password';
  static const String refreshToken = 'auth/refresh-token';

  static String getTokens = 'token/multi-chain?page=1&pageSize=5000&sort=desc';
  static String getTokenPrices = 'token-price?page=1&pageSize=5000&sort=asc';
  static String getBalances = 'balances/by-address';
  static String searchTokens = 'token/search';
  static String getTokenByExternalId = 'token/by-external-id';
  static String getWalletHistory = 'wallet/history';
}
