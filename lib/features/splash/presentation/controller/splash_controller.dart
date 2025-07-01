import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/data/pref/prefs.dart';
import 'package:lhg_phom/core/routes/routes.dart';
import 'package:lhg_phom/core/services/models/user/domain/usecase/get_user_use_case.dart';

import '../../../../core/services/rfid_service.dart';

class SplashController extends GetxController {
  final Prefs prefs;
  final GetuserUseCase _getuserUseCase;
  SplashController(this._getuserUseCase, this.prefs);

  RxDouble loadingValue = 0.0.obs;
  Future<void> _connectRFID() async {
    try {
      final connected = await RFIDService.connect();
      if (connected) {
        print('✅💕 Đã kết nối RFID thành công');
        Get.snackbar(
          '✅ Kết nối thành công',
          'Đã kết nối với thiết bị RFID',
          backgroundColor: Colors.green.withOpacity(0.8),
        );
      } else {
        Get.snackbar(
          '❌Lỗi',
          'Kết nối RFID thất bại',
          backgroundColor: Colors.red.withOpacity(0.8),
        );
      }
    } catch (e) {
      print('❌ Lỗi kết nối RFID: $e');
      Get.snackbar(
        '❌Lỗi',
        'Kết nối RFID thất bại: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
      );
    }
  }

  @override
  void onInit() {
    _connectRFID();
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
