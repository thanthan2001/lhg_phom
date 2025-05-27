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
  // listTagRFID sẽ lưu trữ các tag DUY NHẤT đã được xử lý (gửi đi server) trong phiên này.
  // Đảm bảo nó là RxList<String> để có thể observe nếu cần.
  final RxList<String> listTagRFID = <String>[].obs;
  final listFinalRFID = [];
  var ID_Return = ''.obs;
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  // Text Controllers
  final sumController = TextEditingController();
  final dateController = TextEditingController();
  final userIDController = TextEditingController();
  final userNameController = TextEditingController();
  final rfidController = TextEditingController();
  late String? companyName;

  // ScannedCount sẽ đếm số lần sendEPCToServer được gọi và thành công
  var ScannedCount = 0.obs;
  // var listRFID = []; // Biến này không được sử dụng, có thể xóa nếu không có mục đích khác

  // Scroll Controllers
  final tableScrollController = ScrollController();
  final GetuserUseCase _getuserUseCase;
  LendReturnController(this._getuserUseCase);
  UserModel? user;

  // State
  final RxList<Map<String, dynamic>> searchResult =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> returnBillData =
      <Map<String, dynamic>>[].obs;

  final isLoading = false.obs; // Dùng cho onSearch và onScanMultipleTags
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

  // Logic
  void onScan() {
    // Hàm này có vẻ không liên quan trực tiếp đến logic RFID scan chính?
    isShowingDetail.value = true;
  }

  Future<void> onClear() async {
    print("Clearing...");
    searchResult.clear();
    returnBillData.clear();
    listTagRFID.clear(); // QUAN TRỌNG: Xóa danh sách tag đã xử lý khi clear
    ScannedCount.value = 0; // Reset bộ đếm
    isAvalableScan.value = false; // Không cho phép scan nữa sau khi clear
    listFinalRFID.clear();
    userIDController.clear();
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
      // Giữ nguyên hoặc reset selectedCodePhom
      // selectedCodePhom.value = codePhomList.first;
    } else {
      selectedCodePhom.value = "";
    }
  }

  Future<void> onStop() async {
    print("Stopping RFID scan (if applicable)...");
    // Nếu RFIDService.scanSingleTagMultiple chạy trong vòng lặp bên onScanMultipleTags,
    // bạn cần một biến cờ để dừng vòng lặp đó.
    // Ví dụ: isScanningContinuously.value = false;
    // Hoặc nếu RFIDService có hàm stop:
    await RFIDService.stopScan(); // Giả sử có hàm này
    isLoading.value = false; // Nếu isLoading được dùng để chỉ trạng thái quét
  }

  Future<void> onFinish() async {
    print(listFinalRFID);
    final getDate = DateTime.now();
    print(getDate);
    final data = {
      "companyName": companyName,
      "ID_BILL": returnBillData[0]["ID_BILL"],
    };
    try {
      for (var item in listFinalRFID) {
        final payload = Map<String, dynamic>.from(data);
        payload["RFID"] = item; // hoặc bất kỳ key nào bạn cần
        print(payload);
        final response = await ApiService(
          baseUrl,
        ).post('/phom/submitReturnPhom', payload);
        if (response.data["statusCode"] == 200) {
          print(response.data["message"]);
          Get.snackbar("Thông báo", "✅Gửi dữ liệu trả về thành công.");
          // await onClear();
        } else {
          Get.snackbar(
            "Lỗi",
            response.data["message"],
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      print('Exception ${e}');
    }
    // Get.back();
  }

  // isValidDate và convertDate giữ nguyên

  // **** SỬA ĐỔI HÀM NÀY THEO YÊU CẦU ****
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
          "✅ Tag '$epc' được tính. ScannedCount hiện tại: ${ScannedCount.value}",
        );
      }
    } catch (e) {
      print("❌ Lỗi khi gửi EPC '$epc' đến server: $e");
      Get.snackbar('Lỗi', 'Gửi EPC $epc thất bại: $e');
      listTagRFID.remove(epc);
      print(
        "🔁 Đã xóa '$epc' khỏi listTagRFID do gửi thất bại, cho phép thử lại.",
      );
    }
  }

  // onScanMultipleTags giữ nguyên như bạn cung cấp
  Future<void> onScanMultipleTags() async {
    if (!isAvalableScan.value) {
      Get.snackbar('Cảnh báo', 'Vui lòng thực hiện tìm kiếm trước khi quét.');
      print("⚠️ Attempted to scan but isAvalableScan is false.");
      return;
    }
    if (isLoading.value) {
      // Giữ nguyên isLoading cho trạng thái quét
      print("⚠️ Scan already in progress.");
      return;
    }

    isLoading.value = true;
    print('🚀 Initiating scan. User: ${user?.userId}, Company: $companyName');

    try {
      final tags = await RFIDService.scanSingleTagMultiple(
        timeout: Duration(milliseconds: 200),
      );

      if (tags.isNotEmpty) {
        print('📡 Thẻ RFID quét được từ đầu đọc: $tags');
        checkAndAddNewTags(tags); // Gọi hàm đã được sửa đổi
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
    listTagRFID.clear(); // Reset danh sách tag đã xử lý khi tìm kiếm phiếu mới
    ScannedCount.value = 0; // Reset bộ đếm
    isAvalableScan.value =
        false; // Mặc định không cho scan cho đến khi có kết quả

    final data = {
      "companyName": companyName,
      "DepID": selectedDepartmentId.value,
      "LastMatNo": selectedCodePhom.value,
      "UserID": userIDController.text,
      "DateBorrow": convertDate(dateController.text),
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

        if (resultsFromApi != null && resultsFromApi.isNotEmpty) {
          searchResult.assignAll(resultsFromApi.cast<Map<String, dynamic>>());
          isAvalableScan.value = true;
        } else {
          isAvalableScan.value = false;
          Get.snackbar("Thông báo", "Không tìm thấy phiếu mượn phù hợp.");
        }

        if (returnBillFromApi != null) {
          ID_Return.value = returnBillFromApi[0]['ID_Return'].toString();
          returnBillData.assignAll(
            returnBillFromApi.cast<Map<String, dynamic>>(),
          );
        }

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
      } else {
        Get.snackbar('Lỗi', 'Không thể kết nối thiết bị RFID');
      }
    } catch (e) {
      print('❌ Lỗi kết nối RFID: $e');
      Get.snackbar('Lỗi', 'Kết nối RFID thất bại: $e');
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

  @override
  void onInit() async {
    super.onInit();
    isLoading.value = true;

    user = await _getuserUseCase.getUser();

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
    userIDController.text = user!.userId ?? '';
    userNameController.text = user!.userName ?? '';

    print(
      '✅ LendReturnController Initialized. CompanyName: $companyName, UserID: ${user!.userId}',
    );

    final today = DateTime.now();
    dateController.text =
        "${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}";

    // Không await _connectRFID() nếu nó có thể block lâu, hoặc di chuyển logic kết nối
    // tới một thời điểm thích hợp hơn (ví dụ: khi người dùng nhấn nút Scan lần đầu)
    _connectRFID();

    await Future.wait([getDepartment(), getLastMatNo()]);

    isLoading.value = false;
  }

  @override
  void onClose() {
    // Cân nhắc ngắt kết nối RFID ở đây nếu nó được kết nối trong onInit
    // RFIDService.disconnect();
    sumController.dispose();
    dateController.dispose();
    userIDController.dispose();
    userNameController.dispose();
    rfidController.dispose();
    tableScrollController.dispose();
    super.onClose();
  }
}
