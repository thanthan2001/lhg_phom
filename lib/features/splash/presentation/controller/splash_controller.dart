import 'dart:ui';

import 'package:get/get.dart';
import 'package:lhg_phom/core/data/pref/prefs.dart';
import 'package:lhg_phom/core/routes/routes.dart';
import 'package:lhg_phom/core/services/models/user/domain/usecase/get_user_use_case.dart';

class SplashController extends GetxController {
  final Prefs prefs;
  final GetuserUseCase _getuserUseCase;
  SplashController(this._getuserUseCase, this.prefs);

  RxDouble loadingValue = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    initializeApp();
  }

  Future<void> initializeApp() async {
    await animateTo(0.1);

    String? savedLanguage = await prefs.getLanguage();
    if (savedLanguage != null) {
      Get.updateLocale(Locale(savedLanguage));
    }
    await animateTo(0.5);

    var user = await _getuserUseCase.getUser();
    await animateTo(1.0); 

    await Future.delayed(const Duration(milliseconds: 100));

    if (user != null) {
      Get.offNamed(Routes.main);
    } else {
      Get.offNamed(Routes.login);
    }
  }

  Future<void> animateTo(double target) async {
    const stepDuration = Duration(milliseconds: 10); 
    const stepSize = 0.03;

    while (loadingValue.value < target) {
      loadingValue.value += stepSize;
      if (loadingValue.value > target) {
        loadingValue.value = target;
        break;
      }
      await Future.delayed(stepDuration);
    }
  }
}