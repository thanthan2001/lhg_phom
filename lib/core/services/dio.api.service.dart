import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl;

  ApiService(this.baseUrl) {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers = {'Content-Type': 'application/json'};

    _dio.options.validateStatus = (status) {
      return status != null && status < 500;
    };
  }

  // Post Method
  Future<Response> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(endpoint, data: jsonEncode(data));
      return response;
    } on DioException catch (e) {
      return e.response ??
          Response(
            requestOptions: RequestOptions(path: endpoint),
            statusCode: 500,
            statusMessage: 'Internal Error',
          );
    }
  }
}
