import 'package:flutter/services.dart';

class RFIDService {
  static const MethodChannel _channel = MethodChannel('rfid_channel');

  static Future<String?> scanRFID() async {
    try {
      final result = await _channel.invokeMethod<String>('scanRFID');
      return result;
    } on PlatformException catch (e) {
      print("Lỗi RFID: ${e.message}");
      return null;
    }
  }
}
