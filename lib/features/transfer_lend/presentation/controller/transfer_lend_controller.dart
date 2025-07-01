import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/services/dio.api.service.dart';

import 'package:intl/intl.dart';

import '../../../../core/services/models/user/domain/usecase/get_user_use_case.dart';
import '../../../../core/services/models/user/model/user_model.dart';
import '../../../../core/services/rfid_service.dart';

class TransferLendController extends GetxController {
  final GetuserUseCase _getuserUseCase;
  final isLoading = false.obs;
  List<String> lastSizeList = [];

  TransferLendController(this._getuserUseCase);
  final departmentList = <String>[].obs;
  final Map<String, String> depNameToIdMap = {};
  final Map<String, String> depIdToNameMap = {};

  final selectedDepartment = ''.obs;
  RxString selectedDepartmentId = ''.obs;

  final selectedDepartmentReceiver = ''.obs;
  final selectedDepartmentReceiverId = ''.obs;

  final bill_br_id = TextEditingController();
  var isAvalableScan = false.obs;
  var inventoryData = <List<String>>[].obs;
  String? idBillFromSearch;
  var listTagRFID = [].obs;
  final RxList<Map<String, dynamic>> scannedRfidDetailsList =
      <Map<String, dynamic>>[].obs;

  late String? companyName;
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  UserModel? user;
  final LastSum = 0.obs;
  var isShowDep = false.obs;
  final List<String> headers = [
    'ID Bill',
    'Dep ID',
    'Last Mat No',
    'Last Name',
    'Last Size',
    'Last Sum',
    'Scanned',
  ];

  @override
  void onInit() async {
    super.onInit();
    isLoading.value = true;

    user = await _getuserUseCase.getUser();

    if (user == null ||
        user!.companyName == null ||
        user!.companyName!.isEmpty) {
      print(
        '❌ User hoặc CompanyName null/empty, không thể khởi tạo Controller',
      );
      Get.snackbar('Lỗi', 'Không tìm thấy thông tin người dùng hoặc công ty.');
      isLoading.value = false;
      return;
    }

    companyName = user!.companyName;
    print(
      '✅ Controller Initialized. CompanyName: $companyName, UserID: ${user!.userId}',
    );

    await Future.wait([
      // _connectRFID(),
      getDepartment(),
    ]);

    isLoading.value = false;
  }

  Future<void> onFinish() async {
    user = await _getuserUseCase.getUser();
    final String? companyName = user?.companyName;
    final String? userId = user?.userId;

    final new_bill_return =
        inventoryData.map((item) {
          return {
            "ID_BILL": item[0],
            "DepID": item[1],
            "LastMatNo": item[2],
            "LastName": item[3],
            "LastSize": item[4],
            "LastSum": double.parse(item[5]) - double.parse(item[6]),
          };
        }).toList();
    final new_bill_borrow = {
      "RFIDDetails":
          scannedRfidDetailsList.map((item) {
            return {
              "DepID": selectedDepartmentReceiverId.value,
              "LastMatNo": item["LastMatNo"],
              "ScanDate": item["ScanDate"],
              "RFID": item["RFID"],
            };
          }).toList(),
      "scannedRfidDetailsList":
          inventoryData.map((item) {
            return {
              "ID_BILL": item[0],
              "DepID": selectedDepartmentReceiverId.value,
              "LastMatNo": item[2],
              "LastName": item[3],
              "LastSize": item[4],
              "LastSum": double.parse(item[6]),
            };
          }).toList(),
    };

    final data = {
      "companyName": companyName,
      "userId": userId,
      "BILL_RETURN": new_bill_return,
      "BILL_BORROW": new_bill_borrow,
    };
    print("Data to send on finish: $data");
    try {
      var response = await ApiService(
        baseUrl,
      ).post('/phom/submitTransfer', data);
      if (response.data["statusCode"] == 200) {
        print("✅ Finish successful: ${response.data}");
        Get.snackbar('Thông báo', 'Hoàn tất thành công.');
        onClear();
      } else {
        print('❌ Lỗi khi hoàn tất: ${response.statusCode} - ${response.data}');
        Get.snackbar('Lỗi ❌', 'Không thể hoàn tất: ${response.data}');
      }
    } catch (e) {
      print('❌ Lỗi khi gọi API finish: $e');
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi khi hoàn tất: $e');
    }
  }

