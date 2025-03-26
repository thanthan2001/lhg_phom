import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../configs/app_colors.dart';
import '../text/text_widget.dart';

class ButtonWidget extends StatelessWidget {
  final VoidCallback ontap;
  final String text;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool? isBorder;
  final Color? borderColor;
  final SvgPicture? leadingIcon;
  final double? borderRadius;
  final Widget? child;

  const ButtonWidget({
    super.key,
    this.fontWeight = FontWeight.w600,
    required this.ontap,
    required this.text,
    this.height = 48.0,
    this.width = double.infinity,
    this.isBorder = false,
    this.borderColor,
    this.textColor = AppColors.white,
    this.backgroundColor = AppColors.primary,
    this.leadingIcon,
    this.child,
    this.borderRadius = 10.0,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // Đảm bảo hiệu ứng splash hiển thị đúng
      child: InkWell(
        onTap: ontap,
        borderRadius: BorderRadius.circular(borderRadius!),
        splashColor: Colors.white.withOpacity(0.3), // Hiệu ứng sóng nhẹ
        highlightColor: Colors.white.withOpacity(0.1), // Hiệu ứng khi giữ nút
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          width: width,
          height: height,
          decoration: BoxDecoration(
            border:
                isBorder == true
                    ? Border.all(width: 1, color: borderColor!)
                    : null,
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius!),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leadingIcon != null) leadingIcon!,
                if (leadingIcon != null) const SizedBox(width: 5.0),
                Expanded(
                  child:
                      child ??
                      TextWidget(
                        text: text,
                        fontWeight: fontWeight,
                        textAlign: TextAlign.center,
                        color: textColor,
                        size: fontSize,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
