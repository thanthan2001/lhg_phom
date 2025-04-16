import 'dart:ui';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/configs/prefs_contants.dart';

class ChangePasswordController extends GetxController {
  var isPasswordHidden = true.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
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

  @override
  void onInit() {
    super.onInit();
    loadLanguage();
  }
}
