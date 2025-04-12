import 'package:get/get.dart';

import '../../../../../../core/services/model/lend_model.dart';

class LendRegisterController extends GetxController {
  var registerlendItems = <LendItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    registerLend();
  }

 void registerLend() {
    registerlendItems.value =
        exampleLendItems.where((item) => item.trangThai == 'đăng ký mượn').toList();
  }

}
