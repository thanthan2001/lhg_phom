import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/configs/app_images_string.dart';
import 'package:lhg_phom/core/data/pref/prefs.dart';
import 'package:lhg_phom/core/services/models/user/domain/usecase/save_user_use_case.dart';
import 'package:lhg_phom/features/login/presentation/widgets/factory_selection.dart';

import '../../../../core/services/dio.api.service.dart';
import '../../../../core/services/models/user/model/user_model.dart';

class LoginController extends GetxController {
  final Prefs prefs = Prefs.preferences;
  final SaveUserUseCase _saveUserUseCase;
  LoginController(this._saveUserUseCase);

  var isShowPwd = false.obs;
  var selectedFactory = "".obs;
  late TextEditingController userID = TextEditingController();
  late TextEditingController pwd = TextEditingController();

  final isLanguageSelectorExpanded = false.obs;
  final currentFlag = AppImagesString.fEn.obs;
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  @override
  void onInit() {
    super.onInit();
    loadSavedLanguage();
  }

  void toggleLanguageSelector() {
    isLanguageSelectorExpanded.value = !isLanguageSelectorExpanded.value;
  }

  void loadSavedLanguage() async {
    String? savedLanguage = await prefs.getLanguage();
    if (savedLanguage != null) {
      selectLanguage(savedLanguage, save: false);
    }
  }

  void selectLanguage(String languageName, {bool save = true}) {
    switch (languageName) {
      case 'en':
        currentFlag.value = AppImagesString.fEn;
        Get.updateLocale(Locale('en'));
        break;
      case 'vi':
        currentFlag.value = AppImagesString.fVi;
        Get.updateLocale(Locale('vi'));
        break;
      case 'zh':
        currentFlag.value = AppImagesString.fZh;
        Get.updateLocale(Locale('zh'));
        break;
      case 'my':
        currentFlag.value = AppImagesString.fMy;
        Get.updateLocale(Locale('my'));
        break;
    }

    if (save) {
      prefs.setLanguage(languageName);
    }

    isLanguageSelectorExpanded.value = false;
  }

  void showPwdStattus() {
    isShowPwd.value = !isShowPwd.value;
  }

  void showFactoryModal(BuildContext context) {
    Get.dialog(FactorySelectionWidget(), barrierDismissible: true);
  }

  bool verifyInputLogin(userID, pwd, selectedFactory) {
    if (userID.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your User ID",
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
    if (pwd.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your Password",
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
    if (selectedFactory.value.isEmpty) {
      Get.snackbar(
        "Error",
        "Please select a factory",
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
    return true;
  }

  Future<void> login() async {
    var data = {
      "userID": userID.text,
      "pwd": pwd.text,
      "companyName": selectedFactory.value.toLowerCase(),
    };

    verifyInputLogin(userID, pwd, selectedFactory);
    if (verifyInputLogin(userID, pwd, selectedFactory)) {
      try {
        var response = await ApiService(baseUrl).post('/auth/login', data);

        if (response.statusCode == 200) {
          var user = UserModel.fromJson(response.data['data']);

          user.companyName = selectedFactory.value.toLowerCase();
          await _saveUserUseCase.userSave(user);

          Get.offAllNamed('/main');
        } else {
          Get.snackbar(
            "Error",
            "Login failed: ${response.statusMessage}",
            snackPosition: SnackPosition.TOP,
          );
        }
      } catch (e) {
        Get.snackbar(
          "Error",
          "An error occurred: $e",
          snackPosition: SnackPosition.TOP,
        );
      }
    }
  }
}
