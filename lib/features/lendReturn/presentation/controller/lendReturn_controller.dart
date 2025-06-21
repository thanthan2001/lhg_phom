// LendReturnController.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/services/dio.api.service.dart';
import 'package:lhg_phom/core/services/models/user/domain/usecase/get_user_use_case.dart';
import 'package:lhg_phom/core/services/models/user/model/user_model.dart';
import 'package:lhg_phom/core/services/rfid_service.dart';

class LendReturnController extends GetxController {
  var isAvalableScan = false.obs;

  final RxList<String> listTagRFID = <String>[].obs;
  final listFinalRFID = [];
  var ID_Return = ''.obs;
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  final sumController = TextEditingController();
  final dateController = TextEditingController();
  final bill_br_id = TextEditingController();
  final userNameController = TextEditingController();
  final rfidController = TextEditingController();
  late String? companyName;
  var totalCount = 0.obs;
  final isScanning = false.obs;

  var ScannedCount = 0.obs;

  final tableScrollController = ScrollController();
  final GetuserUseCase _getuserUseCase;
  LendReturnController(this._getuserUseCase);
  UserModel? user;

  // State
  final RxList<Map<String, dynamic>> searchResult =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> returnBillData =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> LastDataBill =
      <Map<String, dynamic>>[].obs;

  final isLoading = false.obs;
  final selectedCodePhom = ''.obs;
  final selectedDepartment = ''.obs;
  final isLeftSide = true.obs;
  final isShowingDetail = false.obs;
  final scrollProgress = 0.0.obs;
  var selectedRowIndex = Rx<int?>(null);
  var databill = {}.obs;
  RxString selectedDepartmentId = ''.obs;

  // Dropdown data
  final RxList<String> codePhomList =
      <String>['AHGH', 'JHSG', 'ADTUH', 'KJAKJA', 'AHGGS', 'UHBV'].obs;
  final RxList<String> departmentList = <String>[].obs;
  final Map<String, String> depNameToIdMap = {};

  // Table data (bảng inventory cũ)
  final inventoryData =
      <List<String>>[
        ['36', '300', '2', '4', '2'],
        ['37', '2000', '4', '3', '3'],
        ['38', '1000', '5', '2', '2'],
        ['39', '1000', '5', '2', '2'],
      ].obs;

  void onScan() {
    isShowingDetail.value = true;
  }

  Future<void> onClear() async {
    print("Clearing...");
    searchResult.clear();
    returnBillData.clear();
    listTagRFID.clear();
    ScannedCount.value = 0;
    isAvalableScan.value = false;
    listFinalRFID.clear();
    bill_br_id.clear();
    userNameController.clear();

    final today = DateTime.now();
    dateController.text =
        "${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}";
    if (departmentList.isNotEmpty) {
      selectedDepartment.value = departmentList.first;
    } else {
      selectedDepartment.value = "";
    }
    if (codePhomList.isNotEmpty) {
      // selectedCodePhom.value = codePhomList.first;
    } else {
      selectedCodePhom.value = "";
    }
  }

  Future<void> onStop() async {
    print("Stopping RFID scan (if applicable)...");

    await RFIDService.stopScan();
    isLoading.value = false;
  }

  Future<void> onFinish() async {
    final data = {"companyName": companyName, "ID_BILL": bill_br_id.text};
    final result =
        listFinalRFID.map((rfid) {
          return {...data, "RFID": rfid};
        }).toList();

    if (LastDataBill.isNotEmpty && searchResult.isNotEmpty) {
      LastDataBill[0]['TotalScanOut'] = searchResult[0]['TotalScanOut'];
    }

    final updatedLastDataBillList =
        LastDataBill.map((item) {
          return {...item, "payloadDetails": result};
        }).toList();
    print('lastDataBill: ${updatedLastDataBillList}');

    try {
      final response = await ApiService(baseUrl).post(
        '/phom/submitReturnPhom',
        {"companyName": companyName, "data": updatedLastDataBillList},
      );
      if (response.data["statusCode"] == 200) {
        print("✅ Trả phiếu mượn thành công: ${response.data}");
        Get.snackbar(
          "✅Hoàn tất",
          "Trả phiếu mượn thành công.",
          backgroundColor: Colors.green.withOpacity(0.8),
        );
        await onClear();
      } else {
        print("❌ Lỗi khi trả phiếu mượn: ${response.data}");
        Get.snackbar(
          backgroundColor: Colors.red,
          "❌Lỗi",
          "${response.data["message"]}",
        );
      }
    } catch (e) {
      print('Exception ${e}');
    }
  }

