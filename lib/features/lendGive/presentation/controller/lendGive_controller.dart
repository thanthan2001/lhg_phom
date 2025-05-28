import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lhg_phom/core/services/models/user/domain/usecase/get_user_use_case.dart';
import 'package:lhg_phom/core/services/models/user/model/user_model.dart';
import 'dart:convert';

import 'package:lhg_phom/core/services/rfid_service.dart';

import '../../../../core/services/dio.api.service.dart';

class LendGiveController extends GetxController {
  final GetuserUseCase _getuserUseCase;
  LendGiveController(this._getuserUseCase);
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  final Map<String, String> depNameToIdMap = {};
  final sumController = TextEditingController();
  final dateController = TextEditingController();
  final bill_br_id = TextEditingController();
  final userNameController = TextEditingController();
  final rfidController = TextEditingController();
  late String? companyName;
  String? idBillFromSearch;
  final tableScrollController = ScrollController();
  RxString selectedDepartmentId = ''.obs;

  var listTagRFID = [].obs;
  List<String> lastSizeList = [];

  // State
  final isLoading = false.obs;
  final selectedCodePhom = ''.obs;
  final selectedDepartment = ''.obs;
  final isLeftSide = true.obs;
  final isShowingDetail = false.obs;
  final scrollProgress = 0.0.obs;
  var selectedRowIndex = Rx<int?>(null);
  final LastSum = 0.obs;
  UserModel? user;

  final codePhomList = <String>[].obs;
  final departmentList = <String>[].obs;

  final List<String> headers = [
    'ID Bill',
    'Dep ID',
    'Last Mat No',
    'Last Name',
    'Last Size',
    'Last Sum',
    'Scanned',
  ];

  final epcDataTable = <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>> scannedRfidDetailsList =
      <Map<String, dynamic>>[].obs;

  Map<String, dynamic> get currentApiDataPayload {
    final scanDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return {
      "companyName": companyName,
      "ScanDate": scanDate,
      "DepID": selectedDepartment.value,
      "StateScan": "0",
    };
  }

  // Table data
  var inventoryData = <List<String>>[].obs;
  var isAvalableScan = false.obs;

  // Logic
  void onScan() {
    isShowingDetail.value = true;
  }

  Future<void> onStop() async {
    await RFIDService.stopScan();
  }

