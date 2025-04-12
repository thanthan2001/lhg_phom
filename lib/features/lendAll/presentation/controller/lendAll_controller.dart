import 'package:get/get.dart';

import '../../../../../../core/services/model/lend_model.dart';

class LendAllController extends GetxController {
  var formlendItems = <LendItemModel>[].obs; 

  @override
  void onInit() {
    super.onInit();
    formLend();
  }

 void formLend() {
    formlendItems.value =
        exampleLendItems.where((item) => item.trangThai != 'đăng ký mượn').toList();
  }

}
