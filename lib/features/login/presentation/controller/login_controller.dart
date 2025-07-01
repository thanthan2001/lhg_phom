// login_controller.dart - Không thay đổi
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/configs/app_images_string.dart';
import 'package:lhg_phom/core/data/pref/prefs.dart';
import 'package:lhg_phom/core/services/models/user/domain/usecase/save_user_use_case.dart';
import 'package:lhg_phom/features/login/presentation/widgets/factory_selection.dart';
import 'package:dio/dio.dart';

import '../../../../core/services/dio.api.service.dart';
import '../../../../core/services/models/user/model/user_model.dart';

class LoginController extends GetxController {
  final Prefs prefs = Prefs.preferences;
  final SaveUserUseCase _saveUserUseCase;
  LoginController(this._saveUserUseCase);

  var isShowPwd = false.obs;
  var selectedFactory = "".obs; // Lưu nhà máy được chọn
  late TextEditingController userID = TextEditingController();
  late TextEditingController pwd = TextEditingController();

  //Expanded Select Language
  final isLanguageSelectorExpanded = false.obs; // NEW: Language Selector
  final currentFlag = AppImagesString.fEn.obs;
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  @override
  void onInit() {
    super.onInit();
    loadSavedLanguage(); // Gọi hàm lấy ngôn ngữ đã lưu khi khởi động
  }
  // NEW: Toggle function for language selector

  void toggleLanguageSelector() {
    isLanguageSelectorExpanded.value = !isLanguageSelectorExpanded.value;
  }

  void loadSavedLanguage() async {
    String? savedLanguage = await prefs.getLanguage();
    if (savedLanguage != null) {
      selectLanguage(savedLanguage, save: false); // Cập nhật giao diện
    }
  }

  // NEW: Language selection logic (you need to implement this)
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
      prefs.setLanguage(languageName); // Lưu ngôn ngữ vào bộ nhớ
    }

    isLanguageSelectorExpanded.value = false;
  }

  void showPwdStattus() {
    isShowPwd.value = !isShowPwd.value;
  }

  // Hiển thị modal chọn nhà máy
  void showFactoryModal(BuildContext context) {
    Get.dialog(
      FactorySelectionWidget(),
      barrierDismissible: true, // Cho phép đóng khi chạm bên ngoài
    );
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
    print("Login button clicked"); // Debug xem hàm có chạy không
    var data = {
      "userID": userID.text,
      "pwd": pwd.text,
      "companyName": selectedFactory.value.toLowerCase(),
    };
    print("Data to be sent: $data"); // Debug xem dữ liệu gửi đi
    print("BAseUrl: $baseUrl"); // Debug xem baseUrl
    verifyInputLogin(userID, pwd, selectedFactory);
    if (verifyInputLogin(userID, pwd, selectedFactory)) {
      try {
        var response = await ApiService(baseUrl).post('/auth/login', data);
        print(
          "111"
        );
        if (response.statusCode == 200) {
             print(
          "2"
        );
          var user = UserModel.fromJson(
            response.data['data'],
          ); // Chuyển đổi dữ liệu thành UserModel
             print(
          "333"
        );
          user.companyName =
              selectedFactory.value.toLowerCase(); // Lưu tên nhà máy vào user
          await _saveUserUseCase.userSave(user); // Lưu thông tin người dùng

          print(
            "Login successful: ${user.toJson()}",
          ); // Debug xem thông tin người dùng
          Get.offAllNamed('/main'); // Chuyển sang màng hình home
        } else {
          print("Login failed: ${response.statusMessage}"); // Debug xem lỗi gì
          Get.snackbar(
            "Error",
            "Login failed: ${response.statusMessage}",
            snackPosition: SnackPosition.TOP,
          );
        }
      } catch (e) {
        print("Error: $e"); // Debug xem lỗi gì
        Get.snackbar(
          "Error",
          "An error occurred: $e",
          snackPosition: SnackPosition.TOP,
        );
      }
    }
    // Get.offAllNamed('/main');
  }
}
