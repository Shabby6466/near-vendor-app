import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:nearvendorapp/utils/app_alerts.dart';
import 'package:nearvendorapp/utils/app_strings.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';
import 'package:nearvendorapp/utils/globals.dart';
import 'package:nearvendorapp/utils/helper_functions.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';

enum ApiType {
  get,
  post,
  put,
  patch,
  delete,
}

class Server {
  Server._();

  static Future<Response> get(
    String url, {
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) {
    return _call(
      url,
      apiType: ApiType.get,
      headers: headers,
      cancelToken: cancelToken,
    );
  }

  static Future<Response> post(
    String url, {
    Map<String, String>? headers,
    dynamic data,
    CancelToken? cancelToken,
  }) {
    return _call(
      url,
      apiType: ApiType.post,
      data: data,
      headers: headers,
      cancelToken: cancelToken,
    );
  }

  static Future<Response> put(
    String url, {
    Map<String, String>? headers,
    dynamic data,
    CancelToken? cancelToken,
  }) {
    return _call(
      url,
      apiType: ApiType.put,
      data: data,
      headers: headers,
      cancelToken: cancelToken,
    );
  }

  static Future<Response> patch(
    String url, {
    Map<String, String>? headers,
    dynamic data,
    CancelToken? cancelToken,
  }) {
    return _call(
      url,
      apiType: ApiType.patch,
      data: data,
      headers: headers,
      cancelToken: cancelToken,
    );
  }

  static Future<Response> delete(
    String url, {
    Map<String, String>? headers,
    dynamic data,
    CancelToken? cancelToken,
  }) {
    return _call(
      url,
      apiType: ApiType.delete,
      data: data,
      headers: headers,
      cancelToken: cancelToken,
    );
  }

  static Future<Response> _call(
    String url, {
    required ApiType apiType,
    dynamic data,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    bool retried = false,
  }) async {
    if (await isInternetAvailable()) {
      String? token;
      try {
        final dio = Dio();

        dio.options.baseUrl = ApiConstants.baseUrl;
        dio.httpClientAdapter = IOHttpClientAdapter(
          createHttpClient: () {
            final client = HttpClient();
            client.badCertificateCallback = (cert, host, port) => true;
            return client;
          },
        );
        if (headers != null) {
          for (final String key in headers.keys) {
            dio.options.headers[key] = headers[key];
          }
        }

        dio.options.headers['Accept'] = 'application/json';

        final authToken = CurrentUserStorage.getUserAuthToken();
        if (authToken != null) {
          token = 'Bearer $authToken';
        }

        debugPrint('server: ${dio.options.baseUrl}');

        if (!(headers?.containsKey('Authorization') ?? false)) {
          dio.options.headers['Authorization'] = token;
        }

        final Response response;
        switch (apiType) {
          case ApiType.get:
            response = await dio.get(url, cancelToken: cancelToken);
          case ApiType.post:
            response = await dio.post(
              url,
              data: data,
              cancelToken: cancelToken,
            );
          case ApiType.put:
            response = await dio.put(url, data: data, cancelToken: cancelToken);
          case ApiType.delete:
            response = await dio.delete(
              url,
              data: data,
              cancelToken: cancelToken,
            );
          case ApiType.patch:
            response = await dio.patch(
              url,
              data: data,
              cancelToken: cancelToken,
            );
        }
        return response;
      } catch (e) {
        if (e is DioException && token != null) {
          if (e.response?.statusCode == 401 && !retried) {
            final refreshSuccess = await _refreshAccessToken();

            if (refreshSuccess) {
              return await _call(
                url,
                apiType: apiType,
                data: data,
                headers: headers,
                cancelToken: cancelToken,
                retried: true,
              );
            }

            if (navigatorKey.currentContext != null) {
              AppAlerts.showErrorSnackBar(
                navigatorKey.currentContext!,
                AppStrings.pleaseLoginAgain,
              );
            }
            logoutUser();
          }
        }
        rethrow;
      }
    } else {
      throw AppStrings.checkInternetConnection;
    }
  }

  static Future<bool> _refreshAccessToken() async {
    final refreshToken = CurrentUserStorage.getUserRefreshAuthToken();
    if (refreshToken == null) return false;

    try {
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
      refreshDio.options.headers['Authorization'] = 'Bearer $refreshToken';

      final refreshResponse = await refreshDio.get(
        ApiConstants.refreshToken,
      );

      final refreshJson = refreshResponse.data;
      if (refreshJson is Map) {
        final newAccessToken = refreshJson['token'] as String?;
        final newRefreshToken = refreshJson['refreshToken'] as String?;

        if (newAccessToken != null) {
          await CurrentUserStorage.storeUserAuthToken(
            newAccessToken,
            newRefreshToken,
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      return false;
    }
  }
}
