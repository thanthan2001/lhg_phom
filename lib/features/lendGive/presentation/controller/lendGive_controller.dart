import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lhg_phom/core/services/models/user/domain/usecase/get_user_use_case.dart';
import 'package:lhg_phom/core/services/models/user/model/user_model.dart';
import 'package:lhg_phom/core/services/rfid_service.dart';
import '../../../../core/services/dio.api.service.dart';

class LendGiveController extends GetxController {
  final GetuserUseCase _getuserUseCase;
  LendGiveController(this._getuserUseCase);

  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  final inventoryDataMap = <String, Map<String, dynamic>>{}.obs;
  var inventoryData = <List<String>>[].obs;

  final Set<String> processedRfidsInSession = <String>{};
  final RxList<Map<String, dynamic>> scannedRfidDetailsList =
      <Map<String, dynamic>>[].obs;
  final RxList<String> invalidRfids = <String>[].obs;

  final RxList<Map<String, String>> mismatchedRfids =
      <Map<String, String>>[].obs;
  final RxList<Map<String, String>> excessRfids = <Map<String, String>>[].obs;

  final bill_br_id = TextEditingController();
  final totalPhomNotBindingController = TextEditingController(text: '0');
  final dateController = TextEditingController();

  final isScanning = false.obs;
  final isLoading = false.obs;
  var totalScannedCount = 0.0.obs;
  var totalExpectedCount = 0.obs;
  var isAvalableScan = false.obs;
  var lastScanStatus = ''.obs;

  UserModel? user;
  String? companyName;
  String? idBillFromSearch;

  final List<String> headers = [
    'ID Bill',
    'Dep ID',
    'Mã Phom',
    'Tên Phom',
    'Size',
    'SL Mượn (Đôi)',
    'Đã Quét (Đôi)',
  ];

  void _resetScanStateForNewSession() {
    processedRfidsInSession.clear();
    scannedRfidDetailsList.clear();
    lastScanStatus.value = '';
    totalScannedCount.value = 0.0;

    invalidRfids.clear();
    mismatchedRfids.clear();
    excessRfids.clear();

    inventoryDataMap.forEach((key, value) {
      value['scannedCount'] = 0.0;
    });

    for (var row in inventoryData) {
      row[6] = '0.0';
    }
    inventoryData.refresh();
  }

  Future<void> onClear() async {
    await onStopRead(showReport: false);

    bill_br_id.clear();
    totalPhomNotBindingController.text = '0';
    inventoryData.clear();
    inventoryDataMap.clear();
    processedRfidsInSession.clear();
    scannedRfidDetailsList.clear();
    invalidRfids.clear();
    mismatchedRfids.clear();
    excessRfids.clear();
    isAvalableScan.value = false;
    lastScanStatus.value = '';
    totalScannedCount.value = 0.0;
    totalExpectedCount.value = 0;
    idBillFromSearch = null;

    Get.snackbar(
      "Thông báo",
      "Đã xóa toàn bộ dữ liệu, sẵn sàng cho phiếu mượn mới.",
      backgroundColor: Colors.blueAccent,
      colorText: Colors.white,
    );
  }

