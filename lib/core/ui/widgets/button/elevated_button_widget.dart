import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../configs/app_colors.dart';
import '../../../configs/app_dimens.dart';
import '../text/text_widget.dart';

class ElevatedButtonWidget extends StatelessWidget {
  final VoidCallback ontap;
  final String text;
  final String icon;
  final double? height;
  final double? width;
  final Color? backgroundcolor;
  final Color? textColor;
  final FontWeight? fontWeight;
  final bool? isBorder;
  const ElevatedButtonWidget({
    super.key,
    this.fontWeight = FontWeight.w600,
    required this.ontap,
    required this.icon,
    required this.text,
    this.height = 55.0,
    this.width = double.infinity,
    this.isBorder = false,
    this.textColor = AppColors.black,
    this.backgroundcolor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: isBorder == true
              ? Border.all(
                  width: 1.5,
                  color: AppColors.primary.withOpacity(0.9),
                )
              : null,
          color: backgroundcolor,
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icon.isNotEmpty
                ? SvgPicture.asset(
                    icon,
                    height: 20.0,
                    width: 20.0,
                    color: AppColors.white,
                  )
                : const SizedBox.shrink(),
            text.isNotEmpty
                ? const SizedBox(width: 10.0)
                : const SizedBox.shrink(),
            TextWidget(
              text: text,
              fontWeight: fontWeight,
              color: textColor,
              size: AppDimens.textSize16,
            ),
          ],
        ),
      ),
    );
  }
}
