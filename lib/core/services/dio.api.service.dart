import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class ApiService {
  late final Dio _dio;
  final String baseUrl;
  late final String _normalizedBaseUrl;

  static const int maxRetries = 5;
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 120000; // 120 seconds
  static const int sendTimeout = 120000; // 120 seconds
  static const Duration totalRequestTimeout = Duration(seconds: 60);
  static const String timeoutMessage = 'Không nhận được phản hồi từ máy chủ';

  ApiService(this.baseUrl) {
    _normalizedBaseUrl = _normalizeBaseUrl(baseUrl);

    _dio = Dio(
      BaseOptions(
        baseUrl: _normalizedBaseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Connection': 'keep-alive',
        },
        connectTimeout: const Duration(milliseconds: connectTimeout),
        receiveTimeout: const Duration(milliseconds: receiveTimeout),
        sendTimeout: const Duration(milliseconds: sendTimeout),
        receiveDataWhenStatusError: true,
        followRedirects: true,
        maxRedirects: 3,
        // Accept every HTTP status and let caller decide success/failure.
        validateStatus: (_) => true,
      ),
    );

    // Add retry interceptor
    _dio.interceptors.add(RetryInterceptor(dio: _dio, maxRetries: maxRetries));
  }

  String _normalizeBaseUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return trimmed;
    final noTrailingSlash = trimmed.replaceFirst(RegExp(r'/+$'), '');
    return '$noTrailingSlash/';
  }

  String _normalizeEndpoint(String endpoint) {
    final cleanEndpoint = endpoint.trim();
    if (cleanEndpoint.startsWith('http://') ||
        cleanEndpoint.startsWith('https://')) {
      return cleanEndpoint;
    }
    return cleanEndpoint.replaceFirst(RegExp(r'^/+'), '');
  }

  String _resolveForLog(String endpoint) {
    if (endpoint.startsWith('http://') || endpoint.startsWith('https://')) {
      return endpoint;
    }
    return Uri.parse(_normalizedBaseUrl).resolve(endpoint).toString();
  }

  Future<Response> post(
    String endpoint,
    Map<String, dynamic> data, {
    Duration? timeout,
  }) async {
    final normalizedEndpoint = _normalizeEndpoint(endpoint);
    final cancelToken = CancelToken();
    final requestTimeout = timeout ?? totalRequestTimeout;
    try {
      final resolved = _resolveForLog(normalizedEndpoint);
      debugPrint(
        '[ApiService][POST] url=$resolved endpoint=$endpoint normalized=$normalizedEndpoint',
      );
      final response = await _dio
          .post(
            normalizedEndpoint,
            data: data,
            cancelToken: cancelToken,
          )
          .timeout(requestTimeout);
      return response;
    } on TimeoutException catch (e) {
      cancelToken.cancel('Request timed out after ${requestTimeout.inSeconds}s');
      debugPrint(
        '[ApiService][POST][Timeout] baseUrl=$_normalizedBaseUrl endpoint=$normalizedEndpoint timeout=${requestTimeout.inSeconds}s message=$e',
      );
      return Response(
        requestOptions: RequestOptions(path: normalizedEndpoint),
        statusCode: 504,
        statusMessage: timeoutMessage,
      );
    } on DioException catch (e) {
      debugPrint(
        '[ApiService][POST][Error] baseUrl=$_normalizedBaseUrl endpoint=$normalizedEndpoint type=${e.type} message=${e.message}',
      );
      return e.response ??
          Response(
            requestOptions: RequestOptions(path: normalizedEndpoint),
            statusCode: 500,
            statusMessage: 'Internal Error: ${e.message}',
          );
    }
  }

  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Duration? timeout,
  }) async {
    final normalizedEndpoint = _normalizeEndpoint(endpoint);
    final cancelToken = CancelToken();
    final requestTimeout = timeout ?? totalRequestTimeout;
    try {
      final resolved = _resolveForLog(normalizedEndpoint);
      debugPrint(
        '[ApiService][GET] url=$resolved endpoint=$endpoint normalized=$normalizedEndpoint',
      );
      final response = await _dio
          .get(
            normalizedEndpoint,
            queryParameters: queryParameters,
            cancelToken: cancelToken,
          )
          .timeout(requestTimeout);
      return response;
    } on TimeoutException catch (e) {
      cancelToken.cancel('Request timed out after ${requestTimeout.inSeconds}s');
      debugPrint(
        '[ApiService][GET][Timeout] baseUrl=$_normalizedBaseUrl endpoint=$normalizedEndpoint timeout=${requestTimeout.inSeconds}s message=$e',
      );
      return Response(
        requestOptions: RequestOptions(path: normalizedEndpoint),
        statusCode: 504,
        statusMessage: timeoutMessage,
      );
    } on DioException catch (e) {
      debugPrint(
        '[ApiService][GET][Error] baseUrl=$_normalizedBaseUrl endpoint=$normalizedEndpoint type=${e.type} message=${e.message}',
      );
      return e.response ??
          Response(
            requestOptions: RequestOptions(path: normalizedEndpoint),
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

  RetryInterceptor({required this.dio, required this.maxRetries});

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
      final delayMs = (1000 * math.pow(2, retryCount)).toInt();
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
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        (err.response?.statusCode == 429) ||
        (err.response?.statusCode == 502) ||
        (err.response?.statusCode == 503) ||
        (err.response?.statusCode == 504);
  }
}
