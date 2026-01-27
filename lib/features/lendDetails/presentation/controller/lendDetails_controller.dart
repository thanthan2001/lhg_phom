import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/services/models/lend_model.dart';

class LendDetailsController extends GetxController {
  late String idMuon;
  late LendItemModel item;

  final tableScrollController = ScrollController();

  final isLoading = false.obs;
  final scrollProgress = 0.0.obs;
  var selectedRowIndex = Rx<int?>(null);

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
  }

  @override
  void onClose() {
    tableScrollController.dispose();
    super.onClose();
  }
}
