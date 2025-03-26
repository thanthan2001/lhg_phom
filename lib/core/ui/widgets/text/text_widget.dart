import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../configs/app_colors.dart';
import '../../../configs/app_dimens.dart';

class TextWidget extends StatelessWidget {
  final String text;
  final double? size;
  final Color? color;
  final int? maxLines;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final List<Shadow>? listShadow;
  final TextDecoration? textDecoration;
  final FontStyle? fontStyle;
  const TextWidget({
    super.key,
    this.textAlign,
    this.listShadow,
    this.maxLines = 1000,
    required this.text,
    this.color = AppColors.black,
    this.size = AppDimens.textSize18,
    this.fontWeight = FontWeight.normal,
    this.fontStyle = FontStyle.normal,
    this.textDecoration = TextDecoration.none,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text.tr,
      maxLines: maxLines,
      softWrap: true,
      overflow: TextOverflow.visible,
      textAlign: textAlign ?? TextAlign.center,
      style: GoogleFonts.roboto(
        textStyle: TextStyle(
          color: color,
          fontSize: size,
          fontStyle: fontStyle,
          shadows: listShadow,
          fontWeight: fontWeight,
          decoration: textDecoration,
          // overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}