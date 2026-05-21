import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';
import 'package:nearvendorapp/utils/globals.dart';
import 'package:nearvendorapp/utils/helper_functions.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';
import 'package:nearvendorapp/utils/ui/app_alerts.dart';
import 'package:nearvendorapp/utils/ui/app_strings.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

enum ApiType { get, post, put, patch, delete }

class Server {
  Server._();

  // ── Singleton Dio instance — configured once, reused for every request ──
  static final Dio _dio = _buildDio();

  static Dio _buildDio() {
    final dio = Dio();
    dio.options.baseUrl = ApiConstants.baseUrl;
    dio.options.validateStatus = (status) =>
        status != null && status < 500 && status != 401;
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        // Allow self-signed certs in dev; remove for production
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      },
    );
    dio.options.headers['Accept'] = 'application/json';

    // Auth token interceptor — reads the token at request time, not at build time
    dio.interceptors.add(_AuthInterceptor());

    // Logging — only in debug mode
    if (kDebugMode) {
      dio.interceptors.add(PrettyDioLogger());
    }

    return dio;
  }

  // ── Public API ────────────────────────────────────────────────────────────

  static Future<Response> get(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) => _call(
    url,
    apiType: ApiType.get,
    headers: headers,
    queryParameters: queryParameters,
    cancelToken: cancelToken,
  );

  static Future<Response> post(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    CancelToken? cancelToken,
  }) => _call(
    url,
    apiType: ApiType.post,
    data: data,
    headers: headers,
    queryParameters: queryParameters,
    cancelToken: cancelToken,
  );

  static Future<Response> put(
    String url, {
    Map<String, String>? headers,
    dynamic data,
    CancelToken? cancelToken,
  }) => _call(
    url,
    apiType: ApiType.put,
    data: data,
    headers: headers,
    cancelToken: cancelToken,
  );

  static Future<Response> patch(
    String url, {
    Map<String, String>? headers,
    dynamic data,
    CancelToken? cancelToken,
  }) => _call(
    url,
    apiType: ApiType.patch,
    data: data,
    headers: headers,
    cancelToken: cancelToken,
  );

  static Future<Response> delete(
    String url, {
    Map<String, String>? headers,
    dynamic data,
    CancelToken? cancelToken,
  }) => _call(
    url,
    apiType: ApiType.delete,
    data: data,
    headers: headers,
    cancelToken: cancelToken,
  );

  // ── Internal ──────────────────────────────────────────────────────────────

  static Future<Response> _call(
    String url, {
    required ApiType apiType,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    bool retried = false,
  }) async {
    if (!await isInternetAvailable()) {
      throw AppStrings.checkInternetConnection;
    }

    // Per-request header overrides (e.g. custom Authorization for reset-password)
    final Options? options = headers != null ? Options(headers: headers) : null;

    try {
      final Response response;
      switch (apiType) {
        case ApiType.get:
          response = await _dio.get(
            url,
            queryParameters: queryParameters,
            cancelToken: cancelToken,
            options: options,
          );
        case ApiType.post:
          response = await _dio.post(
            url,
            data: data,
            queryParameters: queryParameters,
            cancelToken: cancelToken,
            options: options,
          );
        case ApiType.put:
          response = await _dio.put(
            url,
            data: data,
            cancelToken: cancelToken,
            options: options,
          );
        case ApiType.delete:
          response = await _dio.delete(
            url,
            data: data,
            cancelToken: cancelToken,
            options: options,
          );
        case ApiType.patch:
          response = await _dio.patch(
            url,
            data: data,
            cancelToken: cancelToken,
            options: options,
          );
      }
      return response;
    } catch (e) {
      if (e is DioException) {
        final int? httpStatus = e.response?.statusCode;
        final dynamic responseData = e.response?.data;
        int? bodyStatus;
        if (responseData is Map) {
          bodyStatus = int.tryParse(
            responseData['statusCode']?.toString() ?? '',
          );
        }

        if ((httpStatus == 401 || bodyStatus == 401) && !retried) {
          debugPrint('401 detected — attempting token refresh...');
          final refreshSuccess = await _refreshAccessToken();

          if (refreshSuccess) {
            debugPrint('Token refreshed — retrying request...');
            return _call(
              url,
              apiType: apiType,
              data: data,
              queryParameters: queryParameters,
              headers: headers,
              cancelToken: cancelToken,
              retried: true,
            );
          }

          debugPrint('Token refresh failed — logging out.');
          // Capture navigator before any further awaits
          final ctx = navigatorKey.currentContext;
          logoutUser();
          if (ctx != null && ctx.mounted) {
            AppAlerts.showError(ctx, AppStrings.pleaseLoginAgain);
          }
          throw AppStrings.pleaseLoginAgain;
        }

        if (e.response?.statusCode == 429) {
          throw 'Too many requests. Please wait a moment and try again.';
        }

        final msg = e.response?.data is Map
            ? ((e.response!.data as Map)['message'] ?? e.message)
            : e.message;
        throw msg?.toString() ?? 'An error occurred';
      }
      rethrow;
    }
  }

  static Future<bool> _refreshAccessToken() async {
    final refreshToken = CurrentUserStorage.getUserRefreshAuthToken();
    if (refreshToken == null) return false;

    try {
      // Use a separate Dio instance for refresh to avoid interceptor loops
      final refreshDio = Dio();
      refreshDio.options.baseUrl = ApiConstants.baseUrl;
      refreshDio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback = (cert, host, port) => true;
          return client;
        },
      );
      refreshDio.options.headers['Accept'] = 'application/json';

      final refreshResponse = await refreshDio.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final refreshJson = refreshResponse.data;
      if (refreshJson is Map) {
        final data = refreshJson['data'] is Map
            ? (refreshJson['data'] as Map).cast<String, dynamic>()
            : refreshJson.cast<String, dynamic>();
        final newAccessToken = data['token'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;
        if (newAccessToken != null) {
          await CurrentUserStorage.storeUserAuthToken(
            newAccessToken,
            newRefreshToken,
          );
          return true;
        }
      }
      logoutUser();
      return false;
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      logoutUser();
      return false;
    }
  }
}

/// Interceptor that injects the Bearer token at request time.
/// Reading the token here (not at Dio construction time) ensures it is always
/// the latest value from storage, even after a token refresh.
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Don't overwrite an explicit Authorization header (e.g. reset-password flow)
    if (!options.headers.containsKey('Authorization')) {
      final token = CurrentUserStorage.getUserAuthToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }
}
