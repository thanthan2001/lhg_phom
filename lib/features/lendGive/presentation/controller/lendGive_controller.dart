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

  // State
  final isLoading = false.obs;
  final selectedCodePhom = ''.obs;
  final selectedDepartment = ''.obs;
  final isLeftSide = true.obs;
  final isShowingDetail = false.obs;
  final scrollProgress = 0.0.obs;
  var selectedRowIndex = Rx<int?>(null);
  UserModel? user;
  // Dropdown data
  final codePhomList = ['AHGH', 'JHSG', 'ADTUH', 'KJAKJA', 'AHGGS', 'UHBV'];
  final departmentList = ['IT', 'HR', 'K3', 'SEA'];

  // Table data
  final inventoryData =
      <List<String>>[
        ['36', '300', '2', '4', '2'],
        ['37', '2000', '4', '3', '3'],
        ['38', '1000', '5', '2', '2'],
        ['39', '1000', '5', '2', '2'],
        ['38', '1000', '5', '2', '2'],
        ['39', '1000', '5', '2', '2'],
        ['38', '1000', '5', '2', '2'],
        ['39', '1000', '5', '2', '2'],
      ].obs;

  // Logic
  void onScan() {
    isShowingDetail.value = true;
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

  Future<void> onStartRead() async {
    try {
      await RFIDService.scanContinuous((epc) async {
        if (!scannedEPCs.contains(epc)) {
          print('📡 EPC mới quét: $epc');
          rfidController.text = epc;

          // Gửi lên server
          await sendEPCToServer(epc);

          // Thêm vào danh sách
          scannedEPCs.add(epc);

          // Cập nhật UI nếu cần
          // update();

          // Reset/bắt đầu timer 10 phút
          clearEpcTimer?.cancel();
          clearEpcTimer = Timer(Duration(minutes: 10), () {
            scannedEPCs.clear();
            print('🧹 Danh sách EPC đã được xóa sau 10 phút');
          });
        } else {
          print('⏭️ Đã tồn tại EPC: $epc => bỏ qua');
        }
      });

      print('▶️ Bắt đầu quét liên tục...');
    } catch (e) {
      print('❌ Lỗi startRead: $e');
    }
  }

  Future<void> sendEPCToServer(String epc) async {
    final data = {"companyName": companyName, "epc": epc};
    print("data: $data");
    try {
      final response = await ApiService(
        baseUrl,
      ).post('/phom/scanouttemp', data);

      if (response.statusCode == 200) {
        print('✅ Đã gửi EPC lên server: $epc');
      } else {
        print('❌ Gửi EPC thất bại: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Lỗi khi gửi EPC lên server: $e');
    }
  }

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

  @override
  void onInit() {
    final today = DateTime.now();
    companyName = user!.companyName;
    dateController.text = "${today.day}/${today.month}/${today.year}";
    super.onInit();
    _connectRFID();
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
