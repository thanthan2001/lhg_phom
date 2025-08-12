import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/configs/app_colors.dart';
import 'package:lhg_phom/core/services/models/phom_model.dart';
import 'package:lhg_phom/core/services/models/user/domain/usecase/get_user_use_case.dart';
import 'package:lhg_phom/core/services/models/user/model/user_model.dart';
import 'package:lhg_phom/core/utils/date_time.dart';
import '../../../../core/configs/enum.dart';
import '../../../../core/services/dio.api.service.dart';
import '../../../../core/services/rfid_service.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import '../../../../core/ui/dialogs/dialogs.dart';

class BindingPhomController extends GetxController {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  final GetuserUseCase _getuserUseCase;
  UserModel? user;

  BindingPhomController(this._getuserUseCase);
  Timer? _debounce;

  final materialCodeController = TextEditingController();
  final phomNameController = TextEditingController();
  final sizeController = TextEditingController();
  final rfidController = TextEditingController();
  final phomBindingList = <PhomBindingItem>[].obs;

  final tableScrollController = ScrollController();
  final scrollbarController = ScrollController();

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
  var TagsList = [].obs;

  var totalCount = 0.0.obs;
  var isScan = false.obs;
  var listFullScannedData = <Map<String, dynamic>>[].obs;
  final phomTypeList = ['L1', 'L2', 'L3', 'L4', 'L5', 'L6'];
  final shelfList = ['K1', 'K2', 'K3'];

  final currentDate = DatetimeUtil.currentDate();

