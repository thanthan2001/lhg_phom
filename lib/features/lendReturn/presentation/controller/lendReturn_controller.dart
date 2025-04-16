import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LendReturnController extends GetxController {
  // Text Controllers
  final sumController = TextEditingController();
  final dateController = TextEditingController();
  final userIDController = TextEditingController();
  final userNameController = TextEditingController();
  final rfidController = TextEditingController();

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

  // Dropdown data
  final codePhomList = ['AHGH', 'JHSG', 'ADTUH', 'KJAKJA', 'AHGGS', 'UHBV'];
  final departmentList = ['IT', 'HR', 'K3', 'SEA'];

  // Table data
  final inventoryData = <List<String>>[
    ['36', '300', '2', '4', '2'],
    ['37', '2000', '4', '3', '3'],
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


  @override
  void onInit() {
    final today = DateTime.now();
    dateController.text = "${today.day}/${today.month}/${today.year}";
    super.onInit();
  }

  @override
  void onClose() {
    sumController.dispose();
    dateController.dispose();
    userIDController.dispose();
    rfidController.dispose();
    tableScrollController.dispose();
    super.onClose();
  }
}
