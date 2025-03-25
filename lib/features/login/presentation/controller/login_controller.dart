// login_controller.dart - Không thay đổi
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/data/pref/prefs.dart';
import 'package:lhg_phom/core/services/model/user/domain/usecase/save_user_use_case.dart';
import 'package:lhg_phom/features/login/presentation/widgets/factory_selection.dart';

class LoginController extends GetxController {
  final Prefs prefs = Prefs.preferences; // Thêm Prefs để lưu/truy xuất dữ liệu
  final SaveUserUseCase _saveUserUseCase;
  LoginController(this._saveUserUseCase);

  var isShowPwd = false.obs;
  var selectedFactory = "".obs; // Lưu nhà máy được chọn
  late TextEditingController userID = TextEditingController();
  late TextEditingController pwd = TextEditingController();

  //Expanded Select Language
  final isLanguageSelectorExpanded = false.obs; // NEW: Language Selector
  final currentFlag = 'assets/images/ic_vn.png'.obs;

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
        currentFlag.value = 'assets/images/ic_en.png';
        Get.updateLocale(Locale('en'));
        break;
      case 'vi':
        currentFlag.value = 'assets/images/ic_vn.png';
        Get.updateLocale(Locale('vi'));
        break;
      case 'zh':
        currentFlag.value = 'assets/images/ic_zh.png';
        Get.updateLocale(Locale('zh'));
        break;
      case 'my':
        currentFlag.value = 'assets/images/ic_my.png';
        Get.updateLocale(Locale('my'));
        break;
      default:
        currentFlag.value = 'assets/images/ic_vn.png';
        Get.updateLocale(Locale('vi'));
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

  void login() {
    print("Login button clicked"); // Debug xem hàm có chạy không
    Get.offAllNamed('/main'); // Chuyển sang màng hình home
  }
}
