import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../core/data/pref/prefs.dart';
import '../../../../../../core/routes/routes.dart';
import '../../../../../../core/services/model/user/domain/usecase/get_user_use_case.dart';
import '../../../../../../core/configs/prefs_contants.dart';

class UserController extends GetxController {
  final Prefs prefs = Prefs.preferences;
  final GetuserUseCase _getuserUseCase;
  UserController(this._getuserUseCase);

  var isDarkMode = false.obs;
  var language = "English".obs;
  var languageIcon = "assets/images/ic_en.png".obs;

  /// **Chuyển đổi giữa dark mode và light mode**
  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeTheme(isDarkMode.value ? ThemeData.dark() : ThemeData.light());
  }

  /// **Đăng xuất**
  Future<void> logout() async {
    await _getuserUseCase.logout();
    Get.offAllNamed(Routes.login);
  }

  Future<void> loadLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String langCode = prefs.getString(PrefsConstants.languageCode) ?? "en";
    updateLanguage(langCode);
  }

  void updateLanguage(String langCode) {
    switch (langCode) {
      case 'vi':
        language.value = "Tiếng Việt";
        languageIcon.value = "assets/images/ic_vn.png";
        Get.updateLocale(const Locale('vi'));
        break;
      case 'en':
        language.value = "English";
        languageIcon.value = "assets/images/ic_en.png";
        Get.updateLocale(const Locale('en'));
        break;
      case 'zh':
        language.value = "中文";
        languageIcon.value = "assets/images/ic_zh.png";
        Get.updateLocale(const Locale('zh'));
        break;
      case 'my':
        language.value = "မြန်မာဘာသာ";
        Get.updateLocale(const Locale('my'));
        languageIcon.value = "assets/images/ic_my.png";
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
