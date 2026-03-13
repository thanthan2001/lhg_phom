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
import 'package:lhg_phom/core/utils/app_snackbar.dart';

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
  final List<Map<String, String>> _sessionReturnedTags = [];
  final List<Map<String, String>> _sessionUnborrowedTags = [];
  final totalScannedEPCs = 0.obs;
  final totalPairs = 0.0.obs;

  // Safe feedback helper - uses print for async contexts
  void _showFeedback(String title, String message) {
    print('[$title] $message');
  }
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
      _showFeedback('Lỗi', 'Không tìm thấy thông tin người dùng hoặc công ty.');
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
    
    // Connect to RFID device first
    final connected = await RFIDService.connect();
    if (!connected) {
      _showFeedback('Lỗi', 'Không thể kết nối với thiết bị RFID');
      return;
    }
    
    _resetScanState();
    isScanning.value = true;
    try {
      // Clear native cache to start fresh
      await RFIDService.clearScannedTags();
      
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
      final Map<String, dynamic>? itemData =
          responseData != null && responseData.isNotEmpty
              ? responseData.first as Map<String, dynamic>?
              : null;

      final String lastno = itemData?['LastNo']?.toString().trim() ?? 'N/A';
      final String lastsize = itemData?['LastSize']?.toString().trim() ?? 'N/A';
      final String rawSide = itemData?['LastSide']?.toString().trim() ?? '';
      final String side = _normalizeSide(rawSide);
      final String shortcut =
          itemData?['RFID_Shortcut']?.toString().trim() ?? epc;
      final String key = "$lastno-$lastsize";

      if (status == 1) {
        if (side == 'NULL' || side == 'unknown') {
          _sessionUnborrowedTags.add({
            'lastno': lastno,
            'lastsize': lastsize,
            'rfid_shortcut': shortcut,
            'message': 'Không xác định bên phom',
          });
          unborrowedTags.add({
            'rfid_shortcut': shortcut,
            'message': 'Không xác định bên phom',
          });
        } else {
          // Chỉ thêm RFID hợp lệ vào danh sách cuối cùng
          listFinalRFID.add(epc);
          _updateScannedCounts(
            key: key,
            lastNo: lastno,
            lastSize: lastsize,
            side: side,
          );
        }
      } else if (status == 0) {
        _sessionReturnedTags.add({
          'lastno': lastno,
          'lastsize': lastsize,
          'rfid_shortcut': shortcut,
          'message': message,
        });
        returnedTags.add({
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
        unborrowedTags.add({
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

  String _normalizeSide(String rawSide) {
    final sideLower = rawSide.toLowerCase();
    if (sideLower.startsWith('l')) return 'left';
    if (sideLower.startsWith('r') || sideLower.startsWith('p')) return 'right';
    return 'unknown';
  }

  void _updateScannedCounts({
    required String key,
    required String lastNo,
    required String lastSize,
    required String side,
  }) {
    final index = scannedItems.indexWhere((item) => item['key'] == key);
    Map<String, dynamic> entry;
    if (index == -1) {
      entry = {
        'key': key,
        'LastNo': lastNo,
        'LastSize': lastSize,
        'leftCount': 0,
        'rightCount': 0,
        'pairs': 0.0,
        'difference': 0,
      };
      scannedItems.add(entry);
    } else {
      entry = Map<String, dynamic>.from(scannedItems[index]);
    }

    final prevPairs = (entry['pairs'] as double?) ?? 0.0;
    if (side == 'left') {
      entry['leftCount'] = (entry['leftCount'] as int) + 1;
    } else if (side == 'right') {
      entry['rightCount'] = (entry['rightCount'] as int) + 1;
    }

    final leftCount = entry['leftCount'] as int;
    final rightCount = entry['rightCount'] as int;
    final newPairs = (leftCount < rightCount ? leftCount : rightCount).toDouble();

    entry['pairs'] = newPairs;
    entry['difference'] = (leftCount - rightCount).abs();

    if (index == -1) {
      scannedItems[scannedItems.length - 1] = entry;
    } else {
      scannedItems[index] = entry;
    }

    totalPairs.value += newPairs - prevPairs;
    scannedItems.refresh();
  }

  Future<void> onFinish() async {
    // Không cho submit khi đang quét
    if (isScanning.value) {
      _showFeedback('Cảnh báo', 'Vui lòng dừng quét trước khi hoàn tất');
      return;
    }
    
    if (listFinalRFID.isEmpty) {
      _showFeedback('Thông báo', 'Chưa có phom hợp lệ nào được quét.');
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
        AppSnackbar.show(
          "Thành công",
          response.data["message"] ?? "Quá trình trả phom thành công.",
        );
        _resetScanState();
      } else {
        _showFeedback('Lỗi', response.data["message"] ?? "Có lỗi xảy ra từ server.");
      }
    } catch (e) {
      _showFeedback('Thông báo', 'Lỗi kết nối server.');
    } finally {
      isFinishing.value = false;
    }
  }

  void onClearScanned() {
    _resetScanState();
    _showFeedback('Thông báo', 'Đã xóa toàn bộ dữ liệu quét.');
  }

  void _resetScanState() {
    listFinalRFID.clear();
    _seenTags.clear();
    scannedItems.clear();
    returnedTags.clear();
    unborrowedTags.clear();
    _sessionReturnedTags.clear();
    _sessionUnborrowedTags.clear();
    totalScannedEPCs.value = 0;
    totalPairs.value = 0.0;
  }

  void _showScanSummaryDialog() {
    final hasValid = scannedItems.isNotEmpty;
    final hasErrors =
        _sessionReturnedTags.isNotEmpty || _sessionUnborrowedTags.isNotEmpty;

    if (!hasValid && !hasErrors) {
      _showFeedback('Thông báo', 'Không có thẻ mới nào được quét.');
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
                if (hasValid)
                  _buildValidExpansionTile(
                    "Hợp lệ:",
                    scannedItems.toList(),
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
        actions: [
          TextButton(
            child: const Text("Đóng"),
            onPressed: () {
              try {
                if (Get.context != null) {
                  Navigator.of(Get.context!).pop();
                }
              } catch (e) {
                print('Error closing dialog: $e');
              }
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildSummaryRow({
    required String title,
    required String displayText,
    required Color color,
  }) {
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
            text: displayText,
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
    List<Map<String, dynamic>> items,
    Color color,
  ) {
    final double totalPairCount = items.fold<double>(
      0.0,
      (sum, item) => sum + ((item['pairs'] as double?) ?? 0.0),
    );

    final String displayText =
        (totalPairCount % 1 == 0)
            ? "${totalPairCount.toInt()} đôi"
            : "$totalPairCount đôi";

    return Theme(
      data: Get.theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: items.isNotEmpty,
        tilePadding: const EdgeInsets.all(0),
        title: _buildSummaryRow(
          title: title,
          displayText: displayText,
          color: color,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Column(
              children: List.generate(items.length, (index) {
                final item = items[index];
                final leftCount = item['leftCount'] ?? 0;
                final rightCount = item['rightCount'] ?? 0;
                final difference = item['difference'] ?? 0;
                final pairs = (item['pairs'] as double?) ?? 0.0;
                final String pairText =
                    (pairs % 1 == 0) ? pairs.toInt().toString() : pairs.toString();

                return Container(
                  color:
                      index.isEven
                          ? AppColors.primary.withOpacity(0.04)
                          : Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextWidget(
                                text: item['LastNo']?.toString() ?? 'N/A',
                                size: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: TextWidget(
                                text: item['LastSize']?.toString() ?? 'N/A',
                                size: 14,
                                color: AppColors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _buildStatChip('Trái', leftCount.toString(), Colors.blueGrey),
                            _buildStatChip('Phải', rightCount.toString(), Colors.teal),
                            _buildStatChip('Chênh lệch', difference.toString(), Colors.deepOrange),
                            _buildStatChip('Đôi', pairText, AppColors.primary),
                          ],
                        ),
                      ],
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

  Widget _buildStatChip(String label, String value, Color color) {
    return Chip(
      label: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color.withOpacity(0.9),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
        title: _buildSummaryRow(
          title: title,
          displayText: "${tags.length} thẻ",
          color: color,
        ),
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