  Future<void> checkAndAddNewTags(List<String> newTagsFromReader) async {
    if (!isAvalableScan.value) {
      Get.snackbar("Thông báo", "Vui lòng tìm kiếm phiếu mượn trước khi quét.");
      return;
    }

    int newTagsActuallySentToServer = 0;
    for (String epc in newTagsFromReader) {
      if (!listTagRFID.contains(epc)) {
        print('🆕 Tag mới cần xử lý: $epc.');
        await sendEPCToServer(epc);
        listTagRFID.add(epc);
        newTagsActuallySentToServer++;
      } else {
        print('🔁 Tag đã được xử lý trước đó: $epc. Bỏ qua.');
      }
    }

    if (newTagsActuallySentToServer > 0) {
      print('✅ Đã gửi $newTagsActuallySentToServer tag mới lên server.');
    } else if (newTagsFromReader.isNotEmpty) {
      print(
        'ℹ️ Tất cả các tag (${newTagsFromReader.length}) trong lần quét này đã được xử lý trước đó.',
      );
    }

    print(
      '📋 Danh sách tổng các tag DUY NHẤT đã được đưa vào hàng đợi xử lý trong phiên: ${listTagRFID.length} - ${listTagRFID.toList()}',
    );
  }

  Future<void> sendEPCToServer(String epc) async {
    if (listTagRFID.contains(epc)) {
      print(
        "🔁 Tag '$epc' đã được gửi đi, đang chờ phản hồi hoặc đã xử lý. Bỏ qua.",
      );
      return;
    }
    listTagRFID.add(epc);

    totalCount.value = listTagRFID.length;

    final data = {"companyName": companyName, "RFID": epc};
    print("📡 Gửi EPC lên server: $epc");

    try {
      final response = await ApiService(
        baseUrl,
      ).post('/phom/checkRFIDinBrBill', data);

      if (response.data["statusCode"] == 200) {
        print("✅ Gửi EPC '$epc' thành công. Phản hồi: ${response.data}");

        ScannedCount.value++;
        if (!listFinalRFID.contains(epc)) {
          listFinalRFID.add(epc);
        }
        print(
          "✅ Tag '$epc' hợp lệ. ScannedCount hiện tại: ${ScannedCount.value}. ListFinal: ${listFinalRFID.length}",
        );
      } else {
        print(
          "⚠️ Server từ chối EPC '$epc'. Phản hồi: ${response.data['message']}",
        );
        Get.snackbar(
          "Thẻ không hợp lệ",
          "Thẻ $epc không thuộc phiếu mượn này.",
          backgroundColor: Colors.orange.withOpacity(0.8),
        );
      }
    } catch (e) {
      print("❌ Lỗi mạng khi gửi EPC '$epc': $e");
      Get.snackbar('Lỗi mạng', 'Gửi EPC $epc thất bại: $e');

      listTagRFID.remove(epc);

      totalCount.value = listTagRFID.length;
      print("🔁 Đã xóa '$epc' khỏi listTagRFID do lỗi mạng, cho phép thử lại.");
    }
  }

