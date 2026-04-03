import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lhg_phom/core/services/models/user/domain/usecase/get_user_use_case.dart';
import 'package:lhg_phom/core/services/models/user/model/user_model.dart';
import 'package:lhg_phom/core/services/rfid_service.dart';

import '../../../../core/services/dio.api.service.dart';

class QuickScanBorrowController extends GetxController {
  final GetuserUseCase _getuserUseCase;
  QuickScanBorrowController(this._getuserUseCase);

  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  final isLoading = false.obs;
  final isScanning = false.obs;
  final isSaving = false.obs;

  final departmentList = <String>[].obs;
  final Map<String, String> depNameToIdMap = {};
  final selectedDepartment = ''.obs;
  final selectedDepartmentId = ''.obs;
  final userIdController = TextEditingController();

  final headers = const [
    'Mã Phom',
    'Size',
    'Trái',
    'Phải',
    'Chênh lệch',
    'Đã quét (đôi)',
  ];

  final inventoryDataMap = <String, Map<String, dynamic>>{}.obs;
  final inventoryData = <List<String>>[].obs;

  final processedRfidsInSession = <String>{};
  final scannedEpcList = <String>[].obs;

  final invalidRfids = <String>[].obs;
  final invalidRfidDetails = <Map<String, String>>[].obs;
  final outRfids = <Map<String, String>>[].obs;
  final lostRfids = <Map<String, String>>[].obs;

  final totalScannedEPCs = 0.obs;
  final totalScannedPairs = 0.0.obs;
  final lastScanStatus = ''.obs;

  final savedBills = <Map<String, dynamic>>[].obs;
  final saveSummary = ''.obs;

  UserModel? user;
  String? companyName;

  static const Duration _shortApiTimeout = Duration(seconds: 12);
  static const Duration _mediumApiTimeout = Duration(seconds: 20);
  static const Duration _longApiTimeout = Duration(seconds: 30);

  bool get hasRfidErrors =>
      invalidRfids.isNotEmpty || outRfids.isNotEmpty || lostRfids.isNotEmpty;