  Future<void> onSearch() async {
    final String billIdToSearch = bill_br_id.text.trim();
    if (billIdToSearch.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng nhập mã số đơn mượn.');
      return;
    }
    isLoading.value = true;
    await onStopRead(showReport: false);

    inventoryData.clear();
    inventoryDataMap.clear();
    processedRfidsInSession.clear();
    scannedRfidDetailsList.clear();
    invalidRfids.clear();
    mismatchedRfids.clear();
    excessRfids.clear();
    isAvalableScan.value = false;
    lastScanStatus.value = '';
    totalScannedCount.value = 0.0;
    totalExpectedCount.value = 0;
    idBillFromSearch = null;

    final searchData = {"companyName": companyName, "ID_BILL": billIdToSearch};

    try {
      var response = await ApiService(
        baseUrl,
      ).post('/phom/layphieumuon', searchData);
      if (response.data["statusCode"] != 200) {
        throw Exception(
          response.data['message'] ?? 'Lỗi không xác định từ máy chủ',
        );
      }
      final infoBill = response.data["infoBill"];
      if (infoBill == null) throw Exception('Không nhận được thông tin phiếu.');
      if (!infoBill["isConfirm"]) {
        Get.snackbar(
          'Cảnh báo',
          'Phiếu mượn chưa được xác nhận. Không thể quét.',
          backgroundColor: Colors.orange,
        );
        return;
      }
      final List<dynamic>? jsonArray = response.data["data"]?["jsonArray"];
      if (jsonArray == null || jsonArray.isEmpty) {
        Get.snackbar('Thông báo', 'Không tìm thấy dữ liệu cho phiếu mượn này.');
        return;
      }

      idBillFromSearch = jsonArray[0]['ID_bill']?.toString();
      int currentTotalExpected = 0;
      final List<List<String>> tempInventoryData = [];
      final Map<String, Map<String, dynamic>> tempInventoryMap = {};
      for (var item in jsonArray) {
        if (item is Map<String, dynamic>) {
          String lastMatNo = item['LastMatNo']?.toString() ?? '';
          String lastSize = item['LastSize']?.toString().trim() ?? '';
          String key = "${lastMatNo}_$lastSize";
          int lastSum = int.tryParse(item['LastSum']?.toString() ?? '0') ?? 0;
          currentTotalExpected += lastSum;
          final row = [
            item['ID_bill']?.toString() ?? '',
            item['DepID']?.toString() ?? '',
            lastMatNo,
            item['LastName']?.toString() ?? '',
            lastSize,
            lastSum.toString(),
            '0.0',
          ];
          tempInventoryData.add(row);
          tempInventoryMap[key] = {
            'rowData': row,
            'expectedCount': lastSum.toDouble(),
            'scannedCount': 0.0,
            'depId': item['DepID']?.toString() ?? '',
          };
        }
      }
      inventoryData.assignAll(tempInventoryData);
      inventoryDataMap.assignAll(tempInventoryMap);
      totalExpectedCount.value = currentTotalExpected;
      isAvalableScan.value = true;
      Get.snackbar(
        'Thành công',
        'Đã tải thông tin phiếu mượn. Sẵn sàng để quét.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Lỗi tìm kiếm', 'Lỗi: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleScan() {
    if (isScanning.value) {
      onStopRead();
    } else {
      onScanMultipleTags();
    }
  }

  Future<void> onScanMultipleTags() async {
    if (!isAvalableScan.value) {
      Get.snackbar(
        'Cảnh báo',
        'Vui lòng tìm kiếm phiếu mượn hợp lệ trước khi quét.',
      );
      return;
    }
    if (isScanning.value) return;

    _resetScanStateForNewSession();
    isScanning.value = true;

    try {
      await RFIDService.scanContinuous((epc) {
        if (!isScanning.value) return;
        if (processedRfidsInSession.add(epc)) {
          _handleEpc(epc);
        }
      });
    } catch (e) {
      isScanning.value = false;
      lastScanStatus.value = "Lỗi quét: $e";
    }
  }

  Future<void> onStopRead({bool showReport = true}) async {
    if (isScanning.value) {
      await RFIDService.stopScan();
      isScanning.value = false;
      lastScanStatus.value = "Đã dừng quét.";

      if (showReport) {
        _showScanReport();
      }
    }
  }

  void _showScanReport() {
    if (invalidRfids.isEmpty &&
        mismatchedRfids.isEmpty &&
        excessRfids.isEmpty) {
      Get.snackbar(
        "Quét hoàn tất",
        "Tất cả các thẻ quét đều hợp lệ.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return;
    }
    Get.defaultDialog(
      title: "Báo cáo phiên quét",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            if (invalidRfids.isNotEmpty) ...[
              const Text(
                'RFID không tồn tại trong hệ thống:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              Text(invalidRfids.join('\n')),
              const SizedBox(height: 10),
            ],
            if (mismatchedRfids.isNotEmpty) ...[
              const Text(
                'Phom sai (không có trong phiếu mượn):',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              Text(
                mismatchedRfids
                    .map(
                      (item) =>
                          "${item['rfid']} - ${item['matNo']} - Size ${item['size']}",
                    )
                    .join('\n'),
              ),
              const SizedBox(height: 10),
            ],
            if (excessRfids.isNotEmpty) ...[
              const Text(
                'Quét thừa số lượng:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Text(
                excessRfids
                    .map(
                      (item) =>
                          "${item['rfid']} - ${item['matNo']} - Size ${item['size']}",
                    )
                    .join('\n'),
              ),
            ],
          ],
        ),
      ),
      textConfirm: "Đã hiểu",
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(),
    );
  }

  Future<void> _handleEpc(String epc) async {
    final data = {"companyName": companyName, "RFID": epc};
    try {
      final response = await ApiService(
        baseUrl,
      ).post('/phom/getphomrfid', data);

      if (response.statusCode != 200 ||
          response.data?['data'] == null ||
          response.data['data'].isEmpty) {
        lastScanStatus.value = 'RFID $epc không hợp lệ';

        if (!invalidRfids.contains(epc)) invalidRfids.add(epc);
        return;
      }

      final item = response.data['data'][0];
      String lastMatNo = item['LastMatNo']?.toString() ?? 'N/A';
      String lastSize = item['LastSize']?.toString().trim() ?? 'N/A';
      String key = "${lastMatNo}_$lastSize";

      if (inventoryDataMap.containsKey(key)) {
        var entry = inventoryDataMap[key]!;
        double currentScanned = entry['scannedCount'];
        double expected = entry['expectedCount'];

        if (currentScanned < expected) {
          entry['scannedCount'] = currentScanned + 0.5;
          totalScannedCount.value += 0.5;

          List<String> rowData = entry['rowData'];
          rowData[6] = entry['scannedCount'].toString();
          inventoryData.refresh();

          scannedRfidDetailsList.add({
            "StateScan": 0,
            "ID_BILL": idBillFromSearch,
            "DepID": entry['depId'],
            "ScanDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
            "RFID": epc,
            "UserID": user!.userId!,
            "DateBorrow": convertDate(dateController.text),
          });
          lastScanStatus.value = 'Hợp lệ: $lastMatNo - Size $lastSize';
          print(
            '✅ Quét hợp lệ: $key | Đã quét: ${entry['scannedCount']}/${expected}',
          );
        } else {
          lastScanStatus.value = 'Đã đủ SL: $lastMatNo - Size $lastSize';

          if (!excessRfids.any((e) => e['rfid'] == epc)) {
            excessRfids.add({
              'rfid': epc,
              'matNo': lastMatNo,
              'size': lastSize,
            });
          }
        }
      } else {
        lastScanStatus.value = 'Sai phom: $lastMatNo - Size $lastSize';

        if (!mismatchedRfids.any((m) => m['rfid'] == epc)) {
          mismatchedRfids.add({
            'rfid': epc,
            'matNo': lastMatNo,
            'size': lastSize,
          });
        }
      }
    } catch (e) {
      lastScanStatus.value = 'Lỗi xử lý RFID';
    }
  }

  Future<void> onFinish() async {
    if (invalidRfids.isNotEmpty || mismatchedRfids.isNotEmpty) {
      Get.defaultDialog(
        title: "Cảnh báo",
        middleText:
            "Vẫn còn các phom không hợp lệ hoặc sai phom trong phiên quét. Bạn có chắc muốn hoàn tất không?",
        textConfirm: "Vẫn hoàn tất",
        textCancel: "Hủy",
        onConfirm: () {
          Get.back();
          _proceedToFinish();
        },
      );
    } else {
      _proceedToFinish();
    }
  }

  Future<void> _proceedToFinish() async {
    if (scannedRfidDetailsList.isEmpty) {
      Get.snackbar("Thông báo", "Chưa có phom nào được quét.");
      return;
    }
    isLoading.value = true;
    final payload = {
      "companyName": companyName,
      "ToTalPhomNotBinding": totalPhomNotBindingController.text,
      "scannedRfidDetailsList": scannedRfidDetailsList,
    };

    try {
      final response = await ApiService(
        baseUrl,
      ).post('/phom/saveBill', payload);
      if (response.statusCode == 200) {
        final successCount = response.data['successCount'] ?? 0;
        await Get.defaultDialog(
          title: "Hoàn tất",
          middleText: "$successCount mục đã được lưu thành công!",
          textConfirm: "OK",
          onConfirm: () {
            Get.back();
            onClear();
          },
        );
      } else {
        throw Exception("Lưu thất bại. Mã lỗi: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Lỗi hệ thống", "Không thể gửi dữ liệu. ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  String convertDate(String inputDate) {
    try {
      final parts = inputDate.split('/');
      return "${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}";
    } catch (_) {
      return inputDate;
    }
  }

  @override
  void onInit() async {
    super.onInit();
    isLoading.value = true;
    try {
      user = await _getuserUseCase.getUser();
      if (user?.companyName == null || user!.companyName!.isEmpty) {
        throw Exception('Không tìm thấy thông tin người dùng hoặc công ty.');
      }
      companyName = user!.companyName;
      RFIDService.setOnHardwareScan(toggleScan);
      dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    } catch (e) {
      Get.snackbar('Lỗi khởi tạo', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    bill_br_id.dispose();
    totalPhomNotBindingController.dispose();
    dateController.dispose();
    onStopRead(showReport: false);
    super.onClose();
  }
}
