import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

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
  var ID_Return = ''.obs;
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  final isLoading = false.obs;
  final isSearching = false.obs; // For search operation loading
  final GetuserUseCase _getuserUseCase;
  UpdateBindingController(this._getuserUseCase);
  late String? companyName;
  UserModel? user;
  final selectedCodePhom = ''.obs;
  final phomName = ''.obs;
  final selectedSize = ''.obs;
  final RxList<String> codePhomList = <String>[].obs;
  final RxList<String> sizeList = <String>[].obs;
  final isLeftSide = true.obs;
  var listTagRFID = [];
  // To store the search results for the table
  final RxList<Map<String, dynamic>> searchResults =
      <Map<String, dynamic>>[].obs;
  final phomBindingList = <PhomBindingItem>[].obs;
  void onSelectLeft() => isLeftSide.value = true;
  void onSelectRight() => isLeftSide.value = false;
  Future<void> onClear() async {
    isLoading.value = true;
    // selectedCodePhom.value = '';
    // phomName.value = '';
    // selectedSize.value = '';
    // codePhomList.clear();
    // sizeList.clear();
    // searchResults.clear();
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
    searchResults.clear(); // Clear previous results

    try {
      final response = await ApiService(
        baseUrl,
      ).post('/phom/searchPhomBinding', data);
      print(
        'Raw API Response Data: ${response.data}',
      ); // Log the entire response data

      // Safely access the jsonArray
      final dynamic dataField = response.data["data"];
      if (dataField != null &&
          dataField is Map &&
          dataField.containsKey("jsonArray")) {
        final List<dynamic>? jsonArray = dataField["jsonArray"];

        if (jsonArray != null && jsonArray.isNotEmpty) {
          print('Data for table: $jsonArray');
          // Add the "Scanning" column with a default value of 0
          searchResults.value =
              jsonArray.map((item) {
                final Map<String, dynamic> mapItem = Map<String, dynamic>.from(
                  item,
                );
                mapItem['Scanning'] = 0; // Add default scanning count
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

  //check exict tag in listTagRFID
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

  Future<void> onScanMultipleTags() async {
    isLoading.value = true;
    final user = await _getuserUseCase.getUser();
    print('user: ${user?.userId}');
    print('password: ${user?.password}');
    print('username: ${user?.userName}');
    try {
      final tags = await RFIDService.scanSingleTagMultiple(
        timeout: Duration(milliseconds: 100),
      );

      if (tags.isNotEmpty) {
        checkAndAddNewTags(tags);
        phomBindingList.clear(); // Đảm bảo không bị cộng dồn dữ liệu cũ
        for (var tag in listTagRFID) {
          final item = PhomBindingItem(
            rfid: tag,
            lastMatNo: selectedCodePhom.value.trim(),
            lastName: phomName.value.trim(),
            lastType: searchResults[0]["LastType"],
            material: searchResults[0]["Material"],
            lastSize: searchResults[0]["LastSize"],
            lastSide: isLeftSide.value ? "Left" : "Right",
            dateIn: currentDate,
            userID: user?.userId ?? "",
            shelfName: selectedShelf.value.trim(),
            companyName: user?.companyName ?? "",
          );
          phomBindingList.add(item);
        }
        print(
          "phomBindingList: ${jsonEncode(phomBindingList.map((e) => e.toJson()).toList())}",
        );
        print('📋 Tổng listTagRFID: $listTagRFID + ${listTagRFID.length}');
      } else {
        Get.snackbar('Lỗi', 'Không tìm thấy thẻ nào');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi: $e');
    } finally {
      isLoading.value = false;
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
    selectedCodePhom.value = lastMatNo; // Update selected code phom
    phomName.value = ''; // Reset phom name
    sizeList.clear(); // Clear previous sizes
    selectedSize.value = ''; // Reset selected size

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
    try {
      for (var item in phomBindingList) {
        var data = item.toJson(); // Chuyển đổi mỗi đối tượng thành map

        final response = await ApiService(baseUrl).post(
          '/phom/updatephom', // Giả sử backend có endpoint này để nhận một đối tượng
          data,
        );
        print(response.data);
        if (response.data['statusCode'] == 200) {
          print("✅ Gửi thành công: ${item.rfid}");
          Get.snackbar('✅ Gửi thành công', "${item.rfid}");
        } else {
          print("❌ Gửi thất bại cho RFID: ${item.rfid}");
          Get.snackbar(
            "Lỗi ${response.data['message']}",
            "Gửi thất bại cho RFID: ${item.rfid}",
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      print("❌ Lỗi khi gửi dữ liệu: $e");
      Get.snackbar(
        "Lỗi",
        "Đã xảy ra lỗi: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
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
    _connectRFID();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    _disconnectRFID();
  }
}