  Future<void> getDepartment() async {
    if (companyName == null || companyName!.isEmpty) {
      print("⚠️ Company name is not set. Cannot fetch departments.");
      return;
    }
    try {
      final data = {"companyName": companyName};
      print(
        "Fetching departments with data: $data from $baseUrl/phom/getDepartment",
      );
      var response = await ApiService(
        baseUrl,
      ).post('/phom/getDepartment', data);
      if (response.statusCode == 200) {
        final List<dynamic>? jsonArray = response.data?["data"]?["jsonArray"];
        if (jsonArray != null) {
          final List<String> departmentsNames = [];
          final Map<String, String> nameToId = {};
          final Map<String, String> idToName = {};
          for (var e in jsonArray) {
            String depName = e['DepName'].toString();
            String id = e['ID'].toString();
            departmentsNames.add(depName);
            nameToId[depName] = id;
            idToName[id] = depName;
          }

          departmentList.assignAll(departmentsNames);
          depNameToIdMap.clear();
          depNameToIdMap.addAll(nameToId);
          depIdToNameMap.clear();
          depIdToNameMap.addAll(idToName);

          if (departmentsNames.isNotEmpty) {
            if (selectedDepartment.value.isEmpty) {
              selectedDepartment.value = departmentsNames.first;
              selectedDepartmentId.value =
                  depNameToIdMap[departmentsNames.first] ?? '';
            }
            if (selectedDepartmentReceiver.value.isEmpty) {
              selectedDepartmentReceiver.value = departmentsNames.first;
              selectedDepartmentReceiverId.value =
                  depNameToIdMap[departmentsNames.first] ?? '';
            }
          }
          print("✅ Departments fetched: $departmentsNames");
          print("✅ depNameToIdMap: $depNameToIdMap");
          print("✅ depIdToNameMap: $depIdToNameMap");
        } else {
          print("⚠️ Department data is null or not in expected format.");
          departmentList.clear();
          depNameToIdMap.clear();
          depIdToNameMap.clear();
        }
      } else {
        print(
          '❌ Lỗi khi lấy danh sách đơn vị: ${response.statusCode} - ${response.data}',
        );
        departmentList.clear();
        depNameToIdMap.clear();
        depIdToNameMap.clear();
      }
    } catch (e) {
      print('❌ Lỗi khi lấy danh sách đơn vị: $e');
      departmentList.clear();
      depNameToIdMap.clear();
      depIdToNameMap.clear();
    }
  }

