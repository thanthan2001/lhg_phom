import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../core/configs/prefs_contants.dart';

class ShelfController extends GetxController {
  // Danh sách dữ liệu mẫu đa dạng hơn
  var shelves = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadLanguage();
    fetchShelves();
  }

  void fetchShelves() {
    shelves.value = [
      {"shelfCode": "A1B2C3", "shelfName": "Kệ A", "totalForms": 18500},
      {"shelfCode": "D4E5F6", "shelfName": "Kệ B", "totalForms": 19200},
      {"shelfCode": "G7H8I9", "shelfName": "Kệ C", "totalForms": 17450},
      {"shelfCode": "J1K2L3", "shelfName": "Kệ D", "totalForms": 20000},
      {"shelfCode": "M4N5O6", "shelfName": "Kệ H", "totalForms": 21050},
      {"shelfCode": "P7Q8R9", "shelfName": "Kệ F", "totalForms": 18900},
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
