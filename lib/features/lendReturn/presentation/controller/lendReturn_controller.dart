import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/configs/app_colors.dart';
import 'package:lhg_phom/core/services/dio.api.service.dart';
import 'package:lhg_phom/core/services/models/user/domain/usecase/get_user_use_case.dart';
import 'package:lhg_phom/core/services/models/user/model/user_model.dart';
import 'package:lhg_phom/core/services/rfid_service.dart';
import 'package:lhg_phom/core/ui/widgets/text/text_widget.dart';

class LendReturnController extends GetxController {
  final GetuserUseCase _getuserUseCase;
  LendReturnController(this._getuserUseCase);

  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  UserModel? user;
  late String? companyName;
  final isLoading = false.obs;
  final isScanning = false.obs;
  final userNameController = TextEditingController();
  final departmentList = <String>[].obs;
  final Map<String, String> depNameToIdMap = {};
  final selectedDepartment = ''.obs;
  RxString selectedDepartmentId = ''.obs;
  final Set<String> _seenTags = <String>{};
  final scannedItems = <Map<String, dynamic>>[].obs;
  final listFinalRFID = <String>[].obs;

  final returnedTags = <Map<String, String>>[].obs;
  final unborrowedTags = <Map<String, String>>[].obs;
  final canClear = false.obs;
  final isFinishing = false.obs;
  final List<Map<String, String>> _sessionValidTags = [];
  final List<Map<String, String>> _sessionReturnedTags = [];
  final List<Map<String, String>> _sessionUnborrowedTags = [];
  final totalScannedEPCs = 0.obs;
  @override
  void onInit() async {
    super.onInit();
    isLoading.value = true;
    await _initializeUserAndData();
    _setupHardwareScanListener();
    everAll([scannedItems, returnedTags, unborrowedTags], (_) {
      canClear.value =
          scannedItems.isNotEmpty ||
          returnedTags.isNotEmpty ||
          unborrowedTags.isNotEmpty;
    });
    isLoading.value = false;
  }

  Future<void> _initializeUserAndData() async {
    user = await _getuserUseCase.getUser();
    if (user == null ||
        user!.companyName == null ||
        user!.companyName!.isEmpty) {
      Get.snackbar('Lỗi', 'Không tìm thấy thông tin người dùng hoặc công ty.');
      return;
    }
    companyName = user!.companyName;
    userNameController.text = user!.userName ?? '';
    await getDepartment();
  }

  void _setupHardwareScanListener() {
    RFIDService.setOnHardwareScan(() {
      if (isScanning.value) {
        stopContinuousScan();
      } else {
        startContinuousScan();
      }
    });
  }

  Future<void> getDepartment() async {
    if (companyName == null || companyName!.isEmpty) return;
    try {
      final data = {"companyName": companyName};
      var response = await ApiService(
        baseUrl,
      ).post('/phom/getDepartment', data);
      if (response.statusCode == 200) {
        final List<dynamic>? jsonArray = response.data?["data"]?["jsonArray"];
        if (jsonArray != null) {
          final List<String> departmentsNames = [];
          final Map<String, String> nameToId = {};
          for (var e in jsonArray) {
            departmentsNames.add(e['DepName'].toString());
            nameToId[e['DepName'].toString()] = e['ID'].toString();
          }
          departmentList.assignAll(departmentsNames);
          depNameToIdMap.assignAll(nameToId);
          if (departmentsNames.isNotEmpty) {
            selectedDepartment.value = departmentsNames.first;
            selectedDepartmentId.value =
                depNameToIdMap[departmentsNames.first] ?? '';
          }
        }
      }
    } catch (e) {
      _handleException(e, "lấy danh sách đơn vị");
    }
  }

  @override
  void onClose() {
    RFIDService.stopScan();
    userNameController.dispose();
    super.onClose();
  }

  Future<void> startContinuousScan() async {
    if (isScanning.value) return;
    _resetScanState();
    isScanning.value = true;
    try {
      await RFIDService.scanContinuous(sendEPCToServer);
    } catch (e) {
      isScanning.value = false;
      _handleException(e, "bắt đầu quét");
    }
  }

  Future<void> stopContinuousScan() async {
    if (!isScanning.value) return;
    try {
      await RFIDService.stopScan();
    } catch (e) {
      _handleException(e, "dừng quét");
    } finally {
      isScanning.value = false;
      _showScanSummaryDialog();
    }
  }

