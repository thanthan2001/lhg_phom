import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lhg_phom/core/services/models/user/domain/usecase/get_user_use_case.dart';
import 'package:lhg_phom/core/services/models/user/model/user_model.dart';
// import 'dart:convert'; // Not explicitly used in this version, can be removed if not needed elsewhere

import 'package:lhg_phom/core/services/rfid_service.dart';

import '../../../../core/services/dio.api.service.dart';

class LendGiveController extends GetxController {
  final GetuserUseCase _getuserUseCase;
  LendGiveController(this._getuserUseCase);
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  // final List<String> scannedEPCs = []; // danh sách lưu các epc đã quét - This seems unused, consider removing if not planned for use
  // Timer? clearEpcTimer; // timer để xóa mảng sau 10 phút - This seems unused, consider removing if not planned for use

  // Text Controllers
  final sumController = TextEditingController();
  final dateController = TextEditingController();
  final userIDController = TextEditingController();
  final userNameController =
      TextEditingController(); // Seems unused, consider removing
  final rfidController =
      TextEditingController(); // Seems unused, consider removing
  late String? companyName;
  String? idBillFromSearch;
  // Scroll Controllers
  final tableScrollController = ScrollController();

  var listTagRFID = [].obs; // Stores unique EPCs scanned by the RFID reader
  List<String> lastSizeList =
      []; // Stores RFIDs that have matched an item in inventoryData

  // State
  final isLoading = false.obs;
  final selectedCodePhom = ''.obs;
  final selectedDepartment = ''.obs;
  final isLeftSide = true.obs; // Seems unused, consider removing
  final isShowingDetail = false.obs;
  final scrollProgress = 0.0.obs; // Seems unused, consider removing
  var selectedRowIndex = Rx<int?>(null);
  final LastSum = 0.obs; // Total sum from layphieumuon API
  UserModel? user;

  // Dropdown data
  final codePhomList = <String>[].obs; // Initialize as empty, populated by API
  final departmentList =
      <String>[].obs; // Initialize as empty, populated by API

  final List<String> headers = [
    'ID Bill',
    'Dep ID',
    'Last Mat No',
    'Last Name',
    'Last Size',
    'Last Sum',
    'Scanned',
  ];

  final epcDataTable =
      <Map<String, dynamic>>[]
          .obs; // Stores raw data from getphomrfid API for each EPC

  // New variable to store DepID, LastMatNo, ScanDate, RFID
  final RxList<Map<String, dynamic>> scannedRfidDetailsList =
      <Map<String, dynamic>>[].obs;

  // This `data` map seems to be initialized with `companyName` before `companyName` is set in `onInit`.
  // It also uses `selectedDepartment.value` which might be empty initially.
  // Consider initializing or updating this map when `companyName` and `selectedDepartment` are available.
  // For now, I'll comment out its direct initialization and you can decide how to best manage it.
  /*
  final scanDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  late Map<String, dynamic> data = {
    "companyName": companyName,
    "ScanDate": scanDate,
    "DepID": selectedDepartment.value,
    "StateScan": "0",
  };
  */
  Map<String, dynamic> get currentApiDataPayload {
    final scanDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return {
      "companyName": companyName,
      "ScanDate": scanDate,
      "DepID": selectedDepartment.value,
      "StateScan": "0", // Or dynamically set this based on actual state
      // Add other relevant fields if this map is used for API calls like 'onSave'
    };
  }

  // Table data
  var inventoryData =
      <List<String>>[]
          .obs; // Data from layphieumuon API, displayed in the table
  var isAvalableScan = false.obs;

  // Logic
  void onScan() {
    // This function currently only sets isShowingDetail.
    // The actual scanning happens in onScanMultipleTags.
    // If isShowingDetail controls UI visibility related to scanning, this is fine.
    isShowingDetail.value = true;
  }

  Future<void> onStop() async {
    await RFIDService.stopScan();
    // Optionally, update isLoading or other states
    // isLoading.value = false;
  }

