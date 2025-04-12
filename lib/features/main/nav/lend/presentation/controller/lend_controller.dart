import 'package:get/get.dart';

import '../../../../../../core/services/model/lend_model.dart';

class LendController extends GetxController {
  var registerlendItems = <LendItemModel>[].obs;
  var formlendItems = <LendItemModel>[].obs; 

  @override
  void onInit() {
    super.onInit();
    registerLend();
    formLend();
  }

  // Dữ liệu mẫu
 void registerLend() {
    registerlendItems.value =
        exampleLendItems.where((item) => item.trangThai == 'đăng ký mượn').toList();
  }

 void formLend() {
    formlendItems.value =
        exampleLendItems.where((item) => item.trangThai != 'đăng ký mượn').toList();
  }

}
