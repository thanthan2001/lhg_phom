import 'dart:convert';

import 'package:dio/dio.dart';

class ApiService {
  late final Dio _dio;
  final String baseUrl;
  static const int maxRetries = 3;
  static const int connectTimeout = 15000; // 15 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  ApiService(this.baseUrl) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(milliseconds: connectTimeout),
        receiveTimeout: const Duration(milliseconds: receiveTimeout),
        sendTimeout: const Duration(milliseconds: 30000),
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );
    
    // Add retry interceptor
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        maxRetries: maxRetries,
      ),
    );
  }

  Future<Response> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: jsonEncode(data),
      );
      return response;
    } on DioException catch (e) {
      print('API Error: ${e.message}');
      return e.response ??
          Response(
            requestOptions: RequestOptions(path: endpoint),
            statusCode: 500,
            statusMessage: 'Internal Error: ${e.message}',
          );
    }
  }

  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      print('API Error: ${e.message}');
      return e.response ??
          Response(
            requestOptions: RequestOptions(path: endpoint),
            statusCode: 500,
            statusMessage: 'Internal Error: ${e.message}',
          );
    }
  }

  void dispose() {
    _dio.close();
  }
}

/// Custom interceptor for automatic retry with exponential backoff
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryInterceptor({
    required this.dio,
    required this.maxRetries,
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_shouldRetry(err) && err.requestOptions.extra['retries'] == null) {
      err.requestOptions.extra['retries'] = 0;
    }

    if (_shouldRetry(err) &&
        err.requestOptions.extra['retries'] != null &&
        (err.requestOptions.extra['retries'] as int) < maxRetries) {
      final retryCount = (err.requestOptions.extra['retries'] as int);
      err.requestOptions.extra['retries'] = retryCount + 1;

      // Exponential backoff: 1s, 2s, 4s
      final delayMs = (1000 * (2 ^ retryCount)).toInt();
      await Future.delayed(Duration(milliseconds: delayMs));

      try {
        final response = await dio.request(
          err.requestOptions.path,
          cancelToken: err.requestOptions.cancelToken,
          data: err.requestOptions.data,
          onReceiveProgress: err.requestOptions.onReceiveProgress,
          onSendProgress: err.requestOptions.onSendProgress,
          queryParameters: err.requestOptions.queryParameters,
          options: Options(
            method: err.requestOptions.method,
            headers: err.requestOptions.headers,
          ),
        );
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        (err.response?.statusCode == 503) ||
        (err.response?.statusCode == 504);
  }
}