  Future<void> sendEPCToServer(String epc) async {
    if (_seenTags.contains(epc)) return;
    totalScannedEPCs.value++;
    _seenTags.add(epc);

    listFinalRFID.add(epc);

    final data = {
      "companyName": companyName,
      "RFID": epc,
      "DepID": selectedDepartmentId.value,
    };

    try {
      final response = await ApiService(
        baseUrl,
      ).post('/phom/checkRFIDinBrBill', data);
      final status = response.data['status'];
      final message = response.data['message'] ?? 'Lỗi không xác định';
      final responseData = response.data['data'] as List<dynamic>?;
      final String lastno =
          responseData != null && responseData.isNotEmpty
              ? responseData[0]['LastNo']?.toString().trim() ?? 'N/A'
              : 'N/A';
      final String lastsize =
          responseData != null && responseData.isNotEmpty
              ? responseData[0]['LastSize']?.toString().trim() ?? 'N/A'
              : 'N/A';
      final String shortcut =
          responseData != null && responseData.isNotEmpty
              ? responseData[0]['RFID_Shortcut']?.toString().trim() ?? epc
              : epc;
      var existingItem = scannedItems.firstWhere(
        (item) => item['LastNo'] == lastno && item['LastSize'] == lastsize,
        orElse: () => <String, dynamic>{},
      );

      if (existingItem.isNotEmpty) {
        existingItem['scannedCount'].value += 0.5;
      } else {
        scannedItems.add({
          'LastNo': lastno,
          'LastSize': lastsize,
          'scannedCount': 0.5.obs,
        });
      }
      if (status == 1) {
        _sessionValidTags.add({'lastNo': lastno, 'lastSize': lastsize});
      } else if (status == 0) {
        _sessionReturnedTags.add({
          'lastno': lastno,
          'lastsize': lastsize,
          'rfid_shortcut': shortcut,
          'message': message,
        });
      } else {
        _sessionUnborrowedTags.add({
          'lastno': lastno,
          'lastsize': lastsize,
          'rfid_shortcut': shortcut,
          'message': message,
        });
      }
    } catch (e) {
      final errorMessage = 'Lỗi kết nối server hoặc dữ liệu không hợp lệ';
      unborrowedTags.add({'rfid_shortcut': epc, 'message': errorMessage});
      _sessionUnborrowedTags.add({
        'lastno': 'N/A',
        'lastsize': 'N/A',
        'rfid_shortcut': epc,
        'message': errorMessage,
      });
      _handleException(e, "kiểm tra thẻ $epc");
    }
  }

  Future<void> onFinish() async {
    if (listFinalRFID.isEmpty) {
      Get.snackbar("Thông báo", "Chưa có phom hợp lệ nào được quét.");
      return;
    }
    isFinishing.value = true;
    final data = {
      "Userid": user?.userId ?? '',
      "companyName": companyName,
      "DepID": selectedDepartmentId.value,
      "RFID_LIST": listFinalRFID,
    };
    print("Sending data to server: $data");
    try {
      final response = await ApiService(
        baseUrl,
      ).post('/phom/submitReturnPhom', data);
      if (response.data["statusCode"] == 200) {
        Get.snackbar(
          backgroundColor: AppColors.green.withOpacity(0.6),
          "Thành công",
          response.data["message"] ?? "Quá trình trả phom thành công.",
        );
        _resetScanState();
      } else {
        Get.snackbar(
          "Lỗi",
          response.data["message"] ?? "Có lỗi xảy ra từ server.",
        );
      }
    } catch (e) {
      Get.snackbar("Thông báo", "Lỗi kết nối server.");
    } finally {
      isFinishing.value = false;
    }
  }

  void onClearScanned() {
    _resetScanState();
    Get.snackbar("Thông báo", "Đã xóa toàn bộ dữ liệu quét.");
  }

