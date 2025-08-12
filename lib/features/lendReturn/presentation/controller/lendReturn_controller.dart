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
    _resetSearchState();

    final data = {"companyName": companyName, "ID_BILL": bill_br_id.text};

    try {
      final response = await ApiService(
        baseUrl,
      ).post('/phom/getDetailsBillScanOut', data);

      if (response.data["statusCode"] == 200) {
        final dynamic rawResult = response.data["data"]["jsonArray"];
        print("KẾT QUẢ TÌM KIẾM: $rawResult");
        if (rawResult is List && rawResult.isNotEmpty) {
          final List<Map<String, dynamic>> processedResult = [];

          for (var item in rawResult) {
            if (item is Map<String, dynamic>) {
              final Map<String, dynamic> newItem = Map<String, dynamic>.from(
                item,
              );
              newItem['scannedCount'] = 0.0.obs;
              processedResult.add(newItem);
            }
          }

          if (processedResult.isNotEmpty) {
            searchResult.assignAll(processedResult);
            isAvalableScan.value = true;
            Get.snackbar(
              "Thành công",
              "Đã tìm thấy phiếu mượn.",
              backgroundColor: Colors.green.withOpacity(0.7),
            );
          } else {
            isAvalableScan.value = false;
            Get.snackbar("Thông báo", "Dữ liệu trả về không hợp lệ.");
          }
        } else {
          isAvalableScan.value = false;
          Get.snackbar("Thông báo", "Không tìm thấy phiếu mượn phù hợp.");
        }
      } else {
        _handleApiError(response.data, "tìm kiếm");
      }
    } catch (e, stackTrace) {
      print('LỖI KHI TÌM KIẾM: $e');
      print('STACK TRACE: $stackTrace');
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

    // *** THAY ĐỔI QUAN TRỌNG: RESET PHIÊN QUÉT TRƯỚC ĐÓ ***
    // Gọi onClearScanned() để xóa tất cả dữ liệu quét cũ và reset bộ đếm.
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
        final scannedDataList = response.data["data"]["jsonArray"];
        if (scannedDataList != null && scannedDataList.isNotEmpty) {
          final scannedItemData = scannedDataList[0];

          final String lastNo =
              scannedItemData['LastNo']?.toString().trim() ?? '';
          final String lastSize =
              scannedItemData['LastSize']?.toString().trim() ?? '';

          var foundItem = searchResult.firstWhere(
            (item) =>
                item['LastNo']?.toString().trim() == lastNo &&
                item['LastSize']?.toString().trim() == lastSize,
            orElse: () => <String, dynamic>{},
          );

          if (foundItem.isNotEmpty) {
            foundItem['scannedCount'].value += 0.5;
            listFinalRFID.add(epc);
          } else {
            invalidTags.add(epc);
          }
        } else {
          invalidTags.add(epc);
        }
      } else {
        invalidTags.add(epc);
      }
    } catch (e) {
      _seenTags.remove(epc);
      _handleException(e, "kiểm tra thẻ $epc");
    }
  }

  // Future<void> onFinish() async {
  //   if (listFinalRFID.isEmpty) {
  //     Get.snackbar("Thông báo", "Chưa có phom nào được quét.");
  //     return;
  //   }
  //   isLoading.value = true;

  //   final payloadDetails =
  //       listFinalRFID
  //           .map((rfid) => {"companyName": companyName, "RFID": rfid})
  //           .toList();

  //   if (LastDataBill.isNotEmpty && searchResult.isNotEmpty) {
  //     LastDataBill[0]['TotalScanOut'] = searchResult[0]['TotalScanOut'];
  //   }

  //   final updatedLastDataBillList =
  //       LastDataBill.map((item) {
  //         return {...item, "payloadDetails": payloadDetails};
  //       }).toList();

  //   updatedLastDataBillList[0]['TotalPhomNotBinding'] =
  //       totalPhomNotBindingController.text;

  //   try {
  //     // Logic gửi dữ liệu lên server ở đây
  //   } catch (e) {
  //     _handleException(e, "hoàn tất trả phom");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> onFinish() async {
    if (listFinalRFID.isEmpty) {
      Get.snackbar("Thông báo", "Chưa có phom nào được quét.");
      return;
    }
    isLoading.value = true;

    try {
      // 1. Chuẩn bị các thành phần của payload

      // a. Tính tổng số lượng đã phát (TotalScanOut) từ searchResult
      // Cột 'SoLuong' trong searchResult là số lượng đã phát
      double totalScanOut = 0;
      for (var item in searchResult) {
        totalScanOut += (item['SoLuong'] as num?) ?? 0;
      }

      // b. Tạo danh sách chi tiết các RFID đã quét (chỉ cần RFID)
      final List<Map<String, String>> payloadDetails =
          listFinalRFID.map((rfid) => {"RFID": rfid}).toList();

      // 2. Xây dựng đối tượng payload chính theo cấu trúc backend yêu cầu
      final Map<String, dynamic> payload = {
        "companyName": companyName,
        "data": [
          {
            "ID_bill": bill_br_id.text,
            "Userid": user?.userId ?? '',
            "TotalScanOut": totalScanOut,
            "DepID":
                searchResult.isNotEmpty
                    ? searchResult[0]['DepID']?.toString().trim() ?? ''
                    : '',
            "payloadDetails": payloadDetails,
          },
        ],
      };

      print("DỮ LIỆU GỬI ĐI (KHỚP VỚI BACKEND): ${payload}");

      // 3. Gọi API với endpoint và payload đã được định dạng đúng
      final response = await ApiService(
        baseUrl,
      ).post('/phom/submitReturnPhom', payload); // Sửa endpoint nếu cần

      if (response.data["statusCode"] == 200) {
        Get.snackbar(
          "Thành công",
          response.data["message"] ?? "Đã hoàn tất trả phom.",
          backgroundColor: Colors.green,
        );
        // Reset lại trang sau khi thành công
        _resetSearchState();
        bill_br_id.clear();
        totalPhomNotBindingController.clear();
      } else {
        _handleApiError(response.data, "hoàn tất trả phom");
      }
    } catch (e, stackTrace) {
      print("LỖI KHI HOÀN TẤT: $e");
      print("STACK TRACE: $stackTrace");
      _handleException(e, "hoàn tất trả phom");
    } finally {
      isLoading.value = false;
    }
  }

  void onClearScanned() {
    listFinalRFID.clear();
    _seenTags.clear();
    invalidTags.clear();

    // Reset lại tất cả các bộ đếm của từng dòng về 0
    for (var item in searchResult) {
      if (item.containsKey('scannedCount')) {
        item['scannedCount'].value = 0.0;
      }
    }
  }

  void _resetSearchState() {
    searchResult.clear();
    returnBillData.clear();
    LastDataBill.clear();
    listFinalRFID.clear();
    _seenTags.clear();
    invalidTags.clear();
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
              TextWidget(
                text:
                    'Các thẻ sau không thuộc phiếu mượn này: ${invalidTags.length}',
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: Get.height * 0.4),
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
              Get.back();
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
