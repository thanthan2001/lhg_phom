import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lhg_phom/core/ui/widgets/text/text_widget.dart';

import '../../../configs/app_colors.dart';

class TextColumWidget extends StatelessWidget {
  final String text1;
  final String text2;
  final double size;
  final FontWeight fontWeight1;
  final FontWeight fontWeight2;
  final Color textColor2;
  final Color textColor1;
  final TextAlign textAlign;

  const TextColumWidget({
    super.key,
    required this.text1,
    required this.text2,
    this.size = 16.0,
    this.fontWeight2 = FontWeight.normal,
    this.fontWeight1 = FontWeight.normal,
    this.textColor2 = AppColors.white,
    this.textColor1 = AppColors.white,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Canh trái
      children: [
        TextWidget(
          text: text1.tr,
          size: size,
            fontWeight: fontWeight1,
            color: textColor1,
          ),
        const SizedBox(height: 5),
        TextWidget(
          text: text2.tr,
          size: size,
            fontWeight: fontWeight1,
            color: textColor2,
          ),
      ],
    );
  }
}
