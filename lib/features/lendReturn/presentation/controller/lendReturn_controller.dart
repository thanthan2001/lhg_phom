import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/configs/app_colors.dart'; // Import màu sắc nếu cần
import 'package:lhg_phom/core/services/dio.api.service.dart';
import 'package:lhg_phom/core/services/models/user/domain/usecase/get_user_use_case.dart';
import 'package:lhg_phom/core/services/models/user/model/user_model.dart';
import 'package:lhg_phom/core/services/rfid_service.dart';
import 'package:lhg_phom/core/ui/widgets/text/text_widget.dart'; // Import TextWidget

class LendReturnController extends GetxController {
  final GetuserUseCase _getuserUseCase;
  LendReturnController(this._getuserUseCase);

  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  UserModel? user;
  late String? companyName;

  final bill_br_id = TextEditingController();
  final userNameController = TextEditingController();
  final totalPhomNotBindingController = TextEditingController();

  final isLoading = false.obs;
  final isScanning = false.obs;
  var isAvalableScan = false.obs;

  final searchResult = <Map<String, dynamic>>[].obs;
  final returnBillData = <Map<String, dynamic>>[].obs;
  final LastDataBill = <Map<String, dynamic>>[].obs;

  final Set<String> _seenTags = <String>{};
  final listFinalRFID = <String>[].obs;

  final invalidTags = <String>[].obs;

  var ScannedCount = 0.0.obs;

  @override
  void onInit() async {
    super.onInit();
    isLoading.value = true;

    user = await _getuserUseCase.getUser();
    if (user == null ||
        user!.companyName == null ||
        user!.companyName!.isEmpty) {
      Get.snackbar('Lỗi', 'Không tìm thấy thông tin người dùng hoặc công ty.');
      isLoading.value = false;
      return;
    }
    companyName = user!.companyName;
    userNameController.text = user!.userName ?? '';

    RFIDService.setOnHardwareScan(() {
      if (isScanning.value) {
        stopContinuousScan();
      } else {
        startContinuousScan();
      }
    });

    isLoading.value = false;
  }

  @override
  void onClose() {
    RFIDService.stopScan();
    bill_br_id.dispose();
    userNameController.dispose();
    super.onClose();
  }