  Future<void> onFinish() async {
    if (scannedRfidDetailsList.isEmpty) {
      Get.snackbar("Thông báo", "Không có dữ liệu quét chi tiết để gửi đi.");
      return;
    }

    if (user == null || companyName == null || companyName!.isEmpty) {
      Get.snackbar("Lỗi", "Thông tin người dùng hoặc công ty không đầy đủ.");
      return;
    }

    isLoading.value = true;

    final String apiEndpoint = '/phom/saveBill';
    final String commonCompanyName = companyName!;
    final String commonUserID = user!.userId!;
    final String commonDateBorrow = convertDate(dateController.text);

    final List<Map<String, dynamic>> preparedList =
        scannedRfidDetailsList.map((item) {
          return {
            // "companyName": commonCompanyName,
            "StateScan": 0,
            "ID_BILL": idBillFromSearch,
            "DepID": item["DepID"],
            "ScanDate": item["ScanDate"],
            "RFID": item["RFID"],
            "UserID": commonUserID,
            "DateBorrow": commonDateBorrow,
          };
        }).toList();

    final Map<String, dynamic> payload = {
      "companyName": commonCompanyName,
      "scannedRfidDetailsList": preparedList,
    };
    print('payload for saveBill: $payload');
    try {
      final response = await ApiService(baseUrl).post(apiEndpoint, payload);

      isLoading.value = false;

      if (response.statusCode == 200) {
        final data = response.data;
        final successCount = data['successCount'] ?? 0;
        final failureCount = data['failureCount'] ?? 0;

        if (successCount > 0 && failureCount == 0) {
          await Get.snackbar(
            "Thành công",
            "$successCount mục đã được gửi thành công!",
          );
          await onClear();
          Get.back();
        } else if (successCount > 0 && failureCount > 0) {
          await Get.snackbar(
            "Hoàn tất một phần",
            "$successCount mục thành công, $failureCount mục thất bại.",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          print("🔺 Thất bại:\n${data['failedList']}");
        } else {
          Get.snackbar(
            "Thất bại",
            "Tất cả đều thất bại. Vui lòng kiểm tra lại.",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          "Lỗi",
          "Không thể gửi dữ liệu. Mã lỗi: ${response.statusCode}",
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Lỗi hệ thống", "Không thể kết nối tới máy chủ.");
      print("❌ Exception: $e");
    }
  }

  bool isValidDate(String input) {
    try {
      final parts = input.split('/');
      if (parts.length != 3) return false;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final inputDate = DateTime(year, month, day);
      final now = DateTime.now();

      if (inputDate.isBefore(DateTime(now.year, now.month, now.day))) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> onClear() async {
    print("Clear action triggered");
    LastSum.value = 0;
    bill_br_id.clear();
    listTagRFID.clear();
    print("  - listTagRFID cleared.");

    epcDataTable.clear();
    print("  - epcDataTable cleared.");

    scannedRfidDetailsList.clear(); // Clear the new list
    print("  - scannedRfidDetailsList cleared.");

    if (inventoryData.isEmpty) {
      print("  - inventoryData is already empty, nothing to clear.");
    } else {
      inventoryData.clear();
      print("  - inventoryData cleared.");
    }

    selectedCodePhom.value = '';
    print("  - selectedCodePhom reset to empty.");
    selectedDepartment.value = '';
    print("  - selectedDepartment reset to empty.");
    selectedDepartmentId.value = '';
    print("  - selectedDepartmentId reset to empty.");
    isAvalableScan.value = false;
    print("  - isAvalableScan set to false.");
    isShowingDetail.value = false;
    print("  - isShowingDetail set to false.");

    if (inventoryData.isNotEmpty) {
      bool changed = false;
      for (int i = 0; i < inventoryData.length; i++) {
        if (inventoryData[i].length > 6 && inventoryData[i][6] != '0') {
          inventoryData[i][6] = '0';
          changed = true;
        }
      }
      if (changed) {
        inventoryData.refresh();
        print(
          "  - 'Scanned' column in inventoryData reset to '0'. UI refreshed.",
        );
      } else {
        print(
          "  - 'Scanned' column in inventoryData was already '0' or inventoryData is empty.",
        );
      }
    } else {
      print("  - inventoryData is empty, nothing to reset in it.");
    }

    if (lastSizeList.isNotEmpty) {
      lastSizeList.clear();
      print("  - lastSizeList (matched RFIDs) cleared.");
    } else {
      print("  - lastSizeList was already empty.");
    }

    print("✅ Clear action completed.");
    Get.snackbar("Thông báo", "Đã đặt lại số lượng đã quét và danh sách thẻ.");
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

  Future<void> getDepartment() async {
    if (companyName == null || companyName!.isEmpty) {
      print("⚠️ Company name is not set. Cannot fetch departments.");
      return;
    }
    try {
      final data = {"companyName": companyName};
      print("Fetching departments with data: $data from $baseUrl");
      var response = await ApiService(
        baseUrl,
      ).post('/phom/getDepartment', data);
      if (response.statusCode == 200) {
        final List<dynamic>? jsonArray = response.data?["data"]?["jsonArray"];
        if (jsonArray != null) {
          final List<String> departments = [];
          final Map<String, String> map = {};
          for (var e in jsonArray) {
            String depName = e['DepName'].toString();
            String id = e['ID'].toString();
            departments.add(depName);
            map[depName] = id;
          }
          departmentList.assignAll(departments);
          depNameToIdMap.clear();
          depNameToIdMap.addAll(map);

          if (departments.isNotEmpty) {
            selectedDepartment.value = departments.first;
          }
          print("✅ Departments fetched: $departments");
        } else {
          print("⚠️ Department data is null or not in expected format.");
          departmentList.clear();
          depNameToIdMap.clear();
        }
      } else {
        print(
          '❌ Lỗi khi lấy danh sách đơn vị: ${response.statusCode} - ${response.data}',
        );
        departmentList.clear();
        depNameToIdMap.clear();
      }
    } catch (e) {
      print('❌ Lỗi khi lấy danh sách đơn vị: $e');
      departmentList.clear();
      depNameToIdMap.clear();
    }
  }

  String convertDate(String inputDate) {
    // dd/MM/yyyy to yyyy-MM-dd
    final parts = inputDate.split('/');
    if (parts.length != 3)
      return inputDate; // Return original if format is wrong
    final day = parts[0].padLeft(2, '0');
    final month = parts[1].padLeft(2, '0');
    final year = parts[2];
    return "$year-$month-$day";
  }

  Future<void> sendEPCToServer(String epc) async {
    if (companyName == null || companyName!.isEmpty) {
      print("⚠️ Company name is not set. Cannot send EPC to server.");
      return;
    }
    final data = {"companyName": companyName, "RFID": epc};
    print("data for getphomrfid: $data");

    try {
      final response = await ApiService(
        baseUrl,
      ).post('/phom/getphomrfid', data);

      if (response.statusCode == 200) {
        final List<dynamic>? jsonList = response.data?['data'];
        print("jsonList from getphomrfid: $jsonList");

        if (jsonList == null || jsonList.isEmpty) {
          print("⚠️ Không có dữ liệu chi tiết cho EPC: $epc");
          return;
        }
        bool inventoryUpdated = false;
        for (var item in jsonList) {
          if (item is Map<String, dynamic>) {
            String? epcLastMatNo = item['LastMatNo']?.toString();
            String rfidFromApi = item["RFID"]?.toString() ?? epc;
            String? epcLastSize = item['LastSize']?.toString().trim();

            if (epcLastMatNo == null || epcLastSize == null) {
              print(
                "⚠️ Dữ liệu từ API cho EPC $rfidFromApi thiếu LastMatNo hoặc LastSize: $item",
              );
              continue;
            }
            print(
              "🔎 Đang tìm kiếm trong inventoryData cho MatNo: $epcLastMatNo, Size: $epcLastSize (RFID: $rfidFromApi)",
            );

            for (int i = 0; i < inventoryData.length; i++) {
              List<String> inventoryRow = inventoryData[i];
              if (inventoryRow.length < 7) {
                print(
                  "⚠️ inventoryRow at index $i is too short: $inventoryRow",
                );
                continue;
              }
              String inventoryMatNo = inventoryRow[2];
              String inventorySize = inventoryRow[4].trim();
              String inventoryDepID = inventoryRow[1];

              if (inventoryMatNo == epcLastMatNo &&
                  inventorySize == epcLastSize) {
                print(
                  "✅ Tìm thấy dòng khớp tại index $i: $inventoryRow cho RFID: $rfidFromApi",
                );

                if (!lastSizeList.contains(rfidFromApi)) {
                  int maxAllowedScans = int.tryParse(inventoryRow[5]) ?? 0;
                  if (lastSizeList.length < maxAllowedScans) {
                    lastSizeList.add(rfidFromApi);
                  }
                }
                final String currentDate = DateFormat(
                  'yyyy-MM-dd',
                ).format(DateTime.now());

                int currentScannedCount = int.tryParse(inventoryRow[6]) ?? 0;
                int maxAllowedScans = int.tryParse(inventoryRow[5]) ?? 0;

                if (currentScannedCount < maxAllowedScans) {
                  currentScannedCount++;
                  bool alreadyExistsInDetails = scannedRfidDetailsList.any(
                    (detail) =>
                        detail["RFID"] == rfidFromApi &&
                        detail["LastMatNo"] == epcLastMatNo &&
                        detail["DepID"] == inventoryDepID,
                  );

                  if (!alreadyExistsInDetails) {
                    scannedRfidDetailsList.add({
                      "DepID": inventoryDepID,
                      "LastMatNo": epcLastMatNo,
                      "ScanDate": currentDate,
                      "RFID": rfidFromApi,
                    });
                    print(
                      "📝 Added to scannedRfidDetailsList: DepID: $inventoryDepID, LastMatNo: $epcLastMatNo, ScanDate: $currentDate, RFID: $rfidFromApi",
                    );
                  } else {
                    print(
                      "ℹ️ RFID $rfidFromApi for MatNo $epcLastMatNo, DepID $inventoryDepID already in scannedRfidDetailsList. Scanned count will still increment.",
                    );
                  }
                  inventoryRow[6] = currentScannedCount.toString();
                  inventoryUpdated = true;
                  print(
                    "📊 Cập nhật số lượng quét cho dòng $i (MatNo: $inventoryMatNo, Size: $inventorySize) thành: $currentScannedCount / $maxAllowedScans",
                  );
                } else {
                  print(
                    "⚠️ Số lượng quét cho dòng $i (MatNo: $inventoryMatNo, Size: $inventorySize) đã đạt tối đa: $currentScannedCount / $maxAllowedScans. Không tăng thêm.",
                  );
                }
              }
            }
          }
        }

        if (inventoryUpdated) {
          inventoryData.refresh();
          print("🔄 UI inventoryData đã được refresh.");
        }
        print('📋 lastSizeList content: $lastSizeList');
        print('📋 scannedRfidDetailsList content: $scannedRfidDetailsList');
        print('✅ Dữ liệu trả về từ getphomrfid: ${response.data}');
      } else {
        print(
          '❌ Gửi EPC thất bại (getphomrfid): ${response.statusCode}, ${response.data}',
        );
      }
    } catch (e, stackTrace) {
      print('❌ Lỗi khi gửi EPC lên server (getphomrfid): $e');
      print('Stack trace: $stackTrace');
    }
  }

  String? ID_BILL = ''; // To store ID_Bill if needed for other operations
  Future<void> onSearch() async {
    if (companyName == null || companyName!.isEmpty) {
      Get.snackbar('Lỗi', 'Thông tin công ty không có sẵn.');
      return;
    }
    if (dateController.text.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng chọn ngày.');
      return;
    }
    // Add more validation for other fields if necessary (DepID, UserID, LastMatNo)

    isLoading.value = true;
    isAvalableScan.value = false; // Reset before search
    inventoryData.clear();
    lastSizeList.clear();
    scannedRfidDetailsList.clear(); // Clear details from previous search
    LastSum.value = 0; // Reset total sum
    idBillFromSearch = null;
    final newSelectedDate = convertDate(dateController.text);
    final searchData = {
      "companyName": companyName,
      // "DateBorrow": newSelectedDate,
      // "DepID": selectedDepartmentId.value,
      "ID_BILL": bill_br_id.text, // Ensure this is filled or handle if optional
      // "LastMatNo":
      //     selectedCodePhom
      //         .value, // Ensure this is selected or handle if optional
    };
    print("Searching with data: $searchData from $baseUrl/phom/layphieumuon");

    try {
      var response = await ApiService(
        baseUrl,
      ).post('/phom/layphieumuon', searchData);
      // print('response from layphieumuon: ${response.data["statusCode"]}');
      if (response.data["statusCode"] == 200) {
        if (!response.data["infoBill"]["isConfirm"]) {
          Get.snackbar(
            backgroundColor: Colors.yellow,
            'Thông báo',
            'Phiếu mượn chưa được xác nhận. Vui lòng kiểm tra lại.',
          );
          print('ℹ️ Phiếu mượn chưa được xác nhận.');
          isAvalableScan.value = false;
          isLoading.value = false;
          return;
        }
        if (response.data["infoBill"]["StateLastBill"]) {
          Get.snackbar(
            backgroundColor: Colors.greenAccent,
            'Thông báo',
            '✅Đơn đã được hoàn tất. Không thể quét thêm.',
          );
          print('ℹ️ Đơn đã được hoàn tất. Không thể quét thêm.');
          isAvalableScan.value = false;
          isLoading.value = false;
          return;
        }
        final responseBody = response.data;
        print(responseBody);
        if (responseBody != null &&
            responseBody["data"] != null &&
            responseBody["data"]["rowCount"] != null &&
            responseBody["data"]["rowCount"] > 0) {
          isAvalableScan.value = true;
          final List<dynamic> jsonArray = responseBody["data"]["jsonArray"];
          // print("✅ Data received from layphieumuon: $jsonArray");

          idBillFromSearch = jsonArray[0]['ID_bill']?.toString();
          print('idbillFromSearch: $idBillFromSearch');
          for (var item in jsonArray) {
            if (item is Map<String, dynamic>) {
              LastSum.value +=
                  int.tryParse(item['LastSum']?.toString() ?? '0') ?? 0;
              inventoryData.add([
                item['ID_bill']?.toString() ?? '',
                item['DepID']?.toString() ?? '',
                item['LastMatNo']?.toString() ?? '',
                item['LastName']?.toString() ?? '',
                item['LastSize']?.toString() ?? '',
                item['LastSum']?.toString() ?? '0', // Expected quantity
                '0', // Scanned quantity, initialized to 0
              ]);
            }
          }
          print("📦 inventoryData populated. Total LastSum: ${LastSum.value}");
        } else {
          Get.snackbar(
            'Thông báo',
            'Không tìm thấy dữ liệu cho tiêu chí đã chọn.',
          );
          print(
            'ℹ️ Không có dữ liệu từ layphieumuon hoặc rowCount là 0. Response: $responseBody',
          );
        }
      } else {
        Get.snackbar('Lỗi ❌', '${response.data['message']}');
        print(
          '❌ Lỗi khi lấy dữ liệu từ layphieumuon: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi khi tìm kiếm: $e');
      print('❌ Lỗi khi gọi API layphieumuon: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getLastMatNo() async {
    if (companyName == null || companyName!.isEmpty) {
      print("⚠️ Company name is not set. Cannot fetch LastMatNo.");
      return;
    }
    try {
      final data = {"companyName": companyName};
      print("Fetching LastMatNo with data: $data from $baseUrl");
      var response = await ApiService(baseUrl).post('/phom/getLastMatNo', data);
      if (response.statusCode == 200) {
        final List<dynamic>? jsonArray = response.data?["data"]?["jsonArray"];
        if (jsonArray != null) {
          final List<String> codes =
              jsonArray.map((e) => e['LastMatNo'].toString()).toList();
          codePhomList.assignAll(codes);
          if (codes.isNotEmpty) {}
          print("✅ LastMatNo fetched: $codes");
        } else {
          print("⚠️ LastMatNo data is null or not in expected format.");
          codePhomList.clear();
        }
      } else {
        print(
          '❌ Lỗi khi lấy danh sách mặt nợ: ${response.statusCode} - ${response.data}',
        );
        codePhomList.clear();
      }
    } catch (e) {
      print('❌ Lỗi khi lấy danh sách mặt nợ: $e');
      codePhomList.clear();
    }
  }

  void checkAndAddNewTags(List<String> newTags) {
    if (!isAvalableScan.value) {
      print("⚠️ Scanning is not available. Search for items first.");
      Get.snackbar("Thông báo", "Vui lòng tìm kiếm phiếu mượn trước khi quét.");
      return;
    }

    final uniqueNewTags =
        newTags.where((tag) {
          bool alreadyProcessed = listTagRFID.contains(tag);
          if (!alreadyProcessed) {
            listTagRFID.add(tag);
          }
          return !alreadyProcessed;
        }).toList();

    if (uniqueNewTags.isNotEmpty) {
      print('✅ Thêm tag mới vào listTagRFID và gửi server: $uniqueNewTags');
      for (String epc in uniqueNewTags) {
        sendEPCToServer(epc); // This will try to match against inventoryData
      }
    } else {
      print(
        'ℹ️ Các thẻ này đã được quét trong phiên này: $newTags. Sẽ được xử lý lại để cập nhật số lượng nếu cần.',
      );
      for (String epc in newTags) {
        // Process all received tags, even if "duplicates" from reader
        sendEPCToServer(epc);
      }
    }
    print(
      '📋 Tổng số thẻ đã quét trong phiên (listTagRFID): ${listTagRFID.length} - $listTagRFID',
    );
  }

  Future<void> onScanMultipleTags() async {
    if (!isAvalableScan.value) {
      Get.snackbar('Cảnh báo', 'Vui lòng thực hiện tìm kiếm trước khi quét.');
      print("⚠️ Attempted to scan but isAvalableScan is false.");
      return;
    }
    if (isLoading.value) {
      print("⚠️ Scan already in progress.");
      return;
    }

    isLoading.value = true;

    try {
      // Using scanSingleTagMultiple suggests it might read multiple unique tags in one go.
      final tags = await RFIDService.scanSingleTagMultiple(
        timeout: Duration(milliseconds: 200), // Increased timeout slightly
      );

      if (tags.isNotEmpty) {
        print('📡 Thẻ RFID quét được: $tags');
        checkAndAddNewTags(tags);
      } else {
        // No new tags found in this scan attempt. This is normal.
        print('ℹ️ Không có thẻ RFID mới nào được tìm thấy trong lần quét này.');
        // Get.snackbar('Thông báo', 'Không tìm thấy thẻ mới.'); // Avoid too many snackbars
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi khi quét: $e');
      print('❌ Lỗi khi quét nhiều thẻ: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() async {
    super.onInit();
    isLoading.value = true; // Show loading indicator during initialization

    user = await _getuserUseCase.getUser();

    if (user == null ||
        user!.companyName == null ||
        user!.companyName!.isEmpty) {
      print(
        '❌ User hoặc CompanyName null/empty, không thể khởi tạo LendGiveController',
      );
      Get.snackbar('Lỗi', 'Không tìm thấy thông tin người dùng hoặc công ty.');
      isLoading.value = false;
      // Optionally, navigate away or prevent further actions
      // Get.offAllNamed('/login'); // Example
      return;
    }

    companyName = user!.companyName;
    print(
      '✅ LendGiveController Initialized. CompanyName: $companyName, UserID: ${user!.userId}',
    );

    final today = DateTime.now();
    dateController.text =
        "${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}";

    // Initialize dropdown lists and other data that depends on companyName
    await Future.wait([
      _connectRFID(),
      getDepartment(), // Depends on companyName
      getLastMatNo(), // Depends on companyName
    ]);

    isLoading.value = false;
  }

  @override
  void onClose() {
    sumController.dispose();
    dateController.dispose();
    bill_br_id.dispose();
    // userNameController.dispose(); // If used
    // rfidController.dispose(); // If used
    tableScrollController.dispose();
    _disconnectRFID(); // Ensure RFID is disconnected
    super.onClose();
    print("LendGiveController closed and resources disposed.");
  }
}
