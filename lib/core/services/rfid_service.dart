import 'package:flutter/services.dart';

class RFIDService {
  static const MethodChannel _channel = MethodChannel('rfid_channel');

  static Future<String?> scanRFID() async {
    try {
      final String? result = await _channel.invokeMethod<String>('scanRFID');
      return result;
    } on PlatformException catch (e) {
      print('Lỗi platform khi quét RFID: ${e.message}');
      return null;
    }
  }

  static Future<void> startRead() async {
    try {
      await _channel.invokeMethod('startRead');
    } catch (e) {
      print('Lỗi khi startRead: $e');
    }
  }

  static Future<void> stopRead() async {
    try {
      await _channel.invokeMethod('stopRead');
    } catch (e) {
      print('Lỗi khi stopRead: $e');
    }
  }
}
