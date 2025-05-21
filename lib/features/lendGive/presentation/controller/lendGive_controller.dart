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
  final List<String> scannedEPCs = []; // danh sách lưu các epc đã quét
  Timer? clearEpcTimer; // timer để xóa mảng sau 10 phút
  // Text Controllers
  final sumController = TextEditingController();
  final dateController = TextEditingController();
  final userIDController = TextEditingController();
  final userNameController = TextEditingController();
  final rfidController = TextEditingController();
  late String? companyName;
  // Scroll Controllers
  final tableScrollController = ScrollController();
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
  // Dropdown data
  final codePhomList = ['AHGH', 'JHSG', 'ADTUH', 'KJAKJA', 'AHGGS', 'UHBV'];
  final departmentList = ['IT', 'HR', 'K3', 'SEA'];
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

  final scanDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  late Map<String, dynamic> data = {
    "companyName": companyName,
    "ScanDate": scanDate,
    "DepID": selectedDepartment.value,
    "StateScan": "0",
  };
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

  void onFinish() {
    Get.back();
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

    // 1. Xóa danh sách các tag đã quét từ đầu đọc RFID
    listTagRFID.clear();
    print("  - listTagRFID cleared.");

    // 2. Xóa danh sách chi tiết EPC từ server (nếu bạn dùng nó)
    epcDataTable.clear();
    print("  - epcDataTable cleared.");

    // 3. Reset cột "Scanned" (index 6) về '0' cho tất cả các dòng hiện có trong inventoryData
    if (inventoryData.isNotEmpty) {
      bool changed = false;
      for (int i = 0; i < inventoryData.length; i++) {
        // Kiểm tra xem dòng có đủ phần tử và cột "Scanned" có khác '0' không
        if (inventoryData[i].length > 6 && inventoryData[i][6] != '0') {
          inventoryData[i][6] = '0'; // Reset cột "Scanned"
          changed = true;
        }
      }
      if (changed) {
        inventoryData
            .refresh(); // Cần thiết để UI cập nhật thay đổi trong inventoryData
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

    // 4. Xóa danh sách các RFID đã khớp với inventoryData (lastSizeList)
    if (lastSizeList.isNotEmpty) {
      lastSizeList.clear();
      print("  - lastSizeList (matched RFIDs) cleared.");
    } else {
      print("  - lastSizeList was already empty.");
    }

    // 5. Cân nhắc reset các giá trị khác nếu cần thiết cho hành động "Clear" này:
    // Ví dụ:
    // isAvalableScan.value = false; // Nếu việc clear này làm cho việc quét không còn hợp lệ
    // LastSum.value = 0; // Nếu LastSum nên phản ánh tổng số lượng chưa quét
    // selectedRowIndex.value = null;

    // update(); // `inventoryData.refresh()` đã xử lý việc cập nhật UI cho bảng.
    // `update()` có thể không cần thiết nếu các state khác bạn muốn reset đều là Rx.
    // Nếu có các non-Rx state mà UI đang lắng nghe và cần cập nhật, thì hãy dùng.

    print("✅ Clear action completed.");
    Get.snackbar("Thông báo", "Đã đặt lại số lượng đã quét và danh sách thẻ.");
  }

  // Future<void> sendEPCToServer(String epc) async {
  //   final data = {"companyName": companyName, "RFID": epc};
  //   print("data: $data");
  //   try {
  //     final response = await ApiService(
  //       baseUrl,
  //     ).post('/phom/getphomrfid', data);

  //     if (response.statusCode == 200) {
  //       final List<dynamic> jsonList = response.data['data'];
  //       print(jsonList);
  //       for (var item in jsonList) {
  //         if (item is Map<String, dynamic>) {
  //           epcDataTable.add(item); // hoặc xử lý tùy logic
  //         }
  //       }
  //       print('✅ Dữ liệu trả về: ${response.data}');
  //     } else {
  //       print('❌ Gửi EPC thất bại: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('❌ Lỗi khi gửi EPC lên server: $e');
  //   }
  // }

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

  Future<void> getDepartment() async {
    try {
      final data = {"companyName": companyName};
      print(baseUrl);
      var response = await ApiService(
        baseUrl,
      ).post('/phom/getDepartment', data);
      if (response.statusCode == 200) {
        final List<dynamic> jsonArray = response.data["data"]["jsonArray"];
        final List<String> departments =
            jsonArray.map((e) => e['ID'].toString()).toList();

        departmentList.assignAll(departments);

        if (departments.isNotEmpty) {
          selectedDepartment.value = departments.first;
        }
      }
    } catch (e) {
      print('Lỗi khi lấy danh sách đơn vị: $e');
    }
  }

  String convertDate(String inputDate) {
    final parts = inputDate.split('/');
    final day = parts[0].padLeft(2, '0');
    final month = parts[1].padLeft(2, '0');
    final year = parts[2];
    return "$year-$month-$day";
  }
  // List<Map<String, dynamic>> epcDataTable = [];
  // List<List<String>> inventoryData = [];

  // Future<void> sendEPCToServer(String epc) async {
  //   final data = {"companyName": companyName, "RFID": epc};
  //   print("data: $data");

  //   try {
  //     final response = await ApiService(
  //       baseUrl,
  //     ).post('/phom/getphomrfid', data);

  //     if (response.statusCode == 200) {
  //       final List<dynamic> jsonList = response.data['data'];
  //       print("jsonList: $jsonList");
  //       for (var item in jsonList) {
  //         if (item is Map<String, dynamic>) {
  //           epcDataTable.add(item); // Lưu dữ liệu RFID
  //         }
  //       }
  //       print('✅ Dữ liệu trả về: ${response.data}');
  //     } else {
  //       print('❌ Gửi EPC thất bại: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('❌ Lỗi khi gửi EPC lên server: $e');
  //   }
  // }
  Future<void> sendEPCToServer(String epc) async {
    final data = {"companyName": companyName, "RFID": epc};
    print("data for getphomrfid: $data"); // Log dữ liệu gửi đi

    try {
      final response = await ApiService(
        baseUrl,
      ).post('/phom/getphomrfid', data);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data['data'];
        print("jsonList from getphomrfid: $jsonList"); // Log dữ liệu nhận được

        if (jsonList.isEmpty) {
          print("⚠️ Không có dữ liệu chi tiết cho EPC: $epc");
          return;
        }

        bool inventoryUpdated =
            false; // Cờ để theo dõi nếu inventoryData đã được cập nhật

        for (var item in jsonList) {
          // API có thể trả về một list, thường thì chỉ 1 item cho 1 EPC
          if (item is Map<String, dynamic>) {
            // epcDataTable.add(item); // Bạn vẫn có thể thêm vào epcDataTable nếu cần dùng ở đâu đó

            String? epcLastMatNo = item['LastMatNo']?.toString();
            String RFID = item["RFID"];
            String? epcLastSize =
                item['LastSize']?.toString().trim(); // Trim để đảm bảo khớp

            if (epcLastMatNo == null || epcLastSize == null) {
              print(
                "⚠️ Dữ liệu từ API cho EPC $epc thiếu LastMatNo hoặc LastSize: $item",
              );
              continue; // Bỏ qua item này nếu thiếu thông tin quan trọng
            }

            print(
              "🔎 Đang tìm kiếm trong inventoryData cho MatNo: $epcLastMatNo, Size: $epcLastSize",
            );

            // Duyệt qua inventoryData để tìm dòng khớp
            for (int i = 0; i < inventoryData.length; i++) {
              List<String> inventoryRow = inventoryData[i];
              // Giả sử cấu trúc của inventoryRow khớp với 'headers'
              // headers: ['ID Bill', 'Dep ID', 'Last Mat No', 'Last Name', 'Last Size', 'Last Sum', 'Scanned']
              // Indices:     0          1             2              3              4             5           6
              String inventoryMatNo = inventoryRow[2];
              String inventorySize =
                  inventoryRow[4].trim(); // Trim để đảm bảo khớp

              if (inventoryMatNo == epcLastMatNo &&
                  inventorySize == epcLastSize) {
                print("✅ Tìm thấy dòng khớp tại index $i: $inventoryRow");
                lastSizeList.add(RFID);
                int currentScannedCount = int.tryParse(inventoryRow[6]) ?? 0;
                currentScannedCount++;
                inventoryRow[6] = currentScannedCount.toString();

                // Quan trọng: Để GetX nhận biết sự thay đổi trong một item của RxList<List<String>>
                // bạn cần gán lại item đó hoặc gọi refresh() trên RxList.
                // inventoryData[i] = inventoryRow; // Cách 1: Gán lại (ít hiệu quả hơn nếu nhiều thay đổi)
                // Hoặc đơn giản là sau vòng lặp gọi inventoryData.refresh()
                inventoryUpdated = true;
                print(
                  "📊 Cập nhật số lượng quét cho dòng $i thành: $currentScannedCount",
                );
                // Nếu bạn cho rằng một EPC chỉ khớp với MỘT dòng duy nhất trong inventoryData,
                // bạn có thể `break;` ở đây để tối ưu.
                // break;
              }
            }
          }
        }
        print('last listttttttttttttttttttttttttttttttttttt ${lastSizeList}');
        if (inventoryUpdated) {
          inventoryData
              .refresh(); // Báo cho GetX cập nhật UI lắng nghe inventoryData
          print("🔄 UI inventoryData đã được refresh.");
        }

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

  Future<void> onSearch() async {
    final newSelectedDate = convertDate(dateController.text);
    final data = {
      "companyName": companyName,
      "DateBorrow": newSelectedDate,
      "DepID": selectedDepartment.value,
      "UserID": userIDController.text,
      "LastMatNo": selectedCodePhom.value,
    };
    print(data);
    print(data["DateBorrow"]);

    var response = await ApiService(baseUrl).post('/phom/layphieumuon', data);
    if (response.statusCode == 200 && response.data["data"]["rowCount"] != 0) {
      isAvalableScan.value = true;
      print(response);
      final List<dynamic> jsonArray = response.data["data"]["jsonArray"];
      print(jsonArray);
      inventoryData.clear();
      LastSum.value = 0;
      data["ID_bill"] = response.data["data"]["jsonArray"][0]['ID_bill'];
      // ID_Bill.value =
      //     response.data["data"]["jsonArray"][0]['ID_bill'].toString();
      for (var item in jsonArray) {
        LastSum.value += int.tryParse(item['LastSum']?.toString() ?? '0') ?? 0;
        inventoryData.add([
          item['ID_bill']?.toString() ?? '',
          item['DepID']?.toString() ?? '',
          item['LastMatNo']?.toString() ?? '',
          item['LastName']?.toString() ?? '',
          item['LastSize']?.toString().trim() ?? '',
          item['LastSum']?.toString() ?? '',
          '0',
        ]);
      }
      print(lastSizeList);
    } else {
      Get.snackbar('Lỗi', 'Không thể lấy dữ liệu');
    }
  }

  Future<void> getLastMatNo() async {
    try {
      final data = {"companyName": companyName};
      var response = await ApiService(baseUrl).post('/phom/getLastMatNo', data);
      if (response.statusCode == 200) {
        final List<dynamic> jsonArray = response.data["data"]["jsonArray"];
        final List<String> codePhom =
            jsonArray.map((e) => e['LastMatNo'].toString()).toList();

        codePhomList.assignAll(codePhom);

        if (codePhom.isNotEmpty) {
          selectedDepartment.value = codePhom.first;
        }
      }
    } catch (e) {
      print('Lỗi khi lấy danh sách mặt nợ: $e');
    }
  }

  //check exict tag in listTagRFID
  void checkAndAddNewTags(List<String> newTags) {
    final uniqueTags =
        newTags.where((tag) => !listTagRFID.contains(tag)).toList();

    if (uniqueTags.isNotEmpty) {
      listTagRFID.addAll(uniqueTags);
      for (String epc in uniqueTags) {
        sendEPCToServer(epc);
      }

      print('✅ Thêm tag mới & gửi server: $uniqueTags');
    } else {
      print('⚠️ Tất cả tag đã tồn tại, không thêm mới');
    }
  }

  Future<void> onScanMultipleTags() async {
    isLoading.value = true;
    if (isAvalableScan.value == false) {
      return null;
    }
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

        print('📋 Tổng listTagRFID: $listTagRFID + ${listTagRFID.length}');
        print("listTagRFID: $listTagRFID");
      } else {
        Get.snackbar('Lỗi', 'Không tìm thấy thẻ nào');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> onSave()async{
  //   for(item to)
  // }

  @override
  void onInit() async {
    super.onInit();

    // Lấy user từ usecase
    user = await _getuserUseCase.getUser();

    if (user == null) {
      print('❌ User null, không thể khởi tạo LendGiveController');
      Get.snackbar('Lỗi', 'Không tìm thấy thông tin người dùng');
      return;
    }

    companyName = user!.companyName;
    print('✅ CompanyName: $companyName');

    final today = DateTime.now();
    dateController.text = "${today.day}/${today.month}/${today.year}";

    await _connectRFID();
    await getDepartment();
    await getLastMatNo();
  }

  @override
  void onClose() {
    sumController.dispose();
    dateController.dispose();
    userIDController.dispose();
    rfidController.dispose();
    tableScrollController.dispose();
    super.onClose();
    _disconnectRFID();
  }
}