  void _resetScanState() {
    listFinalRFID.clear();
    _seenTags.clear();
    scannedItems.clear();
    returnedTags.clear();
    unborrowedTags.clear();
    _sessionValidTags.clear();
    _sessionReturnedTags.clear();
    _sessionUnborrowedTags.clear();
    totalScannedEPCs.value = 0;
  }
  void _showScanSummaryDialog() {
    if (_sessionValidTags.isEmpty &&
        _sessionReturnedTags.isEmpty &&
        _sessionUnborrowedTags.isEmpty) {
      Get.snackbar(
        "Thông báo",
        "Không có thẻ mới nào được quét.",
        duration: const Duration(seconds: 2),
      );
      return;
    }
    Get.dialog(
      AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: const Row(
          children: [
            Icon(Icons.checklist_rtl, color: AppColors.primary, size: 28),
            SizedBox(width: 10),
            Text("Kết quả phiên quét"),
          ],
        ),
        content: SizedBox(
          width: Get.width,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildValidExpansionTile(
                  "Hợp lệ:",
                  _sessionValidTags,
                  Colors.green,
                ),
                if (_sessionReturnedTags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildErrorExpansionTile(
                    "Đã trả:",
                    _sessionReturnedTags,
                    Colors.orange,
                  ),
                ],
                if (_sessionUnborrowedTags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildErrorExpansionTile(
                    "Chưa mượn / Lỗi:",
                    _sessionUnborrowedTags,
                    Colors.red,
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [TextButton(child: const Text("Đóng"), onPressed: Get.back)],
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildSummaryRow(String title, int count, Color color) {
    final double pairCount =
        count / 2.0; 
    final String displayText =
        (pairCount % 1 == 0)
            ? pairCount.toInt().toString()
            : pairCount.toString();
    final String finalCountText =
        title.contains("Hợp lệ") ? "$displayText đôi" : "$count thẻ";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextWidget(
              text: title,
              fontWeight: FontWeight.bold,
              size: 15,
            ),
          ),
          const SizedBox(width: 8),
          TextWidget(
            text: finalCountText,
            color: color,
            fontWeight: FontWeight.bold,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildValidExpansionTile(
    String title,
    List<Map<String, String>> tags,
    Color color,
  ) {
    final Map<String, Map<String, dynamic>> aggregatedMap = {};
    for (final tag in tags) {
      final String key = "${tag['lastNo']}-${tag['lastSize']}";
      if (aggregatedMap.containsKey(key)) {
        aggregatedMap[key]!['count'] += 0.5;
      } else {
        aggregatedMap[key] = {
          'lastNo': tag['lastNo'],
          'lastSize': tag['lastSize'],
          'count': 0.5,
        };
      }
    }
    final aggregatedList = aggregatedMap.values.toList();

    return Theme(
      data: Get.theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: tags.isNotEmpty,
        tilePadding: const EdgeInsets.all(0),
        title: _buildSummaryRow(title, tags.length, color),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Column(
              children: List.generate(aggregatedList.length, (index) {
                final item = aggregatedList[index];
                final double count = item['count'];
                final String displayText =
                    (count % 1 == 0)
                        ? count.toInt().toString()
                        : count.toString();
                return Container(
                  color:
                      index.isEven
                          ? AppColors.primary.withOpacity(0.04)
                          : Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextWidget(
                                text: "Mã Phom",
                                size: 12,
                                color: AppColors.grey,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: TextWidget(
                                text: "Size",
                                size: 12,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextWidget(
                                text: "${item['lastNo']}",
                                size: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: TextWidget(
                                text: "${item['lastSize']}",
                                size: 14,
                                color: AppColors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(
                        displayText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 0,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorExpansionTile(
    String title,
    List<Map<String, String>> tags,
    Color color,
  ) {
    return Theme(
      data: Get.theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: tags.isNotEmpty,
        tilePadding: const EdgeInsets.all(0),
        title: _buildSummaryRow(title, tags.length, color),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Column(
              children: List.generate(tags.length, (index) {
                final tag = tags[index];
                return Container(
                  color:
                      index.isEven
                          ? color.withOpacity(0.05)
                          : Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildErrorDetailColumn(
                            "Mã Phom",
                            "${tag['lastno']}",
                            flex: 3,
                          ),
                          _buildErrorDetailColumn(
                            "Size",
                            "${tag['lastsize']}",
                            flex: 2,
                          ),
                          _buildErrorDetailColumn(
                            "Mã RFID",
                            "${tag['rfid_shortcut']}",
                            flex: 3,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextWidget(
                              text: "Lý do: ${tag['message'] ?? ""}",
                              size: 13,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDetailColumn(String title, String data, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(text: title, size: 12, color: AppColors.grey),
          const SizedBox(height: 2),
          TextWidget(text: data, size: 14, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }

  void _handleException(dynamic e, String action) {
    print("Đã xảy ra sự cố khi $action. Lỗi: $e");
  }
}
