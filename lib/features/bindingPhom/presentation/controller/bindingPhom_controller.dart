import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/configs/app_colors.dart';
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
  var totalCount = 0.obs;
  var isScan = false.obs;
  // Dropdown data
  final phomTypeList = ['L1', 'L2', 'L3', 'L4', 'L5', 'L6'];
  final shelfList = ['K1', 'K2', 'K3'];

  final currentDate = DatetimeUtil.currentDate();

  // Table data
  final inventoryData = <List<String>>[].obs;
  final selectedSize = ''.obs;
  final sizeList = <String>[].obs;

  Future<void> onClear() async {
    totalCount.value = 0;
    isScan.value = false;
    materialCodeController.clear();
    phomName.value = '';
    selectedSize.value = '';
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
        Get.snackbar(
          '✅ Kết nối thành công',
          'Đã kết nối với thiết bị RFID',
          backgroundColor: Colors.green.withOpacity(0.8),
        );
      } else {
        Get.snackbar(
          '❌Lỗi',
          'Kết nối RFID thất bại',
          backgroundColor: Colors.red.withOpacity(0.8),
        );
      }
    } catch (e) {
      print('❌ Lỗi kết nối RFID: $e');
      Get.snackbar(
        '❌Lỗi',
        'Kết nối RFID thất bại: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
      );
    }
  }

  Future<void> onStopRead() async {
    try {
      await RFIDService.stopScan();
      print('⏹️ Dừng quét RFID');
    } catch (e) {
      print('❌ Lỗi dừng quét: $e');
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi khi dừng quét: $e');
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
      totalCount.value = listTagRFID.length;
    } else {
      print('⚠️ Tất cả tag đã tồn tại, không thêm mới');
    }
  }

  Future<void> onScanMultipleTags() async {
    if (!isScan.value) {
      Get.snackbar(
        '⚠️Thông báo',
        'Thực hiện tìm kiếm trước khi scan',
        backgroundColor: AppColors.primary2,
      );
      return;
    }
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
            material: inventoryData[0][5].trim(),
            lastSize: selectedSize.value.trim(),
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
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
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

              final resLastSize = await ApiService(baseUrl).post(
                '/phom/getSizeNotBinding',
                {"LastMatNo": MaVatTu, "companyName": companyName},
              );
              if (resLastSize.data["statusCode"] == 200) {
                print(
                  '✅ Gọi API lấy kích thước không bị ràng buộc thành công: ${resLastSize.data}',
                );
                final List<dynamic> jsonArray =
                    resLastSize.data['data']['jsonArray'];
                sizeList.clear();
                for (var item in jsonArray) {
                  final size = item['LastSize']?.toString().trim() ?? '';
                  if (size.isNotEmpty && !sizeList.contains(size)) {
                    sizeList.add(size);
                  }
                }
                print('✅ Kích thước không bị ràng buộc: $sizeList');
              } else {
                print(
                  '❌ Lỗi lấy kích thước không bị ràng buộc: ${resLastSize.data["message"]}',
                );
              }
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
        "SizePhom": selectedSize.value,
      };
      print('Gọi API với dữ liệu: $data');
      var response = await ApiService(
        baseUrl,
      ).post('/phom/searchPhomBinding', data);

      if (response.data["statusCode"] == 200) {
        var data = response.data;
        if (data != null && data['data']['rowCount'] != 0) {
          print('✅ Gọi API thành công: $data');
          final List<dynamic> jsonArray = data['data']['jsonArray'];
          isScan.value = true;
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

  // Future<void> onFinish() async {
  //   try {
  //     final data = {
  //       "companyName": user?.companyName ?? "",
  //       "details": phomBindingList.map((item) => item.toJson()).toList(),
  //     };

  //     final response = await ApiService(baseUrl).post(
  //       '/phom/bindingPhom', // Giả sử backend có endpoint này để nhận một đối tượng
  //       data,
  //     );
  //     print(response.data);
  //     if (response.data['statusCode'] == 200) {
  //       print("✅ Gửi thành công: ${response.data["data"]["RFID"]}");
  //       Get.snackbar(
  //         '✅ Gửi thành công',
  //         'Đã gửi thành công cho RFID: ${response.data["data"]["RFID"]}',
  //         snackPosition: SnackPosition.BOTTOM,
  //       );
  //     } else {
  //       print("❌ Gửi thất bại cho RFID: ${response.data["data"]["RFID"]}");
  //       Get.snackbar(
  //         "Lỗi ${response.data['message']}",
  //         "Gửi thất bại cho RFID: ${response.data["data"]["RFID"]}",
  //         snackPosition: SnackPosition.BOTTOM,
  //       );
  //     }
  //   } catch (e) {
  //     print("❌ Lỗi khi gửi dữ liệu: $e");
  //     Get.snackbar(
  //       "Lỗi",
  //       "Đã xảy ra lỗi: $e",
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //   }
  // }
  Future<void> onFinish() async {
    try {
      final data = {
        "companyName": user?.companyName ?? "",
        "details": phomBindingList.map((item) => item.toJson()).toList(),
      };

      final response = await ApiService(
        baseUrl,
      ).post('/phom/bindingPhom', data);

      final resData = response.data;

      if (resData['statusCode'] == 200) {
        final insertedList = resData['data'] as List<dynamic>;
        final summary = resData['summary'];
        final successCount = summary['successCount'];
        final failCount = summary['failCount'];
        final failedRFIDs = (summary['failedRFIDs'] as List).join(', ');
        listTagRFID.clear(); // Xóa danh sách RFID đã quét
        phomBindingList.clear(); // Xóa danh sách đã ràng buộc
        totalCount.value = 0; // Đặt lại tổng số lượng
        Get.snackbar(
          '✅ Gửi thành công',
          'Thành công: $successCount, Thất bại: $failCount\nRFID lỗi: $failedRFIDs',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
      } else {
        Get.snackbar(
          "❌ Lỗi",
          resData['message'] ?? "Không rõ lỗi",
          snackPosition: SnackPosition.BOTTOM,
        );
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