  Future<void> onSearch() async {
    if (bill_br_id.text.trim().isEmpty) {
      Get.snackbar("Thông báo", "Vui lòng nhập Mã số đơn mượn.");
      return;
    }

    isLoading.value = true;
    FocusManager.instance.primaryFocus?.unfocus();
    _resetSearchState(); // Reset trạng thái trước khi tìm kiếm mới

    final data = {"companyName": companyName, "ID_BILL": bill_br_id.text};

    try {
      final response = await ApiService(baseUrl).post('/phom/getOldBill', data);

      if (response.data["statusCode"] == 200) {
        final resultsFromApi =
            response.data?["data"]["results"] as List<dynamic>?;
        final returnBillFromApi =
            response.data?["data"]["getReturnBill"] as List<dynamic>?;
        final lastBillResult =
            response.data?["data"]["lastdatabill"] as List<dynamic>?;

        if (lastBillResult != null)
          LastDataBill.assignAll(lastBillResult.cast<Map<String, dynamic>>());
        if (returnBillFromApi != null)
          returnBillData.assignAll(
            returnBillFromApi.cast<Map<String, dynamic>>(),
          );

        if (resultsFromApi != null && resultsFromApi.isNotEmpty) {
          searchResult.assignAll(resultsFromApi.cast<Map<String, dynamic>>());
          isAvalableScan.value = true;
          Get.snackbar(
            "Thành công",
            "Đã tìm thấy phiếu mượn.",
            backgroundColor: Colors.green.withOpacity(0.7),
          );
        } else {
          isAvalableScan.value = false;
          Get.snackbar("Thông báo", "Không tìm thấy phiếu mượn phù hợp.");
        }
      } else {
        _handleApiError(response.data, "tìm kiếm");
      }
    } catch (e) {
      _handleException(e, "tìm kiếm");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startContinuousScan() async {
    if (!isAvalableScan.value) {
      Get.snackbar('Cảnh báo', 'Vui lòng thực hiện tìm kiếm trước khi quét.');
      return;
    }
    if (isScanning.value) return;

    invalidTags.clear();
    onClearScanned();

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

      if (invalidTags.isNotEmpty) {
        showInvalidTagsDialog();
      }
    }
  }

  Future<void> sendEPCToServer(String epc) async {
    if (_seenTags.contains(epc)) {
      return;
    }
    _seenTags.add(epc);

    final data = {
      "companyName": companyName,
      "RFID": epc,
      "ID_BILL": bill_br_id.text,
    };

    try {
      final response = await ApiService(
        baseUrl,
      ).post('/phom/checkRFIDinBrBill', data);

      if (response.data["statusCode"] == 200) {
        listFinalRFID.add(epc);
        ScannedCount.value += 0.5;
      } else {
        invalidTags.add(epc);
      }
    } catch (e) {
      _seenTags.remove(epc);
      _handleException(e, "kiểm tra thẻ $epc");
    }
  }

  Future<void> onFinish() async {
    if (listFinalRFID.isEmpty) {
      Get.snackbar("Thông báo", "Chưa có phom nào được quét.");
      return;
    }
    isLoading.value = true;

    final payloadDetails =
        listFinalRFID
            .map((rfid) => {"companyName": companyName, "RFID": rfid})
            .toList();

    if (LastDataBill.isNotEmpty && searchResult.isNotEmpty) {
      LastDataBill[0]['TotalScanOut'] = searchResult[0]['TotalScanOut'];
    }

    final updatedLastDataBillList =
        LastDataBill.map((item) {
          return {...item, "payloadDetails": payloadDetails};
        }).toList();

    updatedLastDataBillList[0]['TotalPhomNotBinding'] =
        totalPhomNotBindingController.text;

    try {} catch (e) {
      _handleException(e, "hoàn tất trả phom");
    } finally {
      isLoading.value = false;
    }
  }

  void onClearScanned() {
    listFinalRFID.clear();

    _seenTags.clear();
    invalidTags.clear(); // Cũng xóa danh sách tag lỗi
    ScannedCount.value = 0;
  }

  Future<void> onClearPage() async {
    await stopContinuousScan();
    bill_br_id.clear();
    _resetSearchState();
  }

  Future<void> _connectRFID() async {
    try {
      final connected = await RFIDService.connect();
      if (connected) {
      } else {
        Get.snackbar(
          'Lỗi',
          'Kết nối RFID thất bại',
          backgroundColor: Colors.red.withOpacity(0.8),
        );
      }
    } catch (e) {
      _handleException(e, "kết nối RFID");
    }
  }

  void _resetSearchState() {
    searchResult.clear();
    returnBillData.clear();
    LastDataBill.clear();
    listFinalRFID.clear();
    _seenTags.clear();
    invalidTags.clear(); // Xóa danh sách tag lỗi khi reset
    ScannedCount.value = 0;
    isAvalableScan.value = false;
  }

  void showInvalidTagsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text("Thẻ không hợp lệ"),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextWidget(text: "Các thẻ sau không thuộc phiếu mượn này:"),
              const SizedBox(height: 10),

              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: Get.height * 0.4, // Giới hạn chiều cao
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: invalidTags.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: TextWidget(
                        text: '- ${invalidTags[index]}',
                        color: AppColors.black,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Đã hiểu"),
            onPressed: () {
              Get.back(); // Đóng dialog
            },
          ),
        ],
      ),

      barrierDismissible: false,
    );
  }

  void _handleApiError(dynamic responseData, String action) {
    final message = responseData["message"] ?? "Lỗi không xác định";

    Get.snackbar(
      "Lỗi",
      "Lỗi khi $action: $message",
      backgroundColor: Colors.red,
    );
  }

  void _handleException(dynamic e, String action) {
    Get.snackbar(
      "Lỗi",
      "Đã xảy ra sự cố khi $action.",
      backgroundColor: Colors.red,
    );
  }
}
