import 'dart:async';
import 'package:flutter/services.dart';

class RFIDService {
  static const MethodChannel _channel = MethodChannel('rfid_channel');

  static Function(String epc)? _onScanCallback;

  /// Kết nối đến thiết bị RFID
  static Future<bool> connect() async {
    return await _channel.invokeMethod('connectRFID');
  }

  /// Ngắt kết nối với thiết bị
  static Future<void> disconnect() async {
    await _channel.invokeMethod('disconnectRFID');
  }

  /// Đăng ký xử lý phản hồi từ native
  static void _registerMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onTagScanned') {
        final epc = call.arguments as String;
        _onScanCallback?.call(epc);
      }
    });
  }

  /// Bắt đầu quét liên tục, truyền callback mỗi khi có tag
  static Future<void> scanContinuous(Function(String epc) onScan) async {
    _onScanCallback = onScan;
    _registerMethodCallHandler();
    await _channel.invokeMethod('scanRFID', {'mode': 1});
  }

  /// Dừng quét liên tục
  static Future<void> stopScan() async {
    await _channel.invokeMethod('stopScan');
    _onScanCallback = null;
  }

  /// Quét 1 lần, trả về EPC đầu tiên quét được
  static Future<String?> scanSingleTag({
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final completer = Completer<String>();
    _onScanCallback = (epc) {
      if (!completer.isCompleted) completer.complete(epc);
    };

    _registerMethodCallHandler();
    await _channel.invokeMethod('scanRFID', {'mode': 0});

    return completer.future.timeout(timeout, onTimeout: () => '');
  }
}
