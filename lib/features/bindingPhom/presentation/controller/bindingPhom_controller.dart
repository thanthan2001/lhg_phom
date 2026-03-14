import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/services/models/phom_model.dart';
import 'package:lhg_phom/core/services/models/user/domain/usecase/get_user_use_case.dart';
import 'package:lhg_phom/core/services/models/user/model/user_model.dart';
import 'package:lhg_phom/core/utils/date_time.dart';
import '../../../../core/configs/enum.dart';
import '../../../../core/services/dio.api.service.dart';
import '../../../../core/services/rfid_service.dart';
import 'dart:convert';

import '../../../../core/ui/dialogs/dialogs.dart';

class BindingPhomController extends GetxController {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  final GetuserUseCase _getuserUseCase;
  UserModel? user;
  String? companyName;

  BindingPhomController(this._getuserUseCase);
  Timer? _debounce;
  
  // Safe feedback helper - uses dialog for async contexts instead of snackbar
  void _showFeedback(String title, String message, {bool isSuccess = false}) {
    print('[$title] $message'); // Always log for debugging
    
    try {
      if (Get.context != null && WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        // Use dialog instead of snackbar for stability in async callbacks
        Get.dialog(
          AlertDialog(
            title: Text(isSuccess ? '✅ $title' : '⚠️ $title'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(Get.context!).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
          barrierDismissible: true,
        );
      }
    } catch (e) {
      print('Failed to show dialog: $e');
    }
  }

  final materialCodeController = TextEditingController();
  final phomNameController = TextEditingController();
  final sizeController = TextEditingController();
  final rfidController = TextEditingController();
  final phomBindingList = <PhomBindingItem>[].obs;
  final selectedMatNo = ''.obs;
  final RxList<String> codePhomList = <String>[].obs;
  final isLoadingCodes = false.obs;

  final tableScrollController = ScrollController();
  final scrollbarController = ScrollController();

  final isLoading = false.obs;
  final isLoadingStop = false.obs;
  final isSearching = false.obs;
  final isFinishing = false.obs;

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
    isScanning.value = false;
    materialCodeController.clear();
    selectedMatNo.value = '';
    TagsList.clear();
    phomName.value = '';
    selectedSize.value = '';
    sizeList.clear();
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
        content: SizedBox(
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

        if (errorItemsDetails.isNotEmpty) {
          _showErrorDialog(errorItemsDetails);
        } else {
          _showFeedback('Thành công', 'Không có lỗi RFID', isSuccess: true);
        }
      } else {
        print("Không tìm thấy thông tin chi tiết cho RFID lỗi.");
      }
    } catch (e) {
      isScanning.value = false;
      isLoading.value = false;
      _showFeedback('Lỗi', 'Đã xảy ra lỗi khi dừng quét: $e');
    }
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
        _showFeedback('Lỗi', 'Không đọc được thẻ');
        rfidController.text = 'fails';
      }
    } catch (e) {
      _showFeedback('Lỗi', 'Đã xảy ra lỗi khi quét RFID: $e');
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
      TagsList.clear();
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
        if (!listTagRFID.contains(epc)) {
          listTagRFID.add(epc);
          var rfidShortcut = epc.substring(epc.length - 10);
          TagsList.add(rfidShortcut);
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
            rfidShortcut: rfidShortcut,
            companyName: user.companyName ?? "",
          );
          phomBindingList.add(item);
          rfidController.text = listTagRFID.join(', ');
          totalCount.value += 1;
        }
      });
    } catch (e) {
      isLoading.value = false;
      isScanning.value = false;
      _showFeedback('Lỗi', 'Đã xảy ra lỗi khi bắt đầu quét: $e');
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
      _showFeedback('Thông báo', 'Thực hiện tìm kiếm trước khi scan');
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
        _showFeedback('Lỗi', 'Không tìm thấy thẻ nào');
      }
    } catch (e) {
      _showFeedback('Lỗi', 'Đã xảy ra lỗi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> callLastName(String MaVatTu) async {
    user = await _getuserUseCase.getUser();
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      if (MaVatTu.trim().isNotEmpty) {
        final companyName = user?.companyName;
        if (companyName == null || companyName.isEmpty) {
          _showFeedback('Loi', 'Khong tim thay thong tin cong ty');
          return;
        }

        sizeList.clear();
        selectedSize.value = '';

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
              _showFeedback('Lỗi', 'Không có dữ liệu từ API');
            }
          } else {
            phomName.value = '';

            _showFeedback('Lỗi', 'Đã xảy ra lỗi khi gọi API: ${response.statusMessage}');
          }
        } catch (e) {
          _showFeedback('Lỗi', 'Đã xảy ra lỗi khi gọi API: $e');
        }
      }
    });
  }

  Future<void> searchPhomBinding() async {
    if (isSearching.value) return;
    isSearching.value = true;
    user = await _getuserUseCase.getUser();
    final companyName = user?.companyName;
    if (companyName == null || companyName.isEmpty) {
      isSearching.value = false;
      _showFeedback('Loi', 'Khong tim thay thong tin cong ty');
      return;
    }
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
      isSearching.value = false;
    }
  }

  Future<void> onFinish() async {
    if (isFinishing.value) return;
    // Không cho submit khi đang quét
    if (isScanning.value) {
      _showFeedback('Cảnh báo', 'Vui lòng dừng quét trước khi hoàn tất');
      return;
    }
    
    if (phomBindingList.isEmpty) {
      _showFeedback('Thông báo', 'Không có dữ liệu để gửi');
      return;
    }
    isFinishing.value = true;
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
        final summary = resData['summary'];
        final successCount = summary['successCount'];
        final failCount = summary['failCount'];
        final failedRFIDs = (summary['failedRFIDs'] as List).join(', ');
        listTagRFID.clear();
        TagsList.clear();
        phomBindingList.clear();

        totalCount.value = 0;

        DialogsUtils.showAlertDialog2(
          title: 'Thành Công',
          message:
              'Đã binding thành công!\n\nThành công: $successCount thẻ\nThất bại: $failCount thẻ${failedRFIDs.isNotEmpty ? '\n\nRFID lỗi: $failedRFIDs' : ''}',
          typeDialog: TypeDialog.success,
        );
      } else {
        _showFeedback('Lỗi', resData['message'] ?? "Không rõ lỗi");
      }
    } catch (e) {
      _showFeedback('Lỗi', "Đã xảy ra lỗi: $e");
    } finally {
      isFinishing.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _syncScrollControllers();
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

  Future<void> _initializeData() async {
    isLoadingCodes.value = true;
    try {
      user = await _getuserUseCase.getUser();
      companyName = user?.companyName;
      if (companyName == null || companyName!.isEmpty) {
        _showFeedback('Loi', 'Khong tim thay thong tin cong ty');
        return;
      }
      await getLastMatNo();
    } catch (e) {
      _showFeedback('Loi', 'Khong the khoi tao du lieu: $e');
    } finally {
      isLoadingCodes.value = false;
    }
  }

  Future<void> getLastMatNo() async {
    if (companyName == null || companyName!.isEmpty) {
      _showFeedback('Loi', 'Khong tim thay thong tin cong ty');
      return;
    }
    isLoadingCodes.value = true;
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
      _showFeedback('Loi', 'Khong the lay thong tin ma phom');
    } finally {
      isLoadingCodes.value = false;
    }
  }
}