  Future<void> onSearch() async {
    if (companyName == null || companyName!.isEmpty) {
      Get.snackbar('Lỗi', 'Thông tin công ty không có sẵn.');
      return;
    }

    isLoading.value = true;
    isAvalableScan.value = false;
    inventoryData.clear();
    idBillFromSearch = null;
    LastSum.value = 0;

    final searchData = {"companyName": companyName, "ID_BILL": bill_br_id.text};
    print("Searching with data: $searchData from $baseUrl/phom/layphieumuon");

    try {
      var response = await ApiService(
        baseUrl,
      ).post('/phom/layphieumuon', searchData);

      if (response.data["statusCode"] == 200) {
        final responseBody = response.data;
        print(
          "API Response (layphieumuon): $responseBody",
        ); // Log the full response

        if (!responseBody["infoBill"]["isConfirm"]) {
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

        isShowDep.value = true; // Show department dropdowns section

        if (responseBody["data"] != null &&
            responseBody["data"]["jsonArray"] != null &&
            responseBody["data"]["rowCount"] != null &&
            responseBody["data"]["rowCount"] > 0) {
          isAvalableScan.value = true;
          final List<dynamic> jsonArray = responseBody["data"]["jsonArray"];
          idBillFromSearch = jsonArray[0]['ID_bill']?.toString();
          print('idbillFromSearch: $idBillFromSearch');

          // --- START: CẬP NHẬT ĐƠN VỊ CHUYỂN TỪ API ---
          final infoBill = responseBody["infoBill"];
          if (infoBill != null && infoBill is Map<String, dynamic>) {
            String? apiDepId = infoBill['DepID']?.toString();
            if (apiDepId != null && apiDepId.isNotEmpty) {
              // Tìm tên đơn vị từ ID bằng depIdToNameMap
              String? departmentName = depIdToNameMap[apiDepId];

              if (departmentName != null) {
                selectedDepartment.value = departmentName;
                selectedDepartmentId.value = apiDepId;
                print(
                  "🔄 Đơn vị chuyển được cập nhật từ API: Tên='${selectedDepartment.value}', ID='${selectedDepartmentId.value}'",
                );
              } else {
                // Nếu không tìm thấy tên, có thể hiển thị ID hoặc một giá trị mặc định
                selectedDepartment.value =
                    apiDepId; // Hiển thị ID nếu không có tên
                selectedDepartmentId.value = apiDepId;
                print(
                  "⚠️ Không tìm thấy tên cho DepID '$apiDepId' (Đơn vị chuyển). Hiển thị ID: '${selectedDepartment.value}'",
                );
              }
            } else {
              print(
                "⚠️ DepID trong infoBill rỗng hoặc null. Không cập nhật đơn vị chuyển.",
              );
              // Optionally reset to default if preferred
              // if (departmentList.isNotEmpty) {
              //   selectedDepartment.value = departmentList.first;
              //   selectedDepartmentId.value = depNameToIdMap[departmentList.first] ?? '';
              // } else {
              //   selectedDepartment.value = '';
              //   selectedDepartmentId.value = '';
              // }
            }
          } else {
            print(
              "⚠️ infoBill is null hoặc không phải Map. Không cập nhật đơn vị chuyển.",
            );
          }
          // --- END: CẬP NHẬT ĐƠN VỊ CHUYỂN TỪ API ---

          for (var item in jsonArray) {
            if (item is Map<String, dynamic>) {
              LastSum.value +=
                  int.tryParse(item['LastSum']?.toString() ?? '0') ?? 0;
              inventoryData.add([
                item['ID_bill']?.toString() ?? '',
                item['DepID']?.toString() ?? '', // This is item's DepID
                item['LastMatNo']?.toString() ?? '',
                item['LastName']?.toString() ?? '',
                item['LastSize']?.toString() ?? '',
                item['LastSum']?.toString() ?? '0',
                '0',
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
          // Optionally reset department dropdowns if no data found
          // if (departmentList.isNotEmpty) {
          //   selectedDepartment.value = departmentList.first;
          //   selectedDepartmentId.value = depNameToIdMap[departmentList.first] ?? '';
          //   selectedDepartmentReceiver.value = departmentList.first;
          //   selectedDepartmentReceiverId.value = depNameToIdMap[departmentList.first] ?? '';
          // } else {
          //   selectedDepartment.value = '';
          //   selectedDepartmentId.value = '';
          //   selectedDepartmentReceiver.value = '';
          //   selectedDepartmentReceiverId.value = '';
          // }
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

  Future<void> onClear() async {
    print("Clear action triggered");
    LastSum.value = 0;
    bill_br_id.clear();
    listTagRFID.clear();
    scannedRfidDetailsList.clear();
    inventoryData.clear();

    if (departmentList.isNotEmpty) {
      selectedDepartment.value = departmentList.first;
      selectedDepartmentId.value = depNameToIdMap[departmentList.first] ?? '';

      selectedDepartmentReceiver.value = departmentList.first;
      selectedDepartmentReceiverId.value =
          depNameToIdMap[departmentList.first] ?? '';
    } else {
      selectedDepartment.value = '';
      selectedDepartmentId.value = '';
      selectedDepartmentReceiver.value = '';
      selectedDepartmentReceiverId.value = '';
    }

    isAvalableScan.value = false;
    isShowDep.value = false;

    if (lastSizeList.isNotEmpty) {
      lastSizeList.clear();
    }

    print("✅ Clear action completed.");
    Get.snackbar("Thông báo", "Đã đặt lại các trường và danh sách thẻ.");
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
        sendEPCToServer(epc);
      }
    } else {
      print(
        'ℹ️ Các thẻ này đã được quét trong phiên này: $newTags. Sẽ được xử lý lại để cập nhật số lượng nếu cần.',
      );
      for (String epc in newTags) {
        sendEPCToServer(epc);
      }
    }
    print(
      '📋 Tổng số thẻ đã quét trong phiên (listTagRFID): ${listTagRFID.length} - $listTagRFID',
    );
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
                  inventorySize == epcLastSize &&
                  inventoryDepID == selectedDepartmentId.value) {
                print(
                  "✅ Tìm thấy dòng khớp tại index $i: $inventoryRow cho RFID: $rfidFromApi (DepID: $inventoryDepID)",
                );

                bool alreadyScannedForThisItem = scannedRfidDetailsList.any(
                  (detail) =>
                      detail["RFID"] == rfidFromApi &&
                      detail["LastMatNo"] == epcLastMatNo &&
                      detail["DepID"] == inventoryDepID,
                );

                if (alreadyScannedForThisItem) {
                  print(
                    "ℹ️ RFID $rfidFromApi đã được quét cho item này (MatNo: $epcLastMatNo, DepID: $inventoryDepID). Không tăng số lượng.",
                  );
                  continue;
                }

                final String currentDate = DateFormat(
                  'yyyy-MM-dd',
                ).format(DateTime.now());

                int currentScannedCount = int.tryParse(inventoryRow[6]) ?? 0;
                int maxAllowedScans = int.tryParse(inventoryRow[5]) ?? 0;

                if (currentScannedCount < maxAllowedScans) {
                  currentScannedCount++;
                  inventoryRow[6] = currentScannedCount.toString();
                  inventoryUpdated = true;

                  scannedRfidDetailsList.add({
                    "DepID": inventoryDepID,
                    "LastMatNo": epcLastMatNo,
                    "ScanDate": currentDate,
                    "RFID": rfidFromApi,
                  });
                  print(
                    "📝 Added to scannedRfidDetailsList: DepID: $inventoryDepID, LastMatNo: $epcLastMatNo, ScanDate: $currentDate, RFID: $rfidFromApi",
                  );
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
      final tags = await RFIDService.scanSingleTagMultiple(
        timeout: Duration(milliseconds: 300),
      );

      if (tags.isNotEmpty) {
        print('📡 Thẻ RFID quét được: $tags');
        checkAndAddNewTags(tags);
      } else {
        print('ℹ️ Không có thẻ RFID mới nào được tìm thấy trong lần quét này.');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi khi quét: $e');
      print('❌ Lỗi khi quét nhiều thẻ: $e');
    } finally {
      isLoading.value = false;
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
}
