import 'package:flutter/material.dart';

import '../configs/app_colors.dart';

class Line {
  static Container primaryLine() {
    return Container(
      height: 1,
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
    );
  }
}
