import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/services/models/phom_model.dart';
import 'package:lhg_phom/core/services/models/user/domain/usecase/get_user_use_case.dart';
import 'package:lhg_phom/core/services/models/user/model/user_model.dart';
import 'package:lhg_phom/core/utils/date_time.dart';
import '../../../../core/services/dio.api.service.dart';
import '../../../../core/services/rfid_service.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class BindingPhomController extends GetxController {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  final GetuserUseCase _getuserUseCase;
  UserModel? user;

  BindingPhomController(this._getuserUseCase);
  Timer? _debounce;
  // Text Controllers
  final materialCodeController = TextEditingController();
  final phomNameController = TextEditingController();
  final sizeController = TextEditingController();
  final rfidController = TextEditingController();
  final phomBindingList = <PhomBindingItem>[].obs;

  // Scroll Controllers
  final tableScrollController = ScrollController();
  final scrollbarController = ScrollController();

  // State
  final isLoading = false.obs;
  final isLoadingStop = false.obs;

  final phomName = ''.obs;
  final lastNo = ''.obs;
  final selectedPhomType = ''.obs;
  final selectedShelf = ''.obs;
  final isLeftSide = true.obs;
  final isShowingDetail = false.obs;
  final scrollProgress = 0.0.obs;
  final selectedRowIndex = Rx<int?>(null);
  var listTagRFID = [];
  // Dropdown data
  final phomTypeList = ['L1', 'L2', 'L3', 'L4', 'L5', 'L6'];
  final shelfList = ['K1', 'K2', 'K3'];

  final currentDate = DatetimeUtil.currentDate();

  // Table data
  final inventoryData = <List<String>>[].obs;

  Future<void> onClear() async {
    materialCodeController.clear();
    phomName.value = '';
    sizeController.clear();
    rfidController.clear();
    listTagRFID.clear();
    phomBindingList.clear();
    inventoryData.clear();
    isLeftSide.value = true;
    isShowingDetail.value = false;
    selectedRowIndex.value = null;
    update();
  }
  // ==================== RFID LOGIC ====================

  /// Kết nối thiết bị RFID
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

  /// Ngắt kết nối khi đóng controller
  Future<void> _disconnectRFID() async {
    try {
      await RFIDService.disconnect();
      print('✅ Ngắt kết nối RFID');
    } catch (e) {
      print('❌ Lỗi ngắt kết nối: $e');
    }
  }

  /// Bắt đầu đọc liên tục
  Future<void> onStartRead() async {
    try {
      await RFIDService.scanContinuous((epc) {
        rfidController.text = epc;
        print('📡 EPC quét liên tục: $epc');
      });
      print('▶️ Đang quét liên tục...');
    } catch (e) {
      print('❌ Lỗi startRead: $e');
    }
  }

  /// Quét 1 lần
  Future<void> onScan() async {
    isLoading.value = true;
    isShowingDetail.value = false;

    try {
      final epc = await RFIDService.scanSingleTag();
      if (epc != null && epc.isNotEmpty) {
        rfidController.text = epc;
        print('✅ EPC đã quét: $epc');
        isShowingDetail.value = true;
      } else {
        Get.snackbar('Lỗi', 'Không đọc được thẻ');
        rfidController.text = 'fails';
        print('⚠️ Không có dữ liệu');
      }
    } catch (e) {
      print('❌ Lỗi quét RFID: $e');
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi khi quét RFID: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== UI LOGIC ====================

  void onSearch() => isShowingDetail.value = false;
  void onSelectLeft() => isLeftSide.value = true;
  void onSelectRight() => isLeftSide.value = false;

  void _syncScrollControllers() {
    bool isSyncing = false;
    tableScrollController.addListener(() {
      if (isSyncing || !scrollbarController.hasClients) return;
      isSyncing = true;
      scrollbarController.jumpTo(tableScrollController.offset);
      isSyncing = false;
    });
    scrollbarController.addListener(() {
      if (isSyncing || !tableScrollController.hasClients) return;
      isSyncing = true;
      tableScrollController.jumpTo(scrollbarController.offset);
      isSyncing = false;
    });
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
            lastMatNo: materialCodeController.text.trim(),
            lastName: phomName.value.trim(),
            lastno: inventoryData[0][2].trim(),
            lastType: inventoryData[0][3].trim(),
            material: inventoryData[0][4].trim(),
            lastSize: sizeController.text.trim(),
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
        rfidController.text = listTagRFID.join(', ');
      } else {
        Get.snackbar('Lỗi', 'Không tìm thấy thẻ nào');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> callLastName(String MaVatTu) async {
    user = await _getuserUseCase.getUser();
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 2000), () async {
      if (MaVatTu.trim().isNotEmpty) {
        final companyName = user!.companyName;
        print('Công ty: $companyName');
        final data = {"LastMatNo": MaVatTu, "companyName": companyName};
        try {
          var response = await ApiService(
            baseUrl,
          ).post('/phom/getPhomByLastMatNo', data);

          if (response.statusCode == 200) {
            var data = response.data;
            if (data != null && data['data']['rowCount'] != 0) {
              print('✅ Gọi API thành công: $data');
              phomName.value = data['data']['jsonArray'][0]['LastName'] ?? '';
            } else {
              print('⚠️ Không có dữ liệu từ API');
              phomName.value = '';
              Get.snackbar('Lỗi', 'Không có dữ liệu từ API');
            }
          } else {
            print('❌ Lỗi gọi API: ${response.statusMessage}');
            phomName.value = '';

            Get.snackbar(
              'Lỗi',
              'Đã xảy ra lỗi khi gọi API: ${response.statusMessage}',
            );
          }
        } catch (e) {
          print('❌ Lỗi gọi API: $e');
          Get.snackbar('Lỗi', 'Đã xảy ra lỗi khi gọi API: $e');
        }
        print('Gọi API với mã vật tư: $MaVatTu');
      }
    });
  }

  Future<void> searchPhomBinding() async {
    isLoading.value = true;
    user = await _getuserUseCase.getUser();
    final companyName = user!.companyName;
    try {
      final data = {
        "companyName": companyName,
        "MaVatTu": materialCodeController.text,
        "TenPhom": phomName.value,
        "SizePhom": sizeController.text,
      };
      var response = await ApiService(
        baseUrl,
      ).post('/phom/searchPhomBinding', data);

      if (response.statusCode == 200) {
        var data = response.data;
        if (data != null && data['data']['rowCount'] != 0) {
          print('✅ Gọi API thành công: $data');
          final List<dynamic> jsonArray = data['data']['jsonArray'];
          // phomName.value = data['data']['jsonArray'][0]['LastName'] ?? '';
          inventoryData.clear();
          for (var item in jsonArray) {
            final row = [
              (item['LastMatNo'] ?? '').toString().trim(),
              (item['LastName'] ?? '').toString().trim(),
              (item['LastNo'] ?? '').toString().trim(),
              (item['LastType'] ?? '').toString().trim(),
              (item['LastBrand'] ?? '').toString().trim(),
              (item['Material'] ?? '').toString().trim(),
              (item['LastSize'] ?? '').toString().trim(),
              (item['LastQty'] ?? 0).toString(),
              (item['LeftCount'] ?? 0).toString(),
              (item['RightCount'] ?? 0).toString(),
              (item['BindingCount'] ?? 0).toString(),
            ];
            inventoryData.add(row);
          }
          print('✅ Dữ liệu tồn kho: $inventoryData');
        } else {
          print('⚠️ Không có dữ liệu từ API');
          phomName.value = '';
          Get.snackbar('Lỗi', 'Không có dữ liệu từ API');
        }
      } else {
        print('❌ Lỗi gọi API: ${response.statusMessage}');
        phomName.value = '';

        Get.snackbar(
          'Lỗi',
          'Đã xảy ra lỗi khi gọi API: ${response.statusMessage}',
        );
      }
    } catch (e) {
      print('❌ Lỗi gọi API: $e');
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi khi gọi API: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onFinish() async {
    try {
      for (var item in phomBindingList) {
        var data = item.toJson(); // Chuyển đổi mỗi đối tượng thành map

        final response = await ApiService(baseUrl).post(
          '/phom/bindingPhom', // Giả sử backend có endpoint này để nhận một đối tượng
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

  @override
  void onInit() {
    super.onInit();
    _syncScrollControllers();
    _connectRFID();
  }

  @override
  void onClose() {
    materialCodeController.dispose();
    sizeController.dispose();
    rfidController.dispose();
    tableScrollController.dispose();
    scrollbarController.dispose();
    _disconnectRFID();
    super.onClose();
  }
}
