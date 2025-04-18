import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/services/model/lend_model.dart';

class LendDetailsController extends GetxController {
  late String idMuon;
  late LendItemModel item;

  // Scroll Controllers
  final tableScrollController = ScrollController();

  // State
  final isLoading = false.obs;
  final scrollProgress = 0.0.obs;
  var selectedRowIndex = Rx<int?>(null);

  // Table data
  final inventoryData = <List<String>>[].obs;

  void onFinish() {
    Get.back();
  }

  @override
  void onInit() {
    super.onInit();
    idMuon = Get.arguments;

    item = exampleLendItems.firstWhere(
      (e) => e.idMuon == idMuon,
      orElse: () => throw Exception('Không tìm thấy mượn với id: $idMuon'),
    );

    inventoryData.value =
        item.sizes
            .map(
              (s) => [
                s.size,
                s.soLuong.toString(),
                s.trai.toString(),
                s.phai.toString(),
                s.daTra.toString(),
                s.chuaTra.toString(),
              ],
            )
            .toList();

    print("Inventory data: $inventoryData");
  }

  @override
  void onClose() {
    tableScrollController.dispose();
    super.onClose();
  }
}
