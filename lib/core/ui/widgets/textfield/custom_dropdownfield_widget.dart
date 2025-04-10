import 'package:flutter/material.dart';
import 'package:lhg_phom/core/ui/widgets/text/text_widget.dart';
import '../../../configs/app_colors.dart';

class CustomDropdownField extends StatelessWidget {
  final String labelText;
  final String selectedValue;
  final VoidCallback onTap;

  // Optional customizations
  final TextStyle? labelStyle;
  final double? labelSize;
  final Color? labelColor;

  final double? valueSize;
  final Color? valueColor;
  final FontWeight? valueFontWeight;

  final EdgeInsetsGeometry? contentPadding;
  final double borderRadius;
  final Color enabledBorderColor;
  final Color focusedBorderColor;
  final Color errorBorderColor;
  final Color disabledBorderColor;
  final Color backgroundColor;

  const CustomDropdownField({
    super.key,
    required this.labelText,
    required this.selectedValue,
    required this.onTap,
    this.labelStyle,
    this.labelSize,
    this.labelColor,
    this.valueSize,
    this.valueColor,
    this.valueFontWeight,
    this.contentPadding,
    this.borderRadius = 5,
    this.enabledBorderColor = AppColors.grey2,
    this.focusedBorderColor = AppColors.primary1,
    this.errorBorderColor = AppColors.error,
    this.disabledBorderColor = AppColors.grey,
    this.backgroundColor = AppColors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = selectedValue.isEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          InputDecorator(
            decoration: InputDecoration(
              label:
                  isEmpty
                      ? null
                      : TextWidget(
                        text: labelText,
                        size: labelSize ?? 14,
                        color: labelColor ?? AppColors.black,
                        fontWeight: FontWeight.w400,
                      ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(color: enabledBorderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(color: enabledBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(color: focusedBorderColor, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(color: errorBorderColor),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(color: disabledBorderColor),
              ),
              filled: true,
              fillColor: backgroundColor,
              contentPadding:
                  contentPadding ??
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),

            child: TextWidget(
              text: isEmpty ? labelText : selectedValue,
              size: valueSize ?? 16,
              color: valueColor ?? AppColors.black,
              fontWeight: valueFontWeight ?? FontWeight.bold,
              textAlign: TextAlign.left,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.arrow_drop_down, color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}
