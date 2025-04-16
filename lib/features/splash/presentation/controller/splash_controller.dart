import 'dart:ui';

import 'package:get/get.dart';
import 'package:lhg_phom/core/data/pref/prefs.dart';
import 'package:lhg_phom/core/routes/routes.dart';
import 'package:lhg_phom/core/services/model/user/domain/usecase/get_user_use_case.dart';

class SplashController extends GetxController {
  final Prefs prefs;
  final GetuserUseCase _getuserUseCase;
  SplashController(this._getuserUseCase, this.prefs);
  RxDouble loadingProgress = 0.0.obs;
  RxDouble loadingValue = 0.0.obs; 

  @override
  void onInit() {
    super.onInit();
    applySavedLanguage();
    simulateLoading();
  }

  void applySavedLanguage() async {
    String? savedLanguage = await prefs.getLanguage();
    if (savedLanguage != null) {
      Get.updateLocale(Locale(savedLanguage));
    }
  }

  Future<void> simulateLoading() async {
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 50), () {
        loadingValue.value = i / 100;
      });
    }
    await Future.delayed(const Duration(seconds: 3));
    var user = await _getuserUseCase.getUser();
    if (user != null) {
          Get.offNamed(Routes.main);
        } else {
          Get.offNamed(Routes.login);
          //Get.offNamed(Routes.settingInfomation);
    };
  }
}
