import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import '../../../../core/configs/app_colors.dart';
import '../../../../core/services/dio.api.service.dart';
import '../../../../core/services/models/phom_model.dart';
import '../../../../core/services/models/user/domain/usecase/get_user_use_case.dart';
import '../../../../core/services/models/user/model/user_model.dart';
import '../../../../core/services/rfid_service.dart';
import '../../../../core/utils/date_time.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class UpdateBindingController extends GetxController {
  final shelfList = ['K1', 'K2', 'K3'];
  final selectedShelf = ''.obs;
  final currentDate = DatetimeUtil.currentDate();
  final rfidController = TextEditingController();

  var ID_Return = ''.obs;
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  final isLoading = false.obs;
  final isSearching = false.obs;
  final GetuserUseCase _getuserUseCase;
  UpdateBindingController(this._getuserUseCase);
  late String? companyName;
  final isScanning = false.obs;
  var totalCount = 0.obs;
  var isScan = false.obs;

  UserModel? user;
  final selectedCodePhom = ''.obs;
  final phomName = ''.obs;
  final selectedSize = ''.obs;
  final RxList<String> codePhomList = <String>[].obs;
  final RxList<String> sizeList = <String>[].obs;
  final isLeftSide = true.obs;
  var listTagRFID = [];
  final RxList<Map<String, dynamic>> searchResults =
      <Map<String, dynamic>>[].obs;
  final phomBindingList = <PhomBindingItem>[].obs;
  void onSelectLeft() => isLeftSide.value = true;
  void onSelectRight() => isLeftSide.value = false;
  Future<void> onClear() async {
    isScanning.value = false;
    isScan.value = false;
    isLoading.value = true;
    selectedCodePhom.value = '';
    // phomName.value = '';
    totalCount.value = 0;
    selectedSize.value = '';
    // codePhomList.clear();
    // sizeList.clear();
    searchResults.clear();
    listTagRFID.clear();
    phomBindingList.clear();
    isLoading.value = false;
  }

  Future<void> onSearch() async {
    print('Selected Code Phom: ${selectedCodePhom.value}');
    final data = {
      "companyName": companyName,
      "MaVatTu": selectedCodePhom.value,
      "SizePhom": selectedSize.value,
      "TenPhom": phomName.value,
    };

    isSearching.value = true;
    searchResults.clear();

    try {
      final response = await ApiService(
        baseUrl,
      ).post('/phom/searchPhomBinding', data);
      print('Raw API Response Data: ${response.data}');

      final dynamic dataField = response.data["data"];
      if (dataField != null &&
          dataField is Map &&
          dataField.containsKey("jsonArray")) {
        final List<dynamic>? jsonArray = dataField["jsonArray"];

        if (jsonArray != null && jsonArray.isNotEmpty) {
          isScan.value = true;
          print('Data for table: $jsonArray');

          searchResults.value =
              jsonArray.map((item) {
                final Map<String, dynamic> mapItem = Map<String, dynamic>.from(
                  item,
                );
                mapItem['Scanning'] = 0;
                return mapItem;
              }).toList();
        } else {
          Get.snackbar('Thông báo', 'Không tìm thấy kết quả phù hợp.');
        }
      } else {
        print(
          'Error: "data" or "jsonArray" field is missing or not in expected format.',
        );
        Get.snackbar('Lỗi dữ liệu', 'Dữ liệu trả về không đúng định dạng.');
      }
    } catch (e) {
      print('Error during onSearch: $e');
      Get.snackbar('Lỗi', 'Không thể thực hiện tìm kiếm: ${e.toString()}');
    } finally {
      isSearching.value = false;
    }
  }

  /// Dừng quá trình quét liên tục
  Future<void> onStopRead() async {
    try {
      await RFIDService.stopScan();
      isScanning.value = false;
      isLoading.value = false;
      print('⏹️ Dừng quét RFID');
    } catch (e) {
      print('❌ Lỗi dừng quét: $e');
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi khi dừng quét: $e');
    }
  }

  void checkAndAddNewTags(List<String> newTags) {
    final uniqueTags =
        newTags.where((tag) => !listTagRFID.contains(tag)).toList();

    if (uniqueTags.isNotEmpty) {
      listTagRFID.addAll(uniqueTags);
      print('✅ Thêm tag mới: $uniqueTags');
    } else {
      print('⚠️ Tất cả tag đã tồn tại, không thêm mới');
    }
  }

  Future<void> onStartRead() async {
    if (isScanning.value) {
      print('ℹ️ Đã có một phiên quét đang chạy.');
      return;
    }
    if (!isScan.value) {
      Get.snackbar(
        '⚠️Thông báo',
        'Thực hiện tìm kiếm trước khi scan',
        backgroundColor: AppColors.primary2,
      );
      return;
    }

    isLoading.value = true;
    print('▶️ Đang chuẩn bị quét liên tục...');

    try {
      final user = await _getuserUseCase.getUser();
      if (user == null) {
        Get.snackbar('Lỗi', 'Không thể lấy thông tin người dùng.');
        isLoading.value = false;
        return;
      }

      listTagRFID.clear();
      phomBindingList.clear();
      rfidController.clear();
      totalCount.value = 0;
      update();

      isScanning.value = true;
      print('▶️ Đã bắt đầu quét liên tục...');

      await RFIDService.scanContinuous((epc) {
        if (!isScanning.value) return;

        if (!listTagRFID.contains(epc)) {
          listTagRFID.add(epc);

          final item = PhomBindingItem(
            rfid: epc,
            lastMatNo: selectedCodePhom.value.trim(),
            lastName: phomName.value.trim(),

            lastType:
                searchResults.isNotEmpty ? searchResults[0]["LastType"] : "",
            material:
                searchResults.isNotEmpty ? searchResults[0]["Material"] : "",
            lastSize:
                searchResults.isNotEmpty ? searchResults[0]["LastSize"] : "",
            lastSide: isLeftSide.value ? "Left" : "Right",
            dateIn: currentDate,
            userID: user.userId ?? "",
            shelfName: selectedShelf.value.trim(),
            companyName: user.companyName ?? "",
          );

          phomBindingList.add(item);

          totalCount.value = listTagRFID.length;

          print('✅ Tag mới: $epc | Tổng số tag: ${totalCount.value}');
        }
      });
    } catch (e) {
      print('❌ Lỗi khi bắt đầu quét: $e');
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi khi bắt đầu quét: $e');
    } finally {
      if (isScanning.value == false) {
        isLoading.value = false;
      }
    }
  }

  Future<void> getLastMatNo() async {
    isLoading.value = true;
    final data = {"companyName": companyName};
    try {
      final response = await ApiService(
        baseUrl,
      ).post('/phom/getPhomNotBinding', data);
      print('Response getLastMatNo: ${response.data["data"]["jsonArray"]}');

      final List<dynamic> jsonArray = response.data["data"]["jsonArray"];
      final List<String> newCodes =
          jsonArray
              .map<String>((item) => item["LastMatNo"].toString().trim())
              .toList();
      codePhomList.assignAll(
        newCodes.toSet().toList(),
      ); // Use assignAll and ensure uniqueness
    } catch (e) {
      print('Error getLastMatNo: $e');
      Get.snackbar('Lỗi', 'Không thể lấy thông tin mã phom.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getInforbyLastMatNo(String lastMatNo) async {
    selectedCodePhom.value = lastMatNo;
    phomName.value = '';
    sizeList.clear();
    selectedSize.value = '';

    isLoading.value = true;
    final data = {"companyName": companyName, "LastMatNo": lastMatNo};
    try {
      // Get Sizes
      final responseSize = await ApiService(
        baseUrl,
      ).post('/phom/getSizeNotBinding', data);
      final List<dynamic> jsonArraySize =
          responseSize.data["data"]["jsonArray"];
      print('Response getSizeNotBinding: ${jsonArraySize}');
      final List<String> newSizes =
          jsonArraySize
              .map<String>((item) => item["LastSize"].toString().trim())
              .toList();

      sizeList.assignAll(
        newSizes.toSet().toList(),
      ); // Use assignAll and ensure uniqueness
      if (newSizes.isNotEmpty) {
        selectedSize.value = newSizes.first;
      }

      // Get Phom Name
      final responseName = await ApiService(
        baseUrl,
      ).post('/phom/getPhomByLastMatNo', data);
      final List<dynamic> jsonArrayName =
          responseName.data["data"]["jsonArray"];
      if (jsonArrayName.isNotEmpty) {
        final String phomNameValue =
            jsonArrayName[0]["LastName"]?.toString().trim() ?? '';
        phomName.value = phomNameValue;
      }
    } catch (e) {
      print('Error getInforbyLastMatNo: $e');
      Get.snackbar('Lỗi', 'Không thể lấy thông tin chi tiết mã phom.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> isVerify() async {
    if (listTagRFID.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng quét thẻ RFID trước.');
      return false;
    }
    if (selectedCodePhom.value.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng chọn mã phom.');
      return false;
    }
    if (selectedSize.value.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng chọn kích thước phom.');
      return false;
    }
    if (phomName.value.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng chọn tên phom.');
      return false;
    }
    if (selectedShelf.value.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng chọn kệ.');
      return false;
    }
    return true;
  }

  Future<void> onFinish() async {
    if (!await isVerify()) {
      return;
    }

    isLoading.value = true; // Bật loading

    try {
      // Chuẩn bị dữ liệu để gửi đi, cấu trúc này đã đúng
      final data = {
        "companyName": companyName,
        "details": phomBindingList.map((item) => item.toJson()).toList(),
      };

      print("🚀 Dữ liệu gửi đi: ${jsonEncode(data)}");

      final response = await ApiService(baseUrl).post('/phom/updatephom', data);

      print("📦 Dữ liệu nhận về: ${response.data}");

      // Xử lý response mới từ backend
      if (response.data['statusCode'] == 200) {
        final responseData = response.data['data'];
        final int successCount = responseData['totalSuccess'] ?? 0;
        final int failureCount = responseData['totalFailure'] ?? 0;
        final List failures = responseData['failures'] ?? [];

        // Hiển thị thông báo tổng hợp
        if (failureCount == 0) {
          // Tất cả đều thành công
          Get.snackbar(
            '✅ Thành Công',
            'Đã cập nhật thành công tất cả $successCount thẻ.',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          // Có thể xóa list hoặc reset màn hình ở đây nếu muốn
          // onClear();
        } else {
          // Có cả thành công và thất bại
          Get.snackbar(
            '⚠️ Cảnh Báo',
            'Hoàn tất: $successCount thành công, $failureCount thất bại.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 5), // Hiển thị lâu hơn để đọc
          );
          // In ra log các thẻ bị lỗi để debug
          print("❌ Danh sách RFID cập nhật thất bại:");
          for (var failure in failures) {
            print("  - RFID: ${failure['rfid']}, Lỗi: ${failure['error']}");
          }
        }
      } else {
        // Lỗi từ server (ví dụ 400, 500)
        final errorMessage =
            response.data['message'] ?? 'Lỗi không xác định từ server.';
        Get.snackbar(
          '❌ Lỗi Server',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("❌ Lỗi khi gửi dữ liệu: $e");
      Get.snackbar(
        "Lỗi Hệ Thống",
        "Không thể kết nối đến máy chủ: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false; // Tắt loading
    }
  }

  Future<void> _connectRFID() async {
    try {
      final connected = await RFIDService.connect();
      if (connected) {
        print('✅💕 Đã kết nối RFID thành công');
      } else {
        Get.snackbar('Lỗi', 'Không thể kết nối thiết bị RFID');
      }
    } catch (e) {
      print('❌ Lỗi kết nối RFID: $e');
      Get.snackbar('Lỗi', 'Kết nối RFID thất bại: $e');
    }
  }

  Future<void> _disconnectRFID() async {
    try {
      await RFIDService.disconnect();
      print('✅ Ngắt kết nối RFID');
    } catch (e) {
      print('❌ Lỗi ngắt kết nối: $e');
    }
  }

  @override
  void onInit() async {
    isLoading.value = true;
    user = await _getuserUseCase.getUser();
    if (user == null ||
        user!.companyName == null ||
        user!.companyName!.isEmpty) {
      print('❌ User hoặc CompanyName null/empty.');
      Get.snackbar('Lỗi', 'Không tìm thấy thông tin người dùng hoặc công ty.');
      isLoading.value = false;
      return;
    }

    companyName = user!.companyName;
    print('CompanyName: $companyName');
    await getLastMatNo(); // Ensure this completes before setting isLoading to false
    isLoading.value = false; // Set to false after initial data loading
    // _connectRFID();

    // ĐĂNG KÝ LẮNG NGHE SỰ KIỆN NÚT CỨNG
    RFIDService.setOnHardwareScan(() {
      print(
        '🔔 Nút cứng đã được bấm! Trạng thái quét hiện tại: ${isScanning.value}',
      );

      // KIỂM TRA TRẠNG THÁI VÀ GỌI HÀM TƯƠNG ỨNG
      if (isScanning.value) {
        onStopRead(); // Nếu đang quét, gọi hàm dừng
      } else {
        onStartRead(); // Nếu chưa quét, gọi hàm bắt đầu
      }
    });
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    rfidController.dispose();
    phomBindingList.clear();
    listTagRFID.clear();
    super.onClose();
    // _disconnectRFID();
  }
}
