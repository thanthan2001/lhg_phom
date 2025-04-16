import 'package:flutter/material.dart';

import '../extensions/color.dart';

class AppColors {
  static const primary = Color(0xFF5790AB);
  static const primary1 = Color(0xFF064469);
  static const primary2 = Color(0xFF9CCDDB);
  static const primary3 = Color(0xFF0093D3);
  static const secondary = Color(0xFF14AE5C);
  static const secondary1 = Color(0xFFA0F6FA);
  static const secondary2 = Color(0xFF53EDF5);

  static const grey = Color(0xFF737373);
  static const grey1 = Color(0xFFE5E5E5);
  static const grey2 = Color(0xFF7D7B7B);
  static const grey3 = Color(0xFFD9D9D9);
  static const black = Color(0xFF020112);
  static const white = Color(0xFFFFFFFF);

  static const green = Color(0xFF45A448);
  static const Color red = Color(0XFFc23616);

  static const Color grayTitle = Color(0XFF50555C);

  static const Color markerLocation = Colors.red;

  static const gray = Color(0xFF636363);
  static const Color gray2 = Color.fromARGB(255, 243, 243, 243);

  static const Color yellow = Color(0xFFFFD600);

  static const Color purple = Color.fromARGB(255, 143, 78, 168);

  static const transparent = Colors.transparent;
  static const error = Color(0xFFF83758);
  static const colorPink = Color(0xFFF83758);
  static Color colorPink2 = HexColor('#b20088');
  static Color colorPink3 = HexColor('#f5ecef');
  static Color black4 = HexColor('#1F1F1F');
  static Color greenBold = HexColor('#4CAF50');

  static const blue = Color(0xFF5DCCFC);

  static Color getColorBMI(double bmi) {
    if (bmi < 18.5) {
      return const Color(0xFF84CDEE);
    } else if (bmi >= 18.5 && bmi < 25) {
      return AppColors.primary;
    } else if (bmi >= 25 && bmi < 30) {
      return const Color(0xFFFFDF32);
    } else {
      return const Color(0xFFF5554A);
    }
  }
}