  Future<void> onFinish() async {
    if (scannedRfidDetailsList.isEmpty) {
      Get.snackbar("Thông báo", "Không có dữ liệu quét chi tiết để gửi đi.");
      print("ℹ️ onFinish called but scannedRfidDetailsList is empty.");
      return;
    }

    if (user == null || companyName == null || companyName!.isEmpty) {
      Get.snackbar(
        "Lỗi",
        "Thông tin người dùng hoặc công ty không đầy đủ để hoàn tất.",
      );
      print("❌ Cannot finish: User or companyName is null/empty.");
      return;
    }

    isLoading.value = true;
    int successCount = 0;
    int failureCount = 0;
    List<String> errorMessages = [];

    // Common data for all requests in this batch
    final String commonCompanyName = companyName!;
    final String commonUserID = user!.userId!;
    final String commonDateBorrow = convertDate(
      dateController.text,
    ); // Date of the loan slip

    String apiEndpoint =
        '/phom/saveBill'; // As per user's previous request for the endpoint name

    print(
      "🚀 Bắt đầu gửi ${scannedRfidDetailsList.length} mục quét tuần tự...",
    );
    for (var itemDetail in scannedRfidDetailsList) {
      final Map<String, dynamic> individualPayload = {
        "companyName": commonCompanyName,
        "StateScan": 0,
        "ID_BILL":
            idBillFromSearch, // ID_Bill associated with this specific scanned item
        "DepID": itemDetail["DepID"],
        "ScanDate":
            itemDetail["ScanDate"], // The actual date this RFID was scanned and processed
        "RFID": itemDetail["RFID"],
      };

      print("🔗 Endpoint: $baseUrl$apiEndpoint (POST)");

      try {
        // IMPORTANT: Using '/phom/layphieumuon' for a POST to submit/finish a scan is unconventional.
        // This endpoint name suggests fetching data. Please verify with your backend team.
        final response = await ApiService(
          baseUrl,
        ).post(apiEndpoint, individualPayload);

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Check for typical success codes
          print(
            "✅ Mục ${itemDetail['RFID']} đã được gửi. Response: ${response.data}",
          );
          successCount++;
        } else {
          String errorMessage =
              response.data?['message']?.toString() ??
              response.statusMessage ??
              "Lỗi không xác định";
          print(
            "❌ Lỗi gửi mục ${itemDetail['RFID']}: ${response.statusCode} - Data: ${response.data}",
          );
          failureCount++;
          errorMessages.add(
            "RFID ${itemDetail['RFID']}: Lỗi ${response.statusCode} - $errorMessage",
          );
        }
      } catch (e) {
        print("❌ Exception khi gửi mục ${itemDetail['RFID']}: $e");
        failureCount++;
        errorMessages.add("RFID ${itemDetail['RFID']}: Exception - $e");
      }
    } // End of loop

    isLoading.value = false;
    print(
      "🏁 Hoàn tất gửi tuần tự. Thành công: $successCount, Thất bại: $failureCount.",
    );

