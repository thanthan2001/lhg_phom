import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../core/configs/prefs_contants.dart';

class PhomController extends GetxController {
  var phoms = <Map<String, dynamic>>[].obs; // Danh sách phom

  @override
  void onInit() {
    super.onInit();
    loadLanguage();
    loadSampleData();
  }

  // Dữ liệu mẫu
  void loadSampleData() {
    phoms.value = [
      {"phomCode": "P001", "phomName": "Phom A", "material": "Nhựa", "total": 1000},
      {"phomCode": "P002", "phomName": "Phom B", "material": "Nhựa", "total": 800},
      {"phomCode": "P003", "phomName": "Phom C", "material": "Nhựa", "total": 1200},
      {"phomCode": "P004", "phomName": "Phom D", "material": "Nhựa", "total": 500},
      {"phomCode": "P005", "phomName": "Phom E", "material": "Nhựa", "total": 1900},
    ];
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
