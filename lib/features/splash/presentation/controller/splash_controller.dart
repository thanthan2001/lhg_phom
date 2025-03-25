import 'dart:ui';

import 'package:get/get.dart';
import 'package:lhg_phom/core/configs/prefs_contants.dart';
import 'package:lhg_phom/core/data/pref/prefs.dart';
import 'package:lhg_phom/core/routes/routes.dart';
import 'package:lhg_phom/core/services/model/user/domain/usecase/get_user_use_case.dart';
import 'package:lhg_phom/main.dart';

class SplashController extends GetxController {
  final Prefs prefs;
  final GetuserUseCase _getuserUseCase;
  SplashController(this._getuserUseCase, this.prefs);
  RxDouble loadingProgress = 0.0.obs;

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
    _getuserUseCase.getToken().then((value) {
      if (value != null) {
        Get.offNamed(Routes.login);
      } else {
        Get.offNamed(Routes.login);
      }
    });
  }
}
