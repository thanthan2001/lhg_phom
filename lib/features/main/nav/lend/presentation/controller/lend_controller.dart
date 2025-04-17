import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../core/configs/prefs_contants.dart';
import '../../../../../../core/services/model/lend_model.dart';

class LendController extends GetxController {
  var registerlendItems = <LendItemModel>[].obs;
  var formlendItems = <LendItemModel>[].obs; 

  @override
  void onInit() {
    super.onInit();
    loadLanguage();
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


  Future<void> loadLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String langCode = prefs.getString(PrefsConstants.languageCode) ?? "en";
    updateLanguage(langCode);
  }

  void updateLanguage(String langCode) {
    switch (langCode) {
      case 'vi':
        Get.updateLocale(const Locale('vi'));
        break;
      case 'en':
        Get.updateLocale(const Locale('en'));
        break;
      case 'zh':
        Get.updateLocale(const Locale('zh'));
        break;
      case 'my':
        Get.updateLocale(const Locale('my'));
        break;
    }
    Get.updateLocale(Locale(langCode));
  }

}