  @override
  void onInit() async {
    super.onInit();
    isLoading.value = true;
    try {
      user = await _getuserUseCase.getUser();
      companyName = user?.companyName;
      if (companyName == null || companyName!.isEmpty) {
        throw Exception('Không tìm thấy thông tin công ty người dùng.');
      }
      await getDepartment();
      RFIDService.setOnHardwareScan(toggleScan);
    } catch (e) {
      _showFeedback('Lỗi khởi tạo', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    RFIDService.stopScan();
    userIdController.dispose();
    super.onClose();
  }

  void _showFeedback(String title, String message) {
    debugPrint('[$title] $message');
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );

    final lowerTitle = title.toLowerCase();
    final isError = lowerTitle.contains('lỗi') || lowerTitle.contains('error');
    if (isError) {
      _showErrorDialog(title: title, message: message);
    }
  }

  void _showErrorDialog({required String title, required String message}) {
    if (Get.isDialogOpen ?? false) {
      return;
    }

    Get.defaultDialog(
      title: title,
      middleText: message,
      textConfirm: 'Đóng',
      confirmTextColor: Colors.white,
      onConfirm: () {
        if (Get.context != null) {
          Navigator.of(Get.context!).pop();
        }
      },
    );
  }

  Future<void> getDepartment() async {
    if (companyName == null || companyName!.isEmpty) return;
    try {
      final response = await ApiService(
        baseUrl,
      ).post(
        '/phom/getDepartment',
        {'companyName': companyName},
        timeout: _mediumApiTimeout,
      );

      final List<dynamic>? jsonArray = response.data?['data']?['jsonArray'];
      if (response.statusCode == 200 && jsonArray != null) {
        final names = <String>[];
        final map = <String, String>{};
        for (final e in jsonArray) {
          final depName = e['DepName']?.toString() ?? '';
          final depId = e['ID']?.toString() ?? '';
          if (depName.isNotEmpty && depId.isNotEmpty) {
            names.add(depName);
            map[depName] = depId;
          }
        }
        departmentList.assignAll(names);
        depNameToIdMap
          ..clear()
          ..addAll(map);
        if (names.isNotEmpty) {
          selectedDepartment.value = names.first;
          selectedDepartmentId.value = depNameToIdMap[names.first] ?? '';
        }
      }
    } catch (e) {
      _showFeedback('Lỗi', 'Không thể tải danh sách đơn vị: $e');
    }
  }

  void onChangeDepartment(String departmentName) {
    selectedDepartment.value = departmentName;
    selectedDepartmentId.value = depNameToIdMap[departmentName] ?? '';
  }

  void toggleScan() {
    if (isScanning.value) {
      onStopRead(showSummary: true);
    } else {
      onScanMultipleTags();
    }
  }

  void _resetSessionState() {
    processedRfidsInSession.clear();
    scannedEpcList.clear();

    invalidRfids.clear();
    invalidRfidDetails.clear();
    outRfids.clear();
    lostRfids.clear();

    inventoryDataMap.clear();
    inventoryData.clear();

    totalScannedEPCs.value = 0;
    totalScannedPairs.value = 0.0;
    lastScanStatus.value = '';

    savedBills.clear();
    saveSummary.value = '';
  }

  Future<void> onClear() async {
    await onStopRead(showSummary: false);
    _resetSessionState();
  }

  Future<void> onScanMultipleTags() async {
    if (selectedDepartmentId.value.isEmpty) {
      _showFeedback('Cảnh báo', 'Vui lòng chọn đơn vị mượn trước khi quét.');
      return;
    }
    if (isScanning.value) return;

    final connected = await RFIDService.connect();
    if (!connected) {
      _showFeedback('Lỗi', 'Không thể kết nối với thiết bị RFID.');
      return;
    }

    _resetSessionState();
    isScanning.value = true;

    try {
      await RFIDService.clearScannedTags();
      await RFIDService.scanContinuous((epc) {
        if (!isScanning.value) return;
        if (processedRfidsInSession.add(epc)) {
          totalScannedEPCs.value += 1;
          _handleEpc(epc);
        }
      });
    } catch (e) {
      isScanning.value = false;
      lastScanStatus.value = 'Lỗi quét: $e';
    }
  }

  Future<void> onStopRead({bool showSummary = true}) async {
    if (!isScanning.value) return;
    try {
      await RFIDService.stopScan();
    } finally {
      isScanning.value = false;
      lastScanStatus.value = 'Đã dừng quét';
      if (showSummary) {
        _showScanSummaryDialog();
      }
    }
  }

  Future<void> _handleEpc(String epc) async {
    final data = {'companyName': companyName, 'RFID': epc};

    try {
      final response = await ApiService(
        baseUrl,
      ).post('/phom/getphomrfid', data, timeout: _shortApiTimeout);

      final List<dynamic>? responseData = response.data?['data'];
      if (response.statusCode != 200 ||
          responseData == null ||
          responseData.isEmpty) {
        if (!invalidRfids.contains(epc)) {
          invalidRfids.add(epc);
        }
        _upsertInvalidRfidDetail(epc: epc);
        lastScanStatus.value = 'RFID không có dữ liệu: $epc';
        return;
      }

      final item = responseData.first as Map<String, dynamic>;
      final lastNo = item['LastNo']?.toString().trim() ?? 'N/A';
      final lastSize = item['LastSize']?.toString().trim() ?? 'N/A';
      final rawSide = item['LastSide']?.toString().trim() ?? '';
      final side = _normalizeSide(rawSide);

      final isOut = _isTruthy(item['isOut']);
      final isLost = _isTruthy(item['isLost']);

      if (isOut) {
        outRfids.add({'rfid': epc, 'matNo': lastNo, 'size': lastSize});
        lastScanStatus.value = 'Phom đã mượn: $lastNo - Size $lastSize';
        return;
      }

      if (isLost) {
        lostRfids.add({'rfid': epc, 'matNo': lastNo, 'size': lastSize});
        lastScanStatus.value = 'Phom mất/hỏng: $lastNo - Size $lastSize';
        return;
      }

      if (side == 'unknown') {
        if (!invalidRfids.contains(epc)) {
          invalidRfids.add(epc);
        }
        _upsertInvalidRfidDetail(epc: epc, lastNo: lastNo, lastSize: lastSize);
        lastScanStatus.value =
            'Không xác định bên trái/phải: $lastNo - Size $lastSize';
        return;
      }

      scannedEpcList.add(epc);
      _updateInventoryRow(lastNo: lastNo, lastSize: lastSize, side: side);
      lastScanStatus.value = 'Hợp lệ: $lastNo - Size $lastSize';
    } catch (e) {
      lastScanStatus.value = 'Lỗi xử lý RFID: $epc';
    }
  }

  String _normalizeSide(String rawSide) {
    final sideLower = rawSide.toLowerCase();
    if (sideLower.startsWith('l')) return 'left';
    if (sideLower.startsWith('r') || sideLower.startsWith('p')) return 'right';
    return 'unknown';
  }

  bool _isTruthy(dynamic value) {
    if (value == true) return true;
    final normalized = value?.toString().toLowerCase().trim();
    return normalized == '1' || normalized == 'true';
  }

  void _upsertInvalidRfidDetail({
    required String epc,
    String lastNo = 'N/A',
    String lastSize = 'N/A',
  }) {
    if (invalidRfidDetails.any((x) => x['rfid'] == epc)) return;
    invalidRfidDetails.add({'rfid': epc, 'matNo': lastNo, 'size': lastSize});
  }

  void _updateInventoryRow({
    required String lastNo,
    required String lastSize,
    required String side,
  }) {
    final key = '${lastNo}_$lastSize';

    if (!inventoryDataMap.containsKey(key)) {
      final row = [lastNo, lastSize, '0', '0', '0', '0.0'];
      inventoryDataMap[key] = {
        'rowData': row,
        'lastNo': lastNo,
        'lastSize': lastSize,
        'leftCount': 0,
        'rightCount': 0,
        'scannedCount': 0.0,
      };
      inventoryData.add(row);
    }

    final entry = inventoryDataMap[key]!;
    final prevPairs = (entry['scannedCount'] as double?) ?? 0.0;

    if (side == 'left') {
      entry['leftCount'] = (entry['leftCount'] as int? ?? 0) + 1;
    } else if (side == 'right') {
      entry['rightCount'] = (entry['rightCount'] as int? ?? 0) + 1;
    }

    final leftCount = entry['leftCount'] as int;
    final rightCount = entry['rightCount'] as int;
    final newPairs =
        (leftCount < rightCount ? leftCount : rightCount).toDouble();

    entry['scannedCount'] = newPairs;

    final rowData = entry['rowData'] as List<String>;
    rowData[2] = leftCount.toString();
    rowData[3] = rightCount.toString();
    rowData[4] = (leftCount - rightCount).abs().toString();
    rowData[5] = newPairs.toString();

    totalScannedPairs.value += newPairs - prevPairs;
    inventoryData.refresh();
  }

  Future<void> onFinish() async {
    if (isScanning.value) {
      _showFeedback('Cảnh báo', 'Vui lòng dừng quét trước khi hoàn tất.');
      return;
    }

    if (scannedEpcList.isEmpty) {
      _showFeedback('Thông báo', 'Chưa có EPC hợp lệ để tạo phiếu mượn nhanh.');
      return;
    }

    if (hasRfidErrors) {
      _showFeedback(
        'Cảnh báo',
        'Phiên quét còn RFID lỗi. Vui lòng xử lý/xóa dữ liệu lỗi trước khi lưu.',
      );
      return;
    }

    final enteredUserId = userIdController.text.trim();
    if (enteredUserId.isEmpty) {
      _showFeedback('Cảnh báo', 'Vui lòng nhập UserID trước khi lưu.');
      return;
    }

    isSaving.value = true;
    var hasShownResult = false;

    try {
      if (baseUrl.trim().isEmpty) {
        throw Exception(
          'BASE_URL đang rỗng. Kiểm tra file .env đã được đóng gói trong build chưa.',
        );
      }

      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final payload = {
        'companyName': companyName,
        'DepID': selectedDepartmentId.value,
        'UserID': enteredUserId,
        'OfficerId': enteredUserId,
        'DateBorrow': now,
        'DateReceive': now,
        'EPCList': scannedEpcList.toList(),
      };

      final response = await ApiService(
        baseUrl.trim(),
      ).post('/phom/quickScanBorrow', payload, timeout: _longApiTimeout);
      debugPrint('Quick Scan Borrow Response: ${response.data}');

      final dynamic rawBody = response.data;
      Map<String, dynamic>? responseBody;
      if (rawBody is Map<String, dynamic>) {
        responseBody = rawBody;
      } else if (rawBody is Map) {
        responseBody = Map<String, dynamic>.from(rawBody);
      } else if (rawBody is String && rawBody.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(rawBody);
          if (decoded is Map) {
            responseBody = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {
          responseBody = null;
        }
      }

      final statusCode = responseBody?['statusCode'];
      final status = responseBody?['status']?.toString().toLowerCase();
      final isHttpSuccess =
          (response.statusCode ?? 0) >= 200 && (response.statusCode ?? 0) < 300;
      final isApiSuccess =
          status == 'success' || statusCode?.toString() == '200';

      if (isHttpSuccess && isApiSuccess) {
        final data = responseBody?['data'];
        List<dynamic> rawBills = const [];
        int totalBills = 0;

        if (data is Map) {
          final billsValue = data['bills'];
          if (billsValue is List) {
            rawBills = billsValue;
          }

          final totalBillsValue = data['totalBills'];
          if (totalBillsValue is int) {
            totalBills = totalBillsValue;
          } else {
            totalBills = int.tryParse(totalBillsValue?.toString() ?? '') ?? 0;
          }
        }

        final bills =
            rawBills
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList();

        if (totalBills == 0) {
          totalBills = bills.length;
        }

        saveSummary.value = 'Tạo thành công $totalBills phiếu mượn nhanh.';
        savedBills.assignAll(bills);

        final invalidEpc = responseBody?['invalidEPC'];
        _applyInvalidFromQuickScan(invalidEpc);

        _showSaveResultDialog(
          message: responseBody?['message']?.toString() ?? 'Thành công',
        );
        hasShownResult = true;
        _resetSessionState();
      } else {
        final invalidEpc = responseBody?['invalidEPC'];
        _applyInvalidFromQuickScan(invalidEpc);
        final apiMessage = responseBody?['message']?.toString();
        final failMessage =
            apiMessage ??
            'Quick scan borrow thất bại. HTTP ${response.statusCode} - ${response.statusMessage}. status=${responseBody?['status']}, statusCode=${responseBody?['statusCode']}';

        debugPrint(
          '[QuickScanBorrow][SaveFail] payload=$payload | response=$rawBody',
        );
        _showFeedback('Lỗi lưu phiếu', failMessage);
        hasShownResult = true;
        return;
      }
    } catch (e) {
      debugPrint('[QuickScanBorrow][SaveException] $e');
      String errorMessage = e.toString();
      // Nếu bạn dùng Dio, e có thể ép kiểu để lấy status code
      // if (e is DioException) { errorMessage = e.message ?? "Lỗi mạng"; }
      _showFeedback('Lỗi kỹ thuật', 'Chi tiết: $errorMessage');
      hasShownResult = true;
    } finally {
      isSaving.value = false;
      if (!hasShownResult) {
        _showFeedback(
          'Lỗi lưu phiếu',
          'Không nhận được phản hồi hợp lệ từ máy chủ. Vui lòng thử lại.',
        );
      }
    }
  }

  void _applyInvalidFromQuickScan(dynamic invalidEpc) {
    if (invalidEpc is! Map) return;

    final notFound =
        (invalidEpc['notFoundEPC'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();
    for (final epc in notFound) {
      if (!invalidRfids.contains(epc)) invalidRfids.add(epc);
      _upsertInvalidRfidDetail(epc: epc);
    }

    final outList =
        (invalidEpc['outEPC'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();
    for (final epc in outList) {
      if (!outRfids.any((x) => x['rfid'] == epc)) {
        outRfids.add({'rfid': epc, 'matNo': 'N/A', 'size': 'N/A'});
      }
    }

    final lostList =
        (invalidEpc['lostEPC'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();
    for (final epc in lostList) {
      if (!lostRfids.any((x) => x['rfid'] == epc)) {
        lostRfids.add({'rfid': epc, 'matNo': 'N/A', 'size': 'N/A'});
      }
    }
  }

  void _showScanSummaryDialog() {
    final pairLines = _buildPairSummaryLines();
    final invalidLines = <String>[
      ...invalidRfidDetails.map(
        (x) =>
            '- EPC: ${x['rfid'] ?? ''} - ${x['matNo'] ?? 'N/A'} - ${x['size'] ?? 'N/A'}',
      ),
      ...outRfids.map(
        (x) =>
            '- EPC: ${x['rfid'] ?? ''} - ${x['matNo'] ?? 'N/A'} - ${x['size'] ?? 'N/A'}',
      ),
      ...lostRfids.map(
        (x) =>
            '- EPC: ${x['rfid'] ?? ''} - ${x['matNo'] ?? 'N/A'} - ${x['size'] ?? 'N/A'}',
      ),
    ];

    Get.defaultDialog(
      title: 'Kết thúc quét',
      middleText: [
        'Đã quét ${totalScannedEPCs.value} EPC',
        'Hợp lệ - Tổng số đôi: ${totalScannedPairs.value}',
        if (pairLines.isNotEmpty) 'LastNo - LastSize - Số đôi hợp lệ:',
        ...pairLines,
        'Không dữ liệu: ${invalidRfids.length}',
        'Đã mượn: ${outRfids.length}',
        'Mất/hỏng: ${lostRfids.length}',
        if (invalidLines.isNotEmpty) 'EPC lỗi - LastNo - LastSize:',
        ...invalidLines,
      ].join('\n'),
      textConfirm: 'Đóng',
      onConfirm: () {
        if (Get.context != null) {
          Navigator.of(Get.context!).pop();
        }
      },
    );
  }

  void _showSaveResultDialog({required String message}) {
    final pairLines = _buildPairSummaryLines();

    final lines = <String>[
      saveSummary.value,
      message,
      'Tổng số đôi hợp lệ: ${totalScannedPairs.value}',
      if (pairLines.isNotEmpty) 'Mã Phom - Size - Số lượng đôi:',
      ...pairLines,
      if (savedBills.isNotEmpty) 'Danh sách bill:',
      ...savedBills.map(
        (b) =>
            '- ${b['ID_BILL'] ?? ''} | ${b['LastMatNo'] ?? ''} | EPC: ${(b['scannedEPC'] as List?)?.length ?? 0}',
      ),
    ];

    Get.defaultDialog(
      title: 'Quick Scan Borrow',
      middleText: lines.join('\n'),
      textConfirm: 'OK',
      onConfirm: () {
        if (Get.context != null) {
          Navigator.of(Get.context!).pop();
        }
      },
    );
  }

  List<String> _buildPairSummaryLines() {
    final lines = <String>[];
    for (final row in inventoryData) {
      if (row.length < 6) continue;
      final pairCount = double.tryParse(row[5]) ?? 0.0;
      if (pairCount <= 0) continue;
      lines.add('- ${row[0]} - ${row[1]} - $pairCount');
    }
    return lines;
  }
}
