import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';


class ApiService {
  final String baseUrl;
  String? bearerToken; // Biến chứa token
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  ApiService(this.baseUrl, [this.bearerToken]) {
    if (bearerToken != null && bearerToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $bearerToken';
    }
  }

  // Hàm để cập nhật token nếu cần
  void updateToken(String newToken) {
    bearerToken = newToken;
    headers['Authorization'] = 'Bearer $bearerToken';
  }

  Future<Map<String, dynamic>> postData(
      String endpoint, Map<String, dynamic> data, {String? accessToken}) async {
    print('$baseUrl$endpoint');

    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    
    final response = await http.post(Uri.parse('$baseUrl$endpoint'),
        headers: headers, body: json.encode(data));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getData(String endpoint, {String? accessToken}) async {
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    final response =
        await http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> putData(
      String endpoint, Map<String, dynamic> data, {String? accessToken}) async {
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    final response = await http.put(Uri.parse('$baseUrl$endpoint'),
        headers: headers, body: json.encode(data));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> deleteData(
    String endpoint, {
    Map<String, dynamic>? data,
    String? accessToken,
  }) async {
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: data != null ? json.encode(data) : null,
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patchData(
      String endpoint, Map<String, dynamic> data) async {
    final response = await http.patch(Uri.parse('$baseUrl$endpoint'),
        headers: headers, body: json.encode(data));
    return _handleResponse(response);
  }

Future<Map<String, dynamic>> postMultipartData(
      String endpoint,
      Map<String, String> fields,
      Map<String, File> singleFiles,
      Map<String, List<File>> multipleFiles,
      {String? accessToken}) async {
    // Tạo request multipart
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));

    // Thêm token nếu có
    if (accessToken != null) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }

    // Đặt các trường dạng text
    fields.forEach((key, value) {
      request.fields[key] = value;
    });

    // Thêm file đơn lẻ vào request
    for (var entry in singleFiles.entries) {
      var stream = http.ByteStream(entry.value.openRead());
      var length = await entry.value.length();
      var multipartFile = http.MultipartFile(
        entry.key,
        stream,
        length,
        filename: entry.value.path.split('/').last,
        contentType: MediaType(
            'image', entry.value.path.endsWith('.png') ? 'png' : 'jpeg'),
      );
      request.files.add(multipartFile);
    }

    // Tạo bản sao của danh sách file trước khi lặp
    for (var entry in multipleFiles.entries) {
      List<File> fileListCopy = List<File>.from(entry.value);
      for (var file in fileListCopy) {
        var stream = http.ByteStream(file.openRead());
        var length = await file.length();
        var multipartFile = http.MultipartFile(
          entry.key,
          stream,
          length,
          filename: file.path.split('/').last,
          contentType:
              MediaType('image', file.path.endsWith('.png') ? 'png' : 'jpeg'),
        );
        request.files.add(multipartFile);
      }
    }

    // Gửi request
    var response = await request.send();

    // Lấy kết quả từ response
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var responseData = await response.stream.bytesToString();
      return json.decode(responseData);
    } else {
      print('Failed to upload data: ${response.statusCode}');
      throw Exception('Failed to process data: ${response.statusCode}');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      print('Failed to load data: ${response.statusCode}');
      throw Exception('Failed to process data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getDataFromUrl(String fullUrl) async {
    try {
      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        } else {
          throw Exception('Unexpected data format: Expected a JSON object');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: ${e.toString()}');
      throw Exception('Failed to get data from URL: ${e.toString()}');
    }
  }
}