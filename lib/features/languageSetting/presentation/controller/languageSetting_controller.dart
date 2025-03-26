import 'dart:ui';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/configs/prefs_contants.dart';

class LanguageSettingController extends GetxController {
  var language = "English".obs;

  @override
  void onInit() {
    super.onInit();
    loadLanguage();
  }

  Future<void> loadLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String langCode = prefs.getString(PrefsConstants.languageCode) ?? "en";
    updateLanguage(langCode);
  }

  void changeLanguage(String langCode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsConstants.languageCode, langCode);
    updateLanguage(langCode);
  }

  void updateLanguage(String langCode) {
    switch (langCode) {
      case 'vi':
        language.value = "Tiếng Việt";
        Get.updateLocale(const Locale('vi'));
        break;
      case 'en':
        language.value = "English";
        Get.updateLocale(const Locale('en'));
        break;
      case 'zh':
        language.value = "中文";
        Get.updateLocale(const Locale('zh'));
        break;
      case 'my':
        language.value = "မြန်မာဘာသာ";
        Get.updateLocale(const Locale('my'));
        break;
    }
  }
}
