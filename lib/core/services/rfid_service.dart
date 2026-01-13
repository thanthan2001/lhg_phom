import 'dart:async';
import 'package:flutter/services.dart';

class RFIDService {
  static const MethodChannel _channel = MethodChannel('rfid_channel');
  static Function(String epc)? _onScanCallback;
  static bool _handlerInitialized = false;
  static Function()? _onHardwareScanCallback;

  static void setOnHardwareScan(Function() callback) {
    _onHardwareScanCallback = callback;
    _registerHandlerOnce();
  }

  static void _registerHandlerOnce() {
    if (_handlerInitialized) return;
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onTagScanned':
          final epc = call.arguments as String;
          _onScanCallback?.call(epc);
          break;

        case 'onScanButtonPressed':
          _onHardwareScanCallback?.call();
          break;

        case 'onConnected':
          break;
        case 'onError':
          break;
        case 'onContinuousScanStart':
          break;
        case 'onScanStopped':
          break;
        default:
      }
    });
    _handlerInitialized = true;
  }

  static Future<bool> connect() async {
    _registerHandlerOnce();
    try {
      final result = await _channel.invokeMethod<bool>('connectRFID');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> disconnect() async {
    await _channel.invokeMethod('disconnectRFID');
  }

  static Future<bool> scanContinuous(Function(String epc) onScan) async {
    _registerHandlerOnce();
    _onScanCallback = onScan;

    try {
      await _channel.invokeMethod('scanRFID', {'mode': 1});
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> stopScan() async {
    await _channel.invokeMethod('stopScan');
    _onScanCallback = null;
  }

  /// Clear scanned tags cache at native level
  static Future<void> clearScannedTags() async {
    try {
      await _channel.invokeMethod('clearScannedTags');
    } catch (e) {
      print('Error clearing scanned tags: $e');
    }
  }

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
      return null;
    }
  }

  static Future<List<String>> scanSingleTagMultiple({
    Duration timeout = const Duration(milliseconds: 100),
  }) async {
    final Set<String> uniqueEPCs = {};
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
      return [];
    }
  }
}
