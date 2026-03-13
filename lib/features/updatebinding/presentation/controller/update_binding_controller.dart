import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import '../../../../core/configs/enum.dart';
import '../../../../core/ui/dialogs/dialogs.dart';
import '../../../../core/services/dio.api.service.dart';
import '../../../../core/services/models/phom_model.dart';
import '../../../../core/services/models/user/domain/usecase/get_user_use_case.dart';
import '../../../../core/services/models/user/model/user_model.dart';
import '../../../../core/services/rfid_service.dart';
import '../../../../core/utils/date_time.dart';

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

  // Safe feedback helper - uses print for async contexts
  void _showFeedback(String title, String message) {
    print('[$title] $message');
  }

  var totalCount = 0.0.obs;
  var isScan = false.obs;

  UserModel? user;
  final selectedCodePhom = ''.obs;
  final phomName = ''.obs;
  final selectedSize = ''.obs;
  final RxList<String> codePhomList = <String>[].obs;
  final RxList<String> sizeList = <String>[].obs;
  final isLeftSide = true.obs;
  final listTagRFID =
      <String>{}.obs; // Use Set instead of List to prevent duplicates
  final RxList<Map<String, dynamic>> searchResults =
      <Map<String, dynamic>>[].obs;
  final phomBindingList = <PhomBindingItem>[].obs;
  void onSelectLeft() => isLeftSide.value = true;
  void onSelectRight() => isLeftSide.value = false;

  // Clear only scan data, keep search parameters
  Future<void> clearScanData() async {
    // Stop scanning if active
    if (isScanning.value) {
      await onStopRead();
    }

    // Only clear scan-related data
    totalCount.value = 0;
    listTagRFID.clear();
    phomBindingList.clear();
  }

  // Clear all data including search parameters
  Future<void> onClear() async {
    // Stop scanning if active
    if (isScanning.value) {
      await onStopRead();
    }

    isScan.value = false;
    selectedCodePhom.value = '';
    totalCount.value = 0;
    selectedSize.value = '';
    searchResults.clear();
    listTagRFID.clear();
    phomBindingList.clear();
  }

  Future<void> onSearch() async {
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

      final dynamic dataField = response.data["data"];
      if (dataField != null &&
          dataField is Map &&
          dataField.containsKey("jsonArray")) {
        final List<dynamic>? jsonArray = dataField["jsonArray"];
        if (jsonArray != null && jsonArray.isNotEmpty) {
          isScan.value = true;

          searchResults.value =
              jsonArray.map((item) {
                final Map<String, dynamic> mapItem = Map<String, dynamic>.from(
                  item,
                );
                mapItem['Scanning'] = 0;
                return mapItem;
              }).toList();
        } else {
          _showFeedback('Thông báo', 'Không tìm thấy kết quả phù hợp.');
        }
      } else {
        print(
          'Error: "data" or "jsonArray" field is missing or not in expected format.',
        );
        _showFeedback('Lỗi dữ liệu', 'Dữ liệu trả về không đúng định dạng.');
      }
    } catch (e) {
      _showFeedback('Lỗi', 'Không thể thực hiện tìm kiếm: ${e.toString()}');
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> onStopRead() async {
    try {
      await RFIDService.stopScan();
      isScanning.value = false;
      isLoading.value = false;
    } catch (e) {
      _showFeedback('Lỗi', 'Đã xảy ra lỗi khi dừng quét: $e');
    }
  }

  void checkAndAddNewTags(List<String> newTags) {
    final uniqueTags =
        newTags.where((tag) => !listTagRFID.contains(tag)).toList();

    if (uniqueTags.isNotEmpty) {
      listTagRFID.addAll(uniqueTags);
    } else {}
  }

  Future<void> onStartRead() async {
    if (isScanning.value) {
      return;
    }
    if (!isScan.value) {
      _showFeedback('Thông báo', 'Thực hiện tìm kiếm trước khi scan');
      return;
    }

    isLoading.value = true;

    try {
      // Connect to RFID device first
      final connected = await RFIDService.connect();
      if (!connected) {
        _showFeedback('Lỗi', 'Không thể kết nối với thiết bị RFID');
        isLoading.value = false;
        return;
      }
      
      final user = await _getuserUseCase.getUser();
      if (user == null) {
        _showFeedback('Lỗi', 'Không thể lấy thông tin người dùng.');
        isLoading.value = false;
        return;
      }

      listTagRFID.clear();
      phomBindingList.clear();
      rfidController.clear();
      totalCount.value = 0;

      // Clear native cache to start fresh
      await RFIDService.clearScannedTags();

      update();

      isScanning.value = true;
      isLoading.value = false; // Turn off loading once scanning starts

      await RFIDService.scanContinuous((epc) {
        if (!isScanning.value) return;

        // Trim and normalize EPC
        final normalizedEpc = epc.trim();

        // Double check: check both in Set AND in phomBindingList to prevent race condition
        final existsInSet = listTagRFID.contains(normalizedEpc);
        final existsInList = phomBindingList.any(
          (item) => item.rfid == normalizedEpc,
        );

        if (!existsInSet && !existsInList) {
          // Add to set first to prevent race condition
          listTagRFID.add(normalizedEpc);

          final item = PhomBindingItem(
            rfid: normalizedEpc,
            lastMatNo: selectedCodePhom.value.trim(),
            lastName: phomName.value.trim(),

            lastType:
                searchResults.isNotEmpty ? searchResults[0]["LastType"] : "",
            lastno: searchResults.isNotEmpty ? searchResults[0]["LastNo"] : "",
            material:
                searchResults.isNotEmpty ? searchResults[0]["Material"] : "",
            lastSize:
                searchResults.isNotEmpty ? searchResults[0]["LastSize"] : "",
            lastSide: isLeftSide.value ? "Left" : "Right",
            dateIn: currentDate,
            userID: user.userId ?? "",
            shelfName: "K1",
            companyName: user.companyName ?? "",
          );

          phomBindingList.add(item);

          // Update count based on actual list size to avoid race conditions
          totalCount.value = phomBindingList.length.toDouble();

          print(
            '✅ Added new tag: $normalizedEpc | Total: ${totalCount.value} | Set length: ${listTagRFID.length}',
          );
        } else {
          print(
            '⚠️ Duplicate tag ignored: $normalizedEpc (InSet: $existsInSet, InList: $existsInList)',
          );
        }
      });
    } catch (e) {
      _showFeedback('Lỗi', 'Đã xảy ra lỗi khi bắt đầu quét: $e');
      isScanning.value = false;
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

      final List<dynamic> jsonArray = response.data["data"]["jsonArray"];
      final List<String> newCodes =
          jsonArray
              .map<String>((item) => item["LastMatNo"].toString().trim())
              .toList();
      codePhomList.assignAll(newCodes.toSet().toList());
    } catch (e) {
      _showFeedback('Lỗi', 'Không thể lấy thông tin mã phom.');
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
      final responseSize = await ApiService(
        baseUrl,
      ).post('/phom/getSizeNotBinding', data);
      final List<dynamic> jsonArraySize =
          responseSize.data["data"]["jsonArray"];

      final List<String> newSizes =
          jsonArraySize
              .map<String>((item) => item["LastSize"].toString().trim())
              .toList();

      sizeList.assignAll(newSizes.toSet().toList());
      if (newSizes.isNotEmpty) {
        selectedSize.value = newSizes.first;
      }

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
      _showFeedback('Lỗi', 'Không thể lấy thông tin chi tiết mã phom.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> isVerify() async {
    if (listTagRFID.isEmpty) {
      _showFeedback('Lỗi', 'Vui lòng quét thẻ RFID trước.');
      return false;
    }
    if (selectedCodePhom.value.isEmpty) {
      _showFeedback('Lỗi', 'Vui lòng chọn mã phom.');
      return false;
    }
    if (selectedSize.value.isEmpty) {
      _showFeedback('Lỗi', 'Vui lòng chọn kích thước phom.');
      return false;
    }
    if (phomName.value.isEmpty) {
      _showFeedback('Lỗi', 'Vui lòng chọn tên phom.');
      return false;
    }

    return true;
  }

  Future<void> onFinish() async {
    // Không cho submit khi đang quét
    if (isScanning.value) {
      _showFeedback('Cảnh báo', 'Vui lòng dừng quét trước khi hoàn tất');
      return;
    }
    
    if (!await isVerify()) {
      return;
    }

    isLoading.value = true;

    // Show progress notification
    print('⏳ Đang xử lý: Đang lưu ${phomBindingList.length} thẻ RFID...');

    try {
      final data = {
        "companyName": companyName,
        "details": phomBindingList.map((item) => item.toJson()).toList(),
      };

      final response = await ApiService(baseUrl)
          .post('/phom/updatephom', data)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout - Vui lòng thử lại');
            },
          );

      if (response.data['statusCode'] == 200) {
        final responseData = response.data['data'];
        final int successCount = responseData['totalSuccess'] ?? 0;
        final int failureCount = responseData['totalFailure'] ?? 0;

        if (failureCount == 0) {
          DialogsUtils.showAlertDialog2(
            title: 'Thành Công',
            message: 'Đã cập nhật thành công tất cả $successCount thẻ RFID.',
            typeDialog: TypeDialog.success,
          );
          // Clear only scan data, keep search parameters for next batch
          await clearScanData();
        } else {
          print('⚠️ Cảnh Báo: Hoàn tất: $successCount thành công, $failureCount thất bại.');
        }
      } else {
        final errorMessage =
            response.data['message'] ?? 'Lỗi không xác định từ server.';
        _showFeedback('Lỗi Server', errorMessage);
      }
    } catch (e) {
      _showFeedback('Lỗi Hệ Thống', 'Không thể kết nối đến máy chủ: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initializeData();

    RFIDService.setOnHardwareScan(() {
      print(
        '🔔 Nút cứng đã được bấm! Trạng thái quét hiện tại: ${isScanning.value}',
      );

      if (isScanning.value) {
        onStopRead();
      } else {
        onStartRead();
      }
    });
  }

  Future<void> _initializeData() async {
    isLoading.value = true;
    try {
      user = await _getuserUseCase.getUser();
      if (user == null ||
          user!.companyName == null ||
          user!.companyName!.isEmpty) {
        Get.snackbar(
          'Lỗi',
          'Không tìm thấy thông tin người dùng hoặc công ty.',
        );
        return;
      }

      companyName = user!.companyName;
      await getLastMatNo();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể khởi tạo dữ liệu: $e');
    } finally {
      isLoading.value = false;
    }
  }


  @override
  void onClose() {
    rfidController.dispose();
    phomBindingList.clear();
    listTagRFID.clear();
    super.onClose();
  }
}
