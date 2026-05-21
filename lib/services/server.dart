import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';
import 'package:nearvendorapp/utils/globals.dart';
import 'package:nearvendorapp/utils/helper_functions.dart';
import 'package:nearvendorapp/utils/ui/app_alerts.dart';
import 'package:nearvendorapp/utils/ui/app_strings.dart';

enum ApiType { get, post, put, patch, delete }

class Server {
  Server._();

  static Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) => _call(
    url,
    apiType: ApiType.get,
    queryParams: queryParams ?? queryParameters,
    headers: headers,
    cancelToken: cancelToken,
  );

  static Future<Response> post(
    String url, {
    Map<String, String>? headers,
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) => _call(
    url,
    apiType: ApiType.post,
    data: data,
    queryParams: queryParams ?? queryParameters,
    headers: headers,
    cancelToken: cancelToken,
  );

  static Future<Response> put(
    String url, {
    Map<String, String>? headers,
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) => _call(
    url,
    apiType: ApiType.put,
    data: data,
    queryParams: queryParams ?? queryParameters,
    headers: headers,
    cancelToken: cancelToken,
  );

  static Future<Response> patch(
    String url, {
    Map<String, String>? headers,
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) => _call(
    url,
    apiType: ApiType.patch,
    data: data,
    queryParams: queryParams ?? queryParameters,
    headers: headers,
    cancelToken: cancelToken,
  );

  static Future<Response> delete(
    String url, {
    Map<String, String>? headers,
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) => _call(
    url,
    apiType: ApiType.delete,
    data: data,
    queryParams: queryParams ?? queryParameters,
    headers: headers,
    cancelToken: cancelToken,
  );

  static Future<Response> upload(
    String url, {
    required Map<String, dynamic> fields,
    Map<String, File>? files,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) => _upload(
    url,
    fields: fields,
    files: files,
    headers: headers,
    cancelToken: cancelToken,
  );

  static bool _isRefreshing = false;

  static Future<Response> _handle401(
    DioException e,
    String? refreshToken,
    Future<Response> Function() retry,
  ) async {
    if (refreshToken == null || _isRefreshing) {
      await logoutUser();
      final ctx = navigatorKey.currentContext;
      if (ctx != null && ctx.mounted) {
        AppAlerts.showError(ctx, AppStrings.pleaseLoginAgain);
      }
      throw AppStrings.pleaseLoginAgain;
    }

    _isRefreshing = true;
    try {
      final dio = Dio();
      dio.options.baseUrl = ApiConstants.baseUrl;
      final response = await dio.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data as Map<String, dynamic>;
        final data = (body['data'] as Map<String, dynamic>?) ?? body;
        final newToken = data['token'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newToken != null) {
          await AppData().setUser(
            AppData().currentUser,
            token: newToken,
            refreshToken: newRefreshToken,
          );
          _isRefreshing = false;
          return await retry();
        }
      }

      await logoutUser();
      final ctx = navigatorKey.currentContext;
      if (ctx != null && ctx.mounted) {
        AppAlerts.showError(ctx, AppStrings.pleaseLoginAgain);
      }
      throw AppStrings.pleaseLoginAgain;
    } catch (err) {
      _isRefreshing = false;
      await logoutUser();
      final ctx = navigatorKey.currentContext;
      if (ctx != null && ctx.mounted) {
        AppAlerts.showError(ctx, AppStrings.pleaseLoginAgain);
      }
      throw AppStrings.pleaseLoginAgain;
    } finally {
      _isRefreshing = false;
    }
  }

  static Future<Response> _upload(
    String url, {
    required Map<String, dynamic> fields,
    Map<String, File>? files,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) async {
    if (await isInternetAvailable()) {
      String? token;
      try {
        final dio = Dio();
        dio.options.baseUrl = ApiConstants.baseUrl;
        dio.options.connectTimeout = const Duration(seconds: 30);
        dio.options.receiveTimeout = const Duration(seconds: 30);
        dio.options.validateStatus = (status) =>
            status != null && status < 500 && status != 401;

        dio.httpClientAdapter = IOHttpClientAdapter(
          createHttpClient: () {
            final client = HttpClient();
            client.badCertificateCallback = (cert, host, port) => true;
            return client;
          },
        );
        headers?.forEach((key, value) => dio.options.headers[key] = value);
        dio.options.headers['Accept'] = 'application/json';
        token = AppData().token;
        if (token != null) {
          dio.options.headers['Authorization'] = 'Bearer $token';
        }

        final formData = FormData();
        fields.forEach(
          (key, value) => formData.fields.add(MapEntry(key, value.toString())),
        );
        if (files != null) {
          files.forEach((key, file) {
            formData.files.add(
              MapEntry(
                key,
                MultipartFile.fromFileSync(
                  file.path,
                  filename: file.path.split('/').last,
                ),
              ),
            );
          });
        }

        final response = await dio.post(
          url,
          data: formData,
          cancelToken: cancelToken,
        );
        return response;
      } on DioException catch (e) {
        if (token != null && e.response?.statusCode == 401) {
          return await _handle401(
            e,
            AppData().refreshToken,
            () => _upload(
              url,
              fields: fields,
              files: files,
              headers: headers,
              cancelToken: cancelToken,
            ),
          );
        }
        if (e.response?.statusCode == 429) {
          throw 'Too many requests. Please wait a moment and try again.';
        }
        final msg = e.response?.data is Map
            ? ((e.response!.data as Map)['message'] ?? e.message)
            : e.message;
        throw msg?.toString() ?? 'An error occurred';
      }
    } else {
      throw AppStrings.checkInternetConnection;
    }
  }

  static Future<Response> _call(
    String url, {
    required ApiType apiType,
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) async {
    if (await isInternetAvailable()) {
      String? token;
      try {
        final dio = Dio();
        dio.options.baseUrl = ApiConstants.baseUrl;
        dio.options.connectTimeout = const Duration(seconds: 30);
        dio.options.receiveTimeout = const Duration(seconds: 30);
        dio.options.validateStatus = (status) =>
            status != null && status < 500 && status != 401;

        dio.httpClientAdapter = IOHttpClientAdapter(
          createHttpClient: () {
            final client = HttpClient();
            client.badCertificateCallback = (cert, host, port) => true;
            return client;
          },
        );
        headers?.forEach((key, value) => dio.options.headers[key] = value);
        dio.options.headers['Accept'] = 'application/json';
        token = AppData().token;
        if (token != null) {
          dio.options.headers['Authorization'] = 'Bearer $token';
        }

        final Response response;
        switch (apiType) {
          case ApiType.get:
            response = await dio.get(
              url,
              queryParameters: queryParams,
              cancelToken: cancelToken,
            );
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
      } on DioException catch (e) {
        if (token != null && e.response?.statusCode == 401) {
          return await _handle401(
            e,
            AppData().refreshToken,
            () => _call(
              url,
              apiType: apiType,
              data: data,
              queryParams: queryParams,
              headers: headers,
              cancelToken: cancelToken,
            ),
          );
        }
        if (e.response?.statusCode == 429) {
          throw 'Too many requests. Please wait a moment and try again.';
        }
        final msg = e.response?.data is Map
            ? ((e.response!.data as Map)['message'] ?? e.message)
            : e.message;
        throw msg?.toString() ?? 'An error occurred';
      }
    } else {
      throw AppStrings.checkInternetConnection;
    }
  }
}