    if (failureCount == 0 && successCount > 0) {
      Get.snackbar("Thành công", "$successCount mục đã được gửi thành công!");
      await onClear(); // Clear data from the current screen after successful submission of all items
      Get.back(); // Navigate to the previous screen
    } else if (successCount > 0 && failureCount > 0) {
      Get.snackbar(
        "Hoàn tất một phần",
        "$successCount mục thành công, $failureCount mục thất bại.",
        duration: Duration(seconds: 5),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      // Decide if you want to clear/navigate back or allow user to retry failed items.
      // For now, let's assume we clear if at least some were successful.
      // await onClear();
      // Get.back();
    } else if (failureCount > 0 && successCount == 0) {
      Get.snackbar(
        "Thất bại",
        "Tất cả $failureCount mục không gửi được. Vui lòng thử lại.",
        duration: Duration(seconds: 5),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      if (errorMessages.isNotEmpty) {
        print("📝 Chi tiết lỗi:\n${errorMessages.join('\n')}");
        // Optionally show a dialog with errorMessages
      }
    } else {
      // This case (successCount = 0, failureCount = 0) should not happen if scannedRfidDetailsList was not empty.
      Get.snackbar("Thông báo", "Không có mục nào được xử lý.");
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

      // Allow selecting today or future dates.
      // If you only want to allow today, change to:
      // return inputDate.year == now.year && inputDate.month == now.month && inputDate.day == now.day;
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

    listTagRFID.clear();
    print("  - listTagRFID cleared.");

    epcDataTable.clear();
    print("  - epcDataTable cleared.");

    scannedRfidDetailsList.clear(); // Clear the new list
    print("  - scannedRfidDetailsList cleared.");

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

    // Reset LastSum based on its original meaning (total from 'layphieumuon')
    // If onSearch is called again, LastSum will be repopulated.
    // If LastSum is meant to be the sum of *scanned* items, this logic needs to change.
    // For now, assuming it's the total sum from the initial search.
    // If you want to reflect the *currently displayed* total sum from inventoryData[5]
    // you might recalculate it here, or reset it to 0 if clearing means no items.
    // LastSum.value = 0; // Or re-fetch if necessary

    // selectedRowIndex.value = null; // Reset selected row if applicable
    // sumController.clear(); // Clear sum text field if it reflects scanned sum

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
          final List<String> departments =
              jsonArray.map((e) => e['ID'].toString()).toList();
          departmentList.assignAll(departments);
          if (departments.isNotEmpty) {
            selectedDepartment.value = departments.first;
          }
          print("✅ Departments fetched: $departments");
        } else {
          print("⚠️ Department data is null or not in expected format.");
          departmentList.clear();
        }
      } else {
        print(
          '❌ Lỗi khi lấy danh sách đơn vị: ${response.statusCode} - ${response.data}',
        );
        departmentList.clear();
      }
    } catch (e) {
      print('❌ Lỗi khi lấy danh sách đơn vị: $e');
      departmentList.clear();
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
            // epcDataTable.add(item); // Add to raw EPC data if needed for other purposes

            String? epcLastMatNo = item['LastMatNo']?.toString();
            String rfidFromApi =
                item["RFID"]?.toString() ?? epc; // Use epc as fallback
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

                // Add RFID to lastSizeList (tracks RFIDs that resulted in an inventory update)
                if (!lastSizeList.contains(rfidFromApi)) {
                  // Add only if not already there, to avoid duplicates if one RFID is scanned multiple times quickly
                  lastSizeList.add(rfidFromApi);
                }

                // Populate scannedRfidDetailsList
                final String currentDate = DateFormat(
                  'yyyy-MM-dd',
                ).format(DateTime.now());
                // Check if this specific combination of DepID, LastMatNo, and RFID already exists
                // to prevent adding duplicates to scannedRfidDetailsList if the same tag is processed multiple times
                // for the same inventory item due to rapid re-scans before UI updates.
                // This check assumes one RFID tag corresponds to one physical item.
                bool alreadyExistsInDetails = scannedRfidDetailsList.any(
                  (detail) =>
                      detail["RFID"] == rfidFromApi &&
                      detail["LastMatNo"] == epcLastMatNo &&
                      detail["DepID"] == inventoryDepID,
                );

                if (!alreadyExistsInDetails) {
                  // Only add if it's a "new" scan for this item detail
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

                int currentScannedCount = int.tryParse(inventoryRow[6]) ?? 0;
                int maxAllowedScans =
                    int.tryParse(inventoryRow[5]) ?? 0; // LastSum for this row

                if (currentScannedCount < maxAllowedScans) {
                  currentScannedCount++;
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
                // break; // If one RFID can only match one line in inventoryData
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
      "DateBorrow": newSelectedDate,
      "DepID": selectedDepartment.value,
      "UserID":
          userIDController.text, // Ensure this is filled or handle if optional
      "LastMatNo":
          selectedCodePhom
              .value, // Ensure this is selected or handle if optional
    };
    print("Searching with data: $searchData from $baseUrl/phom/layphieumuon");

    try {
      var response = await ApiService(
        baseUrl,
      ).post('/phom/layphieumuon', searchData);
      if (response.statusCode == 200) {
        final responseBody = response.data;
        if (responseBody != null &&
            responseBody["data"] != null &&
            responseBody["data"]["rowCount"] != null &&
            responseBody["data"]["rowCount"] > 0) {
          isAvalableScan.value = true;
          final List<dynamic> jsonArray = responseBody["data"]["jsonArray"];
          print("✅ Data received from layphieumuon: $jsonArray");

          // String? commonIdBill; // To store ID_bill if it's common for all items in this search
          // if (jsonArray.isNotEmpty) {
          //   commonIdBill = jsonArray[0]['ID_bill']?.toString();
          //   // If ID_bill is needed for 'data' map later, assign it here
          //   // data["ID_bill"] = commonIdBill;
          // }
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
                item['LastSize']?.toString().trim() ?? '',
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
        Get.snackbar('Lỗi', 'Không thể lấy dữ liệu: ${response.statusCode}');
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
          if (codes.isNotEmpty) {
            // Do not override selectedDepartment here. It should be selected by user or default from getDepartment.
            // selectedCodePhom.value = codes.first; // Optionally set a default for codePhom
          }
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
          // A tag is considered "new" for processing if it's not in listTagRFID yet.
          // listTagRFID stores all unique tags encountered in the current session.
          bool alreadyProcessed = listTagRFID.contains(tag);
          if (!alreadyProcessed) {
            listTagRFID.add(
              tag,
            ); // Add to the session's master list of scanned tags
          }
          return !alreadyProcessed; // Process only if it's truly new for this session
        }).toList();

    if (uniqueNewTags.isNotEmpty) {
      // listTagRFID.addAll(uniqueNewTags); // Already added above
      print('✅ Thêm tag mới vào listTagRFID và gửi server: $uniqueNewTags');
      for (String epc in uniqueNewTags) {
        sendEPCToServer(epc); // This will try to match against inventoryData
      }
    } else {
      // This means all tags in `newTags` were already in `listTagRFID`.
      // However, we might still need to re-process them if their previous scan didn't match
      // or if the user is re-scanning to ensure items are counted.
      // The current logic in `sendEPCToServer` handles incrementing counts.
      // So, it's generally okay to send them again.
      // For better performance, if a tag is already in listTagRFID AND its corresponding item is fully scanned,
      // you might choose to ignore it. But this adds complexity.
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
    // user details are already available via this.user, no need to fetch again unless they can change mid-session
    // final user = await _getuserUseCase.getUser(); // This is already done in onInit
    print('Initiating scan. User: ${this.user?.userId}, Company: $companyName');

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

  // Future<void> onSave() async {
  //   // 1. Collect all data from `scannedRfidDetailsList`
  //   // 2. Potentially aggregate it or combine with `inventoryData` (e.g., total scanned counts per item)
  //   // 3. Construct the payload for your save API endpoint.
  //   // Example:
  //   if (scannedRfidDetailsList.isEmpty && inventoryData.every((row) => (int.tryParse(row[6]) ?? 0) == 0)) {
  //     Get.snackbar("Thông báo", "Không có gì để lưu. Chưa có thẻ nào được quét và khớp.");
  //     return;
  //   }

  //   // This is a placeholder for what your API expects.
  //   // You might need ID_Bill (ensure it's available, perhaps from onSearch response)
  //   // and the list of scanned items.
  //   final String scanDateForSave = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  //   // String? idBill = inventoryData.isNotEmpty ? inventoryData.first[0] : null; // Example to get ID_Bill

  //   List<Map<String, dynamic>> itemsToSave = [];
  //   for (var row in inventoryData) {
  //     int scannedCount = int.tryParse(row[6]) ?? 0;
  //     if (scannedCount > 0) {
  //       itemsToSave.add({
  //         "ID_bill": row[0],
  //         "DepID": row[1],
  //         "LastMatNo": row[2],
  //         "LastSize": row[4],
  //         "ScannedQuantity": scannedCount,
  //         // Add RFIDs for this item if your API needs them
  //         "RFIDs": scannedRfidDetailsList
  //             .where((detail) => detail["LastMatNo"] == row[2] && detail["DepID"] == row[1] && detail["LastSize"] == row[4] /* approximation, API might give better link */)
  //             .map((detail) => detail["RFID"])
  //             .toList(),
  //       });
  //     }
  //   }
  //   if (itemsToSave.isEmpty) {
  //        Get.snackbar("Thông báo", "Không có mặt hàng nào được quét.");
  //        return;
  //   }

  //   final saveData = {
  //     "companyName": companyName,
  //     "UserID": user?.userId,
  //     "ScanDateTime": scanDateForSave,
  //     "Items": itemsToSave, // List of items with their scanned quantities and RFIDs
  //     // "StateScan": "1", // Or whatever state indicates completion
  //   };

  //   print("💾 Dữ liệu gửi đi để lưu: ${jsonEncode(saveData)}"); // Using jsonEncode for readability

  //   isLoading.value = true;
  //   try {
  //     // Replace with your actual save API endpoint
  //     // final response = await ApiService(baseUrl).post('/phom/saveScanResults', saveData);
  //     // if (response.statusCode == 200 || response.statusCode == 201) {
  //     //   Get.snackbar("Thành công", "Đã lưu kết quả quét.");
  //     //   onClear(); // Optionally clear after successful save
  //     //   Get.back(); // Navigate back
  //     // } else {
  //     //   Get.snackbar("Lỗi", "Lưu thất bại: ${response.statusCode} - ${response.data}");
  //     // }
  //     await Future.delayed(Duration(seconds: 1)); // Simulate API call
  //     Get.snackbar("Thành công", "Đã lưu (Mô phỏng).");
  //     print("✅ Kết quả quét đã được lưu (Mô phỏng).");
  //     // onClear(); // Clear after save
  //     // Get.back();

  //   } catch (e) {
  //     Get.snackbar("Lỗi", "Lỗi khi lưu: $e");
  //     print("❌ Lỗi khi lưu kết quả quét: $e");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

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
    userIDController.dispose();
    // userNameController.dispose(); // If used
    // rfidController.dispose(); // If used
    tableScrollController.dispose();
    _disconnectRFID(); // Ensure RFID is disconnected
    super.onClose();
    print("LendGiveController closed and resources disposed.");
  }
}
