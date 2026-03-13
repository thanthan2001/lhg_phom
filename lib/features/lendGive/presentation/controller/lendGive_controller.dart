import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lhg_phom/core/configs/app_colors.dart';
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

  // BIẾN LƯU TRỮ CÁC TRƯỢNG HỢP LỖI
  final RxList<String> invalidRfids = <String>[].obs; // RFID không có dữ liệu
  final RxList<Map<String, String>> mismatchedRfids =
      <Map<String, String>>[].obs; // Phom không có trong phiếu
  final RxList<Map<String, String>> excessRfids =
      <Map<String, String>>[].obs; // Quét thừa SL
  final RxList<Map<String, String>> wrongSizeRfids =
      <Map<String, String>>[].obs; // Quét sai size (không được chọn)
  // ***** THÊM MỚI *****
  final RxList<Map<String, String>> alreadyLentRfids =
      <Map<String, String>>[].obs; // Phom đã được mượn

  final bill_br_id = TextEditingController();
  final totalPhomNotBindingController = TextEditingController(text: '0');
  final receiverCardNumberController = TextEditingController();
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
    'Tên Phom',
    'Size',
    'SL Mượn (Đôi)',
    'Trái',
    'Phải',
    'Chênh Lệch',
    'Đã Quét (Đôi)',
  ];

  // Safe feedback helper - uses print for async contexts
  void _showFeedback(String title, String message) {
    print('[$title] $message');
  }

  void _resetScanStateForNewSession() {
    processedRfidsInSession.clear();
    scannedRfidDetailsList.clear();
    lastScanStatus.value = '';
    totalScannedCount.value = 0.0;
    invalidRfids.clear();
    mismatchedRfids.clear();
    excessRfids.clear();
    wrongSizeRfids.clear();
    alreadyLentRfids.clear();
    inventoryDataMap.forEach((key, value) {
      value['scannedCount'] = 0.0;
      value['leftCount'] = 0;
      value['rightCount'] = 0;
    });
    for (var row in inventoryData) {
      row[3] = '0';  // Left count
      row[4] = '0';  // Right count
      row[5] = '0';  // Difference
      row[6] = '0.0';  // Scanned count (moved to end)
    }
    inventoryData.refresh();
  }

  Future<void> onClear() async {
    await onStopRead(showReport: false);
    bill_br_id.clear();
    totalPhomNotBindingController.text = '0';
    receiverCardNumberController.clear();
    inventoryData.clear();
    inventoryDataMap.clear();
    processedRfidsInSession.clear();
    scannedRfidDetailsList.clear();
    invalidRfids.clear();
    mismatchedRfids.clear();
    excessRfids.clear();
    wrongSizeRfids.clear();
    alreadyLentRfids.clear();
    isAvalableScan.value = false;
    lastScanStatus.value = '';
    totalScannedCount.value = 0.0;
    totalExpectedCount.value = 0;
    idBillFromSearch = null;
    _showFeedback('Thông báo', 'Đã xóa toàn bộ dữ liệu, sẵn sàng cho phiếu mượn mới.');
  }

  Future<void> onSearch() async {
    final String billIdToSearch = bill_br_id.text.trim();
    if (billIdToSearch.isEmpty) {
      _showFeedback('Lỗi', 'Vui lòng nhập mã số đơn mượn.');
      return;
    }
    isLoading.value = true;
    await onStopRead(showReport: false);

    // ***** CHỈNH SỬA *****
    // Gọi onClear() để reset tất cả các trạng thái, bao gồm cả list lỗi mới
    await onClear();
    bill_br_id.text = billIdToSearch; // Gán lại mã vừa tìm kiếm

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
        _showFeedback('Cảnh báo', 'Phiếu mượn chưa được xác nhận. Không thể quét.');
        return;
      }
      final List<dynamic>? jsonArray = response.data["data"]?["jsonArray"];
      if (jsonArray == null || jsonArray.isEmpty) {
        _showFeedback('Thông báo', 'Không tìm thấy dữ liệu cho phiếu mượn này.');
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
            item['LastName']?.toString() ?? '',
            lastSize,
            lastSum.toString(),
            '0',  // leftCount (index 3)
            '0',  // rightCount (index 4)
            '0',  // difference (index 5)
            '0.0',  // scannedCount (index 6) - chuyển về cuối
          ];
          tempInventoryData.add(row);
          tempInventoryMap[key] = {
            'rowData': row,
            'expectedCount': lastSum.toDouble(),
            'scannedCount': 0.0,
            'leftCount': 0,
            'rightCount': 0,
            'depId': item['DepID']?.toString() ?? '',
            'idBill': item['ID_bill']?.toString() ?? '',
            'matNo': lastMatNo,
            'displayMatNo': '', // Sẽ cập nhật khi quét RFID
          };
        }
      }
      inventoryData.assignAll(tempInventoryData);
      inventoryDataMap.assignAll(tempInventoryMap);
      totalExpectedCount.value = currentTotalExpected;
      isAvalableScan.value = true;
      _showFeedback('Thành công', 'Đã tải thông tin phiếu mượn. Sẵn sàng để quét.');
    } catch (e) {
      _showFeedback('Lỗi tìm kiếm', 'Lỗi: ${e.toString()}');
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
      _showFeedback('Cảnh báo', 'Vui lòng tìm kiếm phiếu mượn hợp lệ trước khi quét.');
      return;
    }
    if (isScanning.value) return;

    // Connect to RFID device first
    final connected = await RFIDService.connect();
    if (!connected) {
      _showFeedback('Lỗi', 'Không thể kết nối với thiết bị RFID');
      return;
    }

    _resetScanStateForNewSession();
    isScanning.value = true;

    try {
      // Clear native cache to start fresh
      await RFIDService.clearScannedTags();
      
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
        _showScanSummaryDialog();
      }
    }
  }

  Map<String, int> _groupRfidErrors(List<Map<String, String>> errorList) {
    final Map<String, int> groupedMap = {};
    for (var item in errorList) {
      final key = "${item['matNo']} - ${item['size']}";
      groupedMap[key] = (groupedMap[key] ?? 0) + 1;
    }
    return groupedMap;
  }

  Widget _buildErrorExpansionTile({
    required String title,
    required int totalCount,
    required Map<String, int> detailsMap,
    required IconData icon,
    required Color color,
  }) {
    if (totalCount == 0) return const SizedBox.shrink();

    return ExpansionTile(
      leading: Icon(icon, color: color, size: 20),
      title: Row(
        children: [
          Expanded(
            flex: 3, // Text chiếm nhiều hơn
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.visible,
            ),
          ),
          const SizedBox(width: 4),
          Chip(
            label: Text(
              '$totalCount đôi',
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
            backgroundColor: color.withOpacity(0.8),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
      children:
          detailsMap.entries.map((entry) {
            final pairCount = entry.value ~/ 2;
            if (pairCount == 0) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 12,
                top: 3,
                bottom: 3,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 4, // Text chiếm nhiều không gian hơn
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$pairCount đôi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  void _showScanSummaryDialog() {
    // Tính tổng expected và scanned
    double totalExpected = 0.0;
    double totalScanned = 0.0;

    // Nhóm các phom hợp lệ đã quét theo displayMatNo (lastNo) - size
    Map<String, double> validScannedMap = {};

    inventoryDataMap.forEach((key, value) {
      totalExpected += value['expectedCount'] as double;
      totalScanned += value['scannedCount'] as double;

      // Nếu phom này đã được quét (scannedCount > 0), thêm vào danh sách hợp lệ
      if (value['scannedCount'] > 0) {
        String displayMatNo =
            value['displayMatNo']?.toString() ??
            value['matNo']?.toString() ??
            '';
        String size = value['rowData'][1]; // Size
        String displayKey = "$displayMatNo - $size";
        validScannedMap[displayKey] = value['scannedCount'];
      }
    });

    // Nhóm các lỗi để hiển thị chi tiết
    final excessDetails = _groupRfidErrors(excessRfids);
    final mismatchedDetails = _groupRfidErrors(mismatchedRfids);
    final alreadyLentDetails = _groupRfidErrors(alreadyLentRfids);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        child: Container(
          width: double.infinity, // Full width
          constraints: BoxConstraints(maxHeight: Get.height * 0.85),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.assessment, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Kết quả phiên quét",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        try {
                          if (Get.context != null) {
                            Navigator.of(Get.context!).pop();
                          }
                        } catch (e) {
                          print('Error closing dialog: $e');
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Quét hợp lệ (đôi):",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 8.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(
                              child: Text(
                                "Tổng:",
                                style: TextStyle(fontSize: 15),
                                overflow: TextOverflow.visible,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text.rich(
                              TextSpan(
                                style: const TextStyle(fontSize: 15),
                                children: [
                                  TextSpan(
                                    text: totalScanned.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          totalScanned >= totalExpected
                                              ? AppColors.green
                                              : Colors.deepOrange,
                                    ),
                                  ),
                                  TextSpan(text: " / $totalExpected"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Hiển thị chi tiết từng phom hợp lệ
                      if (validScannedMap.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ...validScannedMap.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 12.0,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.green,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    entry.key, // "lastNo - size"
                                    style: const TextStyle(fontSize: 13),
                                    maxLines: 2,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "${entry.value} đôi",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppColors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                      const Divider(height: 24, thickness: 1),
                      if (invalidRfids.isNotEmpty ||
                          mismatchedRfids.isNotEmpty ||
                          excessRfids.isNotEmpty ||
                          alreadyLentRfids.isNotEmpty) ...[
                        const Text(
                          "Lỗi & Cảnh báo:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildErrorExpansionTile(
                          title: 'Quét dư',
                          totalCount: excessRfids.length ~/ 2,
                          detailsMap: excessDetails,
                          icon: Icons.layers_outlined,
                          color: Colors.orange,
                        ),
                        _buildErrorExpansionTile(
                          title: 'Không có trong phiếu',
                          totalCount: mismatchedRfids.length ~/ 2,
                          detailsMap: mismatchedDetails,
                          icon: Icons.not_listed_location_outlined,
                          color: Colors.redAccent,
                        ),
                        _buildErrorExpansionTile(
                          title: 'Phom đã được mượn',
                          totalCount: alreadyLentRfids.length ~/ 2,
                          detailsMap: alreadyLentDetails,
                          icon: Icons.block,
                          color: Colors.brown,
                        ),
                        if (invalidRfids.isNotEmpty)
                          ExpansionTile(
                            leading: const Icon(
                              Icons.signal_wifi_off_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                            title: Row(
                              children: [
                                const Expanded(
                                  flex: 3,
                                  child: Text(
                                    'RFID không có dữ liệu',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Chip(
                                  label: Text(
                                    '${invalidRfids.length} chiếc',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                  backgroundColor: Colors.grey.withOpacity(0.8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 0,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ],
                            ),
                            children:
                                invalidRfids.map((rfid) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16.0,
                                      right: 12,
                                      top: 3,
                                      bottom: 3,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        rfid,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 12,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              // Footer Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      try {
                        if (Get.context != null) {
                          Navigator.of(Get.context!).pop();
                        }
                      } catch (e) {
                        print('Error closing dialog: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Đóng",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
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
        lastScanStatus.value = 'Không có dữ liệu: RFID $epc';
        if (!invalidRfids.contains(epc)) invalidRfids.add(epc);
        return;
      }

      final item = response.data['data'][0];
      String lastMatNo = item['LastMatNo']?.toString() ?? 'N/A';
      String lastNo = item['LastNo']?.toString().trim() ?? 'N/A';
      String lastSize = item['LastSize']?.toString().trim() ?? 'N/A';
      String rawSide = item['LastSide']?.toString().trim() ?? 'Unknown';
      String lastSide;
      final sideLower = rawSide.toLowerCase();
      if (sideLower.startsWith('l')) {
        lastSide = 'left';
      } else if (sideLower.startsWith('r') || sideLower.startsWith('p')) {
        // "p" để hỗ trợ "phai" hoặc các ký hiệu viết tắt
        lastSide = 'right';
      } else {
        lastSide = 'unknown';
      }
      String key = "${lastMatNo}_$lastSize";

      // ***** KIỂM TRA TRƯỜNG HỢP PHOM ĐÃ ĐƯỢC MƯỢN *****
      // isOut có thể là boolean (true/false) hoặc string ('1'/'0')
      if (item['isOut'] == true ||
          item['isOut']?.toString() == '1' ||
          item['isOut']?.toString().toLowerCase() == 'true') {
        lastScanStatus.value = 'Đã mượn: $lastNo - Size $lastSize';
        if (!alreadyLentRfids.any((m) => m['rfid'] == epc)) {
          alreadyLentRfids.add({
            'rfid': epc,
            'matNo': lastNo,
            'size': lastSize,
          });
        }
        return; // Dừng xử lý ngay lập tức
      }

      if (!inventoryDataMap.containsKey(key)) {
        lastScanStatus.value = 'Sai phom: $lastNo - Size $lastSize';
        if (!mismatchedRfids.any((m) => m['rfid'] == epc)) {
          mismatchedRfids.add({'rfid': epc, 'matNo': lastNo, 'size': lastSize});
        }
        return;
      }

      var entry = inventoryDataMap[key]!;
      double expected = entry['expectedCount'];

      // Pairs trước khi cập nhật
      final prevPairs = (entry['leftCount'] < entry['rightCount']
              ? entry['leftCount']
              : entry['rightCount'])
          .toDouble();

      // Dừng nếu đã đủ số đôi
      if (prevPairs >= expected) {
        lastScanStatus.value = 'Quét thừa: $lastNo - Size $lastSize';
        if (!excessRfids.any((e) => e['rfid'] == epc)) {
          excessRfids.add({'rfid': epc, 'matNo': lastNo, 'size': lastSize});
        }
        return;
      }

      // Track Left/Right count
      if (lastSide == 'left') {
        entry['leftCount'] = (entry['leftCount'] ?? 0) + 1;
      } else if (lastSide == 'right') {
        entry['rightCount'] = (entry['rightCount'] ?? 0) + 1;
      }

      // Lưu lastNo để hiển thị (chỉ lưu lần đầu)
      if (entry['displayMatNo'] == null || entry['displayMatNo'].isEmpty) {
        entry['displayMatNo'] = lastNo;
      }

      // Tính lại số đôi hợp lệ dựa trên min(left, right)
      final newPairs = (entry['leftCount'] < entry['rightCount']
              ? entry['leftCount']
              : entry['rightCount'])
          .toDouble();
      final deltaPairs = newPairs - prevPairs;
      entry['scannedCount'] = newPairs;
      totalScannedCount.value += deltaPairs;

      List<String> rowData = entry['rowData'];
      rowData[3] = entry['leftCount'].toString();  // Left count
      rowData[4] = entry['rightCount'].toString();  // Right count
      int difference = (entry['leftCount'] - entry['rightCount']).abs();
      rowData[5] = difference.toString();  // Difference
      rowData[6] = newPairs.toString();  // Scanned pairs (min of left/right)
      inventoryData.refresh();

      scannedRfidDetailsList.add({
        "StateScan": 0,
        "ID_BILL": entry['idBill'],
        "DepID": entry['depId'],
        "ScanDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "RFID": epc,
        "UserID": user!.userId!,
        "DateBorrow": convertDate(dateController.text),
      });
      lastScanStatus.value = 'Hợp lệ: $lastNo - Size $lastSize';
    } catch (e) {
      lastScanStatus.value = 'Lỗi xử lý RFID $epc';
    }
  }

  Future<void> onFinish() async {
    // Không cho hoàn tất khi đang quét
    if (isScanning.value) {
      _showFeedback('Cảnh báo', 'Vui lòng dừng quét trước khi hoàn tất.');
      return;
    }

    // Kiểm tra số thẻ người nhận trước
    if (receiverCardNumberController.text.trim().isEmpty) {
      _showFeedback('Cảnh báo', 'Vui lòng nhập số thẻ người nhận trước khi hoàn tất.');

      return;
    }

    // Chỉ hiển thị dialog cảnh báo nếu CÓ lỗi
    if (invalidRfids.isNotEmpty ||
        mismatchedRfids.isNotEmpty ||
        excessRfids.isNotEmpty ||
        alreadyLentRfids.isNotEmpty) {
      Get.defaultDialog(
        title: "Cảnh báo",
        middleText:
            "Phiên quét có chứa các RFID không hợp lệ (sai phom, đã mượn, quét thừa...). Bạn có chắc muốn hoàn tất và chỉ lưu các phom hợp lệ không?",
        textConfirm: "Vẫn hoàn tất",
        textCancel: "Hủy",
        onConfirm: () {
          try {
            if (Get.context != null) {
              Navigator.of(Get.context!).pop();
            }
          } catch (e) {
            print('Error closing dialog: $e');
          }
          _proceedToFinish();
        },
      );
    } else {
      // Không có lỗi, submit trực tiếp
      _proceedToFinish();
    }
  }

  Future<void> _proceedToFinish() async {
    if (scannedRfidDetailsList.isEmpty) {
      _showFeedback('Thông báo', 'Chưa có phom hợp lệ nào được quét.');
      return;
    }

    isLoading.value = true;
    final payload = {
      "companyName": companyName,
      "ToTalPhomNotBinding": totalPhomNotBindingController.text,
      "ReceiverCardNumber": receiverCardNumberController.text.trim(),
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
          onConfirm: () async {
            try {
              if (Get.context != null) {
                Navigator.of(Get.context!).pop();
              }
            } catch (e) {
              print('Error closing dialog: $e');
            }
            await onClear();
          },
        );
      } else {
        throw Exception("Lưu thất bại. Mã lỗi: ${response.statusCode}");
      }
    } catch (e) {
      _showFeedback('Lỗi hệ thống', 'Không thể gửi dữ liệu. ${e.toString()}');
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
      _showFeedback('Lỗi khởi tạo', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    try {
      // Đóng dialog/snackbar nếu đang mở
      while (Get.isDialogOpen == true) {
        Get.back();
      }
    } catch (e) {
      print('Error closing dialogs: $e');
    }

    try {
      // Dừng quét RFID nếu đang quét
      if (isScanning.value) {
        RFIDService.stopScan();
      }
    } catch (e) {
      print('Error stopping RFID scan: $e');
    }

    // Dispose TextEditingControllers
    bill_br_id.dispose();
    totalPhomNotBindingController.dispose();
    receiverCardNumberController.dispose();
    dateController.dispose();

    super.onClose();
  }
}
