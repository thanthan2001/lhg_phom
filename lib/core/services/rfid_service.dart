import 'dart:async';
import 'package:flutter/services.dart';

class RFIDService {
  static const MethodChannel _channel = MethodChannel('rfid_channel');
  static Function(String epc)? _onScanCallback;
  static bool _handlerInitialized = false;

  /// Chỉ gọi 1 lần để đăng ký nhận từ native
  static void _registerHandlerOnce() {
    if (_handlerInitialized) return;
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onTagScanned':
          final epc = call.arguments as String;
          _onScanCallback?.call(epc);
          break;
        case 'onConnected':
          print('✅ Native báo đã kết nối thành công');
          break;
        case 'onError':
          print('❌ Native báo lỗi: ${call.arguments}');
          break;
        case 'onContinuousScanStart':
          print('🔁 Native báo đã bắt đầu quét liên tục');
          break;
        case 'onScanStopped':
          print('🛑 Native báo đã dừng quét');
          break;
        default:
          print('⚠️ Không nhận diện method native: ${call.method}');
      }
    });
    _handlerInitialized = true;
  }

  /// Kết nối đến thiết bị RFID
  static Future<bool> connect() async {
    _registerHandlerOnce();
    try {
      final result = await _channel.invokeMethod<bool>('connectRFID');
      return result ?? false;
    } catch (e) {
      print('❌ Lỗi khi connect: $e');
      return false;
    }
  }

  /// Ngắt kết nối với thiết bị
  static Future<void> disconnect() async {
    await _channel.invokeMethod('disconnectRFID');
  }

  /// Bắt đầu quét liên tục, truyền callback mỗi khi có tag
  static Future<bool> scanContinuous(Function(String epc) onScan) async {
    _registerHandlerOnce();
    _onScanCallback = onScan;

    try {
      await _channel.invokeMethod('scanRFID', {'mode': 1});
      return true;
    } catch (e) {
      print('❌ scanContinuous lỗi: $e');
      return false;
    }
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
    _registerHandlerOnce();

    _onScanCallback = (epc) {
      if (!completer.isCompleted) completer.complete(epc);
    };

    try {
      await _channel.invokeMethod('scanRFID', {'mode': 0});
      return await completer.future.timeout(timeout);
    } catch (e) {
      print('❌ Timeout hoặc lỗi khi quét 1 lần: $e');
      return null;
    }
  }

  static Future<List<String>> scanSingleTagMultiple({
    Duration timeout = const Duration(milliseconds: 100),
  }) async {
    final Set<String> uniqueEPCs = {}; // Tránh trùng lặp
    final completer = Completer<List<String>>();

    _registerHandlerOnce();
    _onScanCallback = (epc) {
      uniqueEPCs.add(epc);
    };

    try {
      await _channel.invokeMethod('scanRFID', {'mode': 0});
      Future.delayed(timeout, () async {
        await stopScan();
        completer.complete(uniqueEPCs.toList());
      });
      return completer.future;
    } catch (e) {
      print('❌ Lỗi quét nhiều EPC: \$e');
      return [];
    }
  }
}