  final inventoryData = <List<String>>[].obs;
  final selectedSize = ''.obs;
  final sizeList = <String>[].obs;
  final isScanning = false.obs;
  Future<void> onClear() async {
    totalCount.value = 0;
    isScan.value = false;
    isScanning.value = false; // Đặt lại trạng thái quét
    materialCodeController.clear();
    TagsList.clear();
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

  void _showErrorDialog(List<Map<String, dynamic>> errorItems) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Tổng số lượng RFID lỗi: ${errorItems.length}',
          style: TextStyle(color: Colors.red[700]),
        ),
        content: Container(
          width: double.maxFinite,
          child: SizedBox(
            height: 300.0,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: errorItems.length,
              itemBuilder: (BuildContext context, int index) {
                final item = errorItems[index];
                final data = item['data'][0];
                final rfid =
                    data['RFID_Shortcut']?.trim() ?? data['RFID'] ?? 'N/A';
                final lastName = data['LastName']?.trim() ?? 'N/A';
                final lastSize = data['LastSize']?.trim() ?? 'N/A';

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    title: Text(
                      'RFID: $rfid',
                      maxLines: 2,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tên phom: $lastName'),
                        Text('Size: $lastSize'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text('Đóng'),
            onPressed: () {
              Get.back();
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> onStopRead() async {
    try {
      await RFIDService.stopScan();
      isScanning.value = false;
      isLoading.value = false;
      final companyName = user?.companyName;

      // Nếu không có RFID nào được quét thì không cần gọi API
      if (listTagRFID.isEmpty) {
        return;
      }

      print('List Tag RFID: $listTagRFID');
      final data = {
        "companyName": companyName,
        "ListRFID": listTagRFID.toList(),
      };

      final response = await ApiService(
        baseUrl,
      ).post('/phom/checkExitsRFID', data);

      if (response.data["statusCode"] == 400) {
        print(response.data["data"]);
        final List<dynamic> errorRfidListFromApi = response.data["data"];
        print('Danh sách RFID lỗi: $errorRfidListFromApi');
        final List<Map<String, dynamic>> errorItemsDetails =
            errorRfidListFromApi.cast<Map<String, dynamic>>();

        if (errorItemsDetails.length > 0) {
          _showErrorDialog(errorItemsDetails);
        }
      } else {
        Get.snackbar(
          '✅ Thành công',
          'Không có lỗi',
          backgroundColor: Colors.greenAccent.withOpacity(0.8),
        );
        print("Không tìm thấy thông tin chi tiết cho RFID lỗi.");
      }
    } catch (e) {
      isScanning.value = false;
      isLoading.value = false;
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi khi dừng quét: $e');
    }
  }

  Future<void> _connectRFID() async {
    try {
      final connected = await RFIDService.connect();
      if (connected) {
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
      Get.snackbar(
        '❌Lỗi',
        'Kết nối RFID thất bại: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
      );
    }
  }

  Future<void> _disconnectRFID() async {
    try {
      await RFIDService.disconnect();
    } catch (e) {}
  }

  Future<void> onScan() async {
    isLoading.value = true;
    isShowingDetail.value = false;

    try {
      final epc = await RFIDService.scanSingleTag();
      if (epc != null && epc.isNotEmpty) {
        rfidController.text = epc;

        isShowingDetail.value = true;
      } else {
        Get.snackbar('Lỗi', 'Không đọc được thẻ');
        rfidController.text = 'fails';
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi khi quét RFID: $e');
    } finally {
      isLoading.value = false;
    }
  }

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

  Future<void> onStartRead() async {
    if (isScanning.value) return;
    if (!isScan.value) {
      Get.snackbar(
        '⚠️Thông báo',
        'Thực hiện tìm kiếm trước khi scan',
        backgroundColor: AppColors.primary2,
      );
      return;
    }

    isLoading.value = true;

    try {
      final user = await _getuserUseCase.getUser();
      if (user == null) {
        Get.snackbar('Lỗi', 'Không thể lấy thông tin người dùng.');
        isLoading.value = false;
        return;
      }
      listTagRFID.clear();
      TagsList.clear();
      phomBindingList.clear();
      rfidController.clear();
      totalCount.value = 0;
      update();
      await RFIDService.scanContinuous((epc) {
        if (!isScanning.value) return;
        if (!listTagRFID.contains(epc)) {
          listTagRFID.add(epc);
          var _rfidShortcut = epc.substring(epc.length - 10);
          TagsList.add(_rfidShortcut);
          final item = PhomBindingItem(
            rfid: epc,
            lastMatNo: materialCodeController.text.trim(),
            lastName: phomName.value.trim(),
            lastno: inventoryData[0][2].trim(),
            lastType: inventoryData[0][3].trim(),
            material: inventoryData[0][5].trim(),
            lastSize: selectedSize.value.trim(),
            lastSide: isLeftSide.value ? "Left" : "Right",
            dateIn: currentDate,
            userID: user.userId ?? "",
            shelfName: 'K1',
            rfidShortcut: _rfidShortcut,
            companyName: user.companyName ?? "",
          );
          phomBindingList.add(item);
          rfidController.text = listTagRFID.join(', ');
          totalCount.value += 0.5;
        }
      });

      isScanning.value = true;
    } catch (e) {
      isLoading.value = false;
      isScanning.value = false;
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi khi bắt đầu quét: $e');
    }
  }

  void checkAndAddNewTags(List<String> newTags) {
    final uniqueTags =
        newTags.where((tag) => !listTagRFID.contains(tag)).toList();
    if (uniqueTags.isNotEmpty) {
      listTagRFID.addAll(uniqueTags);
      totalCount.value = (listTagRFID.length) / 2;
    } else {}
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
    try {
      final tags = await RFIDService.scanSingleTagMultiple(
        timeout: Duration(milliseconds: 100),
      );
      if (tags.isNotEmpty) {
        checkAndAddNewTags(tags);
        phomBindingList.clear();
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

        final data = {"LastMatNo": MaVatTu, "companyName": companyName};
        try {
          var response = await ApiService(
            baseUrl,
          ).post('/phom/getPhomByLastMatNo', data);

          if (response.statusCode == 200) {
            var data = response.data;
            if (data != null && data['data']['rowCount'] != 0) {
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
              } else {
                print(
                  '❌ Lỗi lấy kích thước không bị ràng buộc: ${resLastSize.data["message"]}',
                );
              }
            } else {
              phomName.value = '';
              Get.snackbar('Lỗi', 'Không có dữ liệu từ API');
            }
          } else {
            phomName.value = '';

            Get.snackbar(
              'Lỗi',
              'Đã xảy ra lỗi khi gọi API: ${response.statusMessage}',
            );
          }
        } catch (e) {
          Get.snackbar('Lỗi', 'Đã xảy ra lỗi khi gọi API: $e');
        }
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

      var response = await ApiService(
        baseUrl,
      ).post('/phom/searchPhomBinding', data);

      if (response.data["statusCode"] == 200) {
        var data = response.data;
        if (data != null && data['data']['rowCount'] != 0) {
          final List<dynamic> jsonArray = data['data']['jsonArray'];
          isScan.value = true;

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

              (item['BindingCount'] ?? 0).toString(),
            ];
            inventoryData.add(row);
          }
        } else {
          phomName.value = '';
          Get.snackbar('Lỗi', 'Không có dữ liệu từ API');
        }
      } else {
        phomName.value = '';

        Get.snackbar(
          'Lỗi',
          'Đã xảy ra lỗi khi gọi API: ${response.statusMessage}',
        );
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi khi gọi API: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onFinish() async {
    if (phomBindingList.isEmpty) {
      Get.snackbar(
        '⚠️Thông báo',
        'Không có dữ liệu để gửi',
        backgroundColor: AppColors.primary2,
      );
      return;
    }
    try {
      final data = {
        "companyName": user?.companyName ?? "",
        "details": phomBindingList.map((item) => item.toJson()).toList(),
      };
      print(
        'phomBindingList: ${jsonEncode(phomBindingList.map((e) => e.toJson()).toList())}',
      );
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
        listTagRFID.clear();
        TagsList.clear();
        phomBindingList.clear();

        totalCount.value = 0;

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

  @override
  void onClose() {
    if (isScanning.value) {
      RFIDService.stopScan();
    }
    materialCodeController.dispose();
    sizeController.dispose();
    rfidController.dispose();
    tableScrollController.dispose();
    scrollbarController.dispose();

    super.onClose();
  }
}
