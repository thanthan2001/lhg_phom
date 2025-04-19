import 'dart:async';

import 'package:flutter/services.dart';

class RFIDService {
  static const MethodChannel _channel = MethodChannel('rfid_channel');

  // Kết nối thiết bị
  static Future<bool> connect() async {
    return await _channel.invokeMethod('connectRFID');
  }

  // Ngắt kết nối thiết bị
  static Future<void> disconnect() async {
    await _channel.invokeMethod('disconnectRFID');
  }

  // Quét liên tục (callback cho mỗi tag)
  static Future<void> startRead(Function(String epc) onScan) async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onTagScanned') {
        onScan(call.arguments as String);
      }
    });

    await _channel.invokeMethod('startScan');
  }

  // Dừng quét liên tục
  static Future<void> stopScan() async {
    await _channel.invokeMethod('stopScan');
  }

  // Quét 1 lần, đợi kết quả qua callback đầu tiên
  static Future<String?> scanRFID() async {
    String? scannedEpc;

    final completer = Completer<String>();
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onTagScanned') {
        scannedEpc = call.arguments as String;
        if (!completer.isCompleted) completer.complete(scannedEpc);
      }
    });

    await _channel.invokeMethod('startScan');

    // Dừng sau 2 giây để tránh quét mã tiếp theo
    Future.delayed(const Duration(seconds: 2), () async {
      await stopScan();
    });

    return completer.future.timeout(
      const Duration(seconds: 3),
      onTimeout: () => '',
    );
  }
}