  Future<void> onScanMultipleTags() async {
    if (!isAvalableScan.value) {
      Get.snackbar('Cảnh báo', 'Vui lòng thực hiện tìm kiếm trước khi quét.');
      print("⚠️ Attempted to scan but isAvalableScan is false.");
      return;
    }

    if (isScanning.value) {
      print("⚠️ Đã đang trong quá trình quét liên tục.");
      return;
    }

    isLoading.value = true;
    isScanning.value = true;
    print("▶️ Bắt đầu quét liên tục nhiều thẻ...");

    try {
      await RFIDService.scanContinuous((epc) {
        if (!isScanning.value) return;

        sendEPCToServer(epc);
      });

      print("▶️ scanContinuous đã được khởi động.");
    } catch (e) {
      print('❌ Lỗi khi bắt đầu quét liên tục: $e');
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi khi quét: $e');
      isScanning.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  String convertDate(String inputDate) {
    final parts = inputDate.split('/');
    if (parts.length != 3) return inputDate;
    final day = parts[0].padLeft(2, '0');
    final month = parts[1].padLeft(2, '0');
    final year = parts[2];
    return "$year-$month-$day";
  }

  Future<void> onSearch() async {
    isLoading.value = true;
    searchResult.clear();
    returnBillData.clear();
    listTagRFID.clear();
    ScannedCount.value = 0;
    isAvalableScan.value = false;

    final data = {
      "companyName": companyName,
      // "DepID": selectedDepartmentId.value,
      // "LastMatNo": selectedCodePhom.value,
      "ID_BILL": bill_br_id.text,
      // "DateBorrow": convertDate(dateController.text),
    };
    print("Searching with data: $data from $baseUrl");
    try {
      final response = await ApiService(baseUrl).post('/phom/getOldBill', data);
      // print(response.statusCode);
      if (response.data["statusCode"] == 200) {
        print(response.data);
        final List<dynamic>? resultsFromApi = response.data?["data"]["results"];
        final List<dynamic>? returnBillFromApi =
            response.data?["data"]["getReturnBill"];

        final List<dynamic>? lastbillresult =
            response.data?["data"]["lastdatabill"];
        if (lastbillresult != null && lastbillresult.isNotEmpty) {
          LastDataBill.assignAll(lastbillresult.cast<Map<String, dynamic>>());
        }
        if (resultsFromApi != null && resultsFromApi.isNotEmpty) {
          searchResult.assignAll(resultsFromApi.cast<Map<String, dynamic>>());
          isAvalableScan.value = true;
        } else {
          isAvalableScan.value = false;
          Get.snackbar("Thông báo", "Không tìm thấy phiếu mượn phù hợp.");
        }

        if (returnBillFromApi != null && returnBillFromApi.isNotEmpty) {
          ID_Return.value = returnBillFromApi[0]['ID_Return'].toString();
          returnBillData.assignAll(
            returnBillFromApi.cast<Map<String, dynamic>>(),
          );
        }
        print(
          "✅ Tìm kiếm thành công. Số lượng kết quả: ${LastDataBill.toList()}",
        );
        print("✅ Controller Search result: ${searchResult.toList()}");
        print("✅ Controller returnBillData: ${returnBillData.toList()}");
      } else {
        print('❌ Lỗi khi tìm kiếm: ${response.statusCode} - ${response.data}');
        isAvalableScan.value = false;
        Get.snackbar('Lỗi', 'Tìm kiếm thất bại: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Lỗi khi tìm kiếm: $e');
      isAvalableScan.value = false;
      Get.snackbar('Lỗi', 'Tìm kiếm thất bại: $e');
    } finally {
      isLoading.value = false;
    }
  }

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

  Future<void> onStopRead() async {
    try {
      await RFIDService.stopScan();
      isScanning.value = false;
      isLoading.value = false;
      print('⏹️ Dừng quét RFID');
    } catch (e) {
      print('❌ Lỗi dừng quét: $e');
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi khi dừng quét: $e');
    }
  }

  @override
  void onInit() async {
    super.onInit();
    isLoading.value = true;

    user = await _getuserUseCase.getUser();
    RFIDService.setOnHardwareScan(() {
      print(
        '🔔 Nút cứng đã được bấm! Trạng thái quét hiện tại: ${isScanning.value}',
      );

      if (isScanning.value) {
        onStopRead();
      } else {
        onScanMultipleTags();
      }
    });
    if (user == null ||
        user!.companyName == null ||
        user!.companyName!.isEmpty) {
      print(
        '❌ User hoặc CompanyName null/empty, không thể khởi tạo LendReturnController',
      );
      Get.snackbar('Lỗi', 'Không tìm thấy thông tin người dùng hoặc công ty.');
      isLoading.value = false;
      return;
    }

    companyName = user!.companyName;
    bill_br_id.text = user!.userId ?? '';
    userNameController.text = user!.userName ?? '';

    print(
      '✅ LendReturnController Initialized. CompanyName: $companyName, UserID: ${user!.userId}',
    );

    final today = DateTime.now();
    dateController.text =
        "${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}";

    // _connectRFID();

    await Future.wait([getDepartment(), getLastMatNo()]);

    isLoading.value = false;
  }

  @override
  void onClose() {
    // RFIDService.disconnect();
    sumController.dispose();
    dateController.dispose();
    bill_br_id.dispose();
    userNameController.dispose();
    rfidController.dispose();
    tableScrollController.dispose();
    super.onClose();
  }
}
