import 'dart:ui';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/configs/prefs_contants.dart';
import '../../../../core/data/pref/prefs.dart';
import '../../../../core/services/models/user/domain/usecase/get_user_use_case.dart';

class InformationUserController extends GetxController {
  final Prefs prefs = Prefs.preferences;
  final GetuserUseCase _getuserUseCase;
  InformationUserController(this._getuserUseCase);

  final String idUser = "67845";
  final String department = "IT Software";
  final String fullName = "Trần Văn Bé Thân";
  final String birthDate = "01/01/2001";
  final String phoneNumber = "0987828268";
  final String hometown = "256 Cái Tắc, Châu Thành A, Hậu Giang";
  final String joiningDate = "25/02/2025";

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
