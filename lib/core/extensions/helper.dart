import 'package:flutter/material.dart';

import '../configs/app_colors.dart';
import '../configs/app_dimens.dart';

class CustomShadow {
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: AppColors.gray.withOpacity(.2),
          blurRadius: 2,
          spreadRadius: .7,
          offset: const Offset(0, 1),
        ),
      ];
}

class CustomCardStyle {
  static BoxDecoration get cardBoxDecoration => BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radius5),
          boxShadow: [
            BoxShadow(
              color: AppColors.gray.withOpacity(.2),
              blurRadius: 2,
              spreadRadius: .7,
              offset: const Offset(0, 1),
            ),
          ]);
}
