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
  final Widget? leadingIcon;
  final Widget? icon;
  final double? borderRadius;
  final Widget? child;

  const ButtonWidget({
    super.key,
    this.fontWeight = FontWeight.w600,
    required this.ontap,
    required this.text,
    this.height = 56.0,
    this.width = double.infinity,
    this.isBorder = false,
    this.borderColor,
    this.textColor = AppColors.white,
    this.backgroundColor = AppColors.primary,
    this.leadingIcon,
    this.icon,
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                spreadRadius: 1, // Bán kính lan rộng
                blurRadius: 6, // Độ mờ của bóng
                offset: const Offset(0, 2), // Độ dịch chuyển theo trục X,Y
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                
                Flexible(
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
                if (leadingIcon != null) const SizedBox(width: 2.0),
                if (leadingIcon != null) leadingIcon!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
