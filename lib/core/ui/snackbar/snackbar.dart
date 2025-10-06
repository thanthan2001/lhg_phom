import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../configs/app_colors.dart';

class SnackbarUtil {
  static show(String message) {
    Get.showSnackbar(
      GetSnackBar(
        messageText: Text(
          message.tr,
          style: Theme.of(Get.context!)
              .textTheme
              .titleMedium
              ?.copyWith(color: AppColors.white),
        ),
        snackStyle: SnackStyle.GROUNDED,
        duration: const Duration(seconds: 3),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
