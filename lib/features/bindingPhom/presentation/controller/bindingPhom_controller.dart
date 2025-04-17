import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/rfid_service.dart';

class BindingPhomController extends GetxController {
  // Text Controllers
  final materialCodeController = TextEditingController();
  final sizeController = TextEditingController();
  final rfidController = TextEditingController();

  // Scroll Controllers
  final tableScrollController = ScrollController();
  final scrollbarController = ScrollController();

  // State
  final isLoading = false.obs;
  final selectedPhomType = ''.obs;
  final selectedShelf = ''.obs;
  final isLeftSide = true.obs;
  final isShowingDetail = false.obs;
  final scrollProgress = 0.0.obs;
  var selectedRowIndex = Rx<int?>(null);

  // Dropdown data
  final phomTypeList = ['L1', 'L2', 'L3', 'L4', 'L5', 'L6'];
  final shelfList = ['K1', 'K2', 'K3'];

  // Table data
  final inventoryData = <List<String>>[
    ['VH36272', 'GF27881', '3.5', '2000', '10', '5', '3'],
    ['VH36273', 'GF27882', '4.0', '1500', '8', '7', '2'],
    ['VH36274', 'GF27883', '3.0', '1800', '6', '4', '1'],
  ].obs;

  // Logic
  void onSearch() {
    isShowingDetail.value = false;
  }

  void onScan() async {
  final epc = await RFIDService.scanRFID();
  if (epc != null && epc.isNotEmpty) {
    rfidController.text = epc;
    isShowingDetail.value = true;
  } else {
    Get.snackbar('Lỗi', 'Không đọc được thẻ');
  }
}

  void onSelectLeft() {
    isLeftSide.value = true;
  }

  void onSelectRight() {
    isLeftSide.value = false;
  }

  void onFinish() {
    Get.back();
  }

  void _syncScrollControllers() {
  bool isSyncing = false;

  tableScrollController.addListener(() {
    if (isSyncing) return;
    if (!scrollbarController.hasClients) return;

    isSyncing = true;
    scrollbarController.jumpTo(tableScrollController.offset);
    isSyncing = false;
  });

  scrollbarController.addListener(() {
    if (isSyncing) return;
    if (!tableScrollController.hasClients) return;

    isSyncing = true;
    tableScrollController.jumpTo(scrollbarController.offset);
    isSyncing = false;
  });
}


  @override
  void onInit() {
    _syncScrollControllers();
    super.onInit();
  }

  @override
  void onClose() {
    materialCodeController.dispose();
    sizeController.dispose();
    rfidController.dispose();
    tableScrollController.dispose();
    scrollbarController.dispose();
    super.onClose();
  }
}
