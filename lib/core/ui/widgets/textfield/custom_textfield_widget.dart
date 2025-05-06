import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../configs/app_colors.dart';
import '../../../configs/app_dimens.dart';
import '../text/text_widget.dart';

enum InputDecorationType { box, underline }

class CustomTextFieldWidget extends StatefulWidget {
  final double height;
  final double borderRadius;
  final Color? hintColor;
  final String? hintText;
  String? errorText;
  final bool obscureText;
  final Color? backgroundColor;
  final Color? focusedColor;
  final double? focusedWidth;
  final Color? enableColor;
  final double? enableWidth;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Function(String)? onChanged;
  final Function(String)? onCompleted;
  final Color? textColor;
  final Function()? onTap;
  final FocusNode? focusNode;
  final String? labelText;
  final Color? labelColor;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool isShowBorder;
  final bool enable;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final InputDecorationType decorationType;
  final AutovalidateMode autovalidateMode;
  final String? Function(String?)? validator;

  CustomTextFieldWidget({
    super.key,
    this.height = 52.0,
    this.errorText = "Text is empty",
    this.borderRadius = 10.0,
    this.onChanged,
    this.suffixIcon,
    this.prefixIcon,
    required this.obscureText,
    this.backgroundColor,
    this.focusedWidth = 1,
    this.enableWidth = 1,
    this.controller,
    this.hintText,
    this.hintColor,
    this.focusedColor = AppColors.primary1,
    this.enableColor = AppColors.primary,
    this.onTap,
    this.focusNode,
    this.labelText,
    this.labelColor = AppColors.primary,
    this.textColor,
    this.onCompleted,
    this.keyboardType,
    this.isShowBorder = true,
    this.enable = true,
    this.maxLength,
    this.inputFormatters,
    this.decorationType = InputDecorationType.box,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.validator,
  });

  @override
  State<CustomTextFieldWidget> createState() => _CustomTextFieldWidgetState();
}

class _CustomTextFieldWidgetState extends State<CustomTextFieldWidget> {
  bool isError = false;
  bool isFormFieldValid = false;

  InputBorder _getInputBorder(Color color, double width) {
    if (widget.decorationType == InputDecorationType.box) {
      return OutlineInputBorder(
        borderSide: BorderSide(width: width, color: color),
        borderRadius: BorderRadius.circular(widget.borderRadius),
      );
    } else {
      return UnderlineInputBorder(
        borderSide: BorderSide(width: width, color: color),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Ẩn bàn phím khi nhấn ngoài input
      },
      behavior: HitTestBehavior.translucent, // Cho phép nhận sự kiện nhấn
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            
            enabled: widget.enable,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            controller: widget.controller,
            autovalidateMode: widget.autovalidateMode,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onCompleted,
            inputFormatters: widget.inputFormatters,
            obscureText: widget.obscureText,
            focusNode: widget.focusNode,
            validator: widget.validator,
            style: TextStyle(
              fontSize: AppDimens.textSize16,
              color: widget.textColor ?? AppColors.primary,
            ),
            decoration: InputDecoration(
              border: _getInputBorder(widget.enableColor!, widget.enableWidth!),
              contentPadding: EdgeInsets.symmetric(
                vertical: (widget.height - AppDimens.textSize16) / 2,
                horizontal: 10,
              ),
              labelText: widget.labelText,
              labelStyle: TextStyle(
                color: widget.labelColor,
                fontSize: AppDimens.textSize16,
              ),
              suffixIcon: widget.suffixIcon,
              prefixIcon: widget.prefixIcon,
              filled: widget.backgroundColor != null,
              fillColor: widget.backgroundColor,
              hintText: widget.hintText,
              hintStyle: TextStyle(
                fontSize: AppDimens.textSize16,
                color: widget.hintColor,
              ),
              enabledBorder:
                  widget.isShowBorder
                      ? _getInputBorder(
                        widget.enableColor!,
                        widget.enableWidth!,
                      )
                      : InputBorder.none,
              focusedBorder:
                  widget.isShowBorder
                      ? _getInputBorder(
                        widget.focusedColor!,
                        widget.focusedWidth!,
                      )
                      : InputBorder.none,
              errorBorder: _getInputBorder(
                widget.focusedColor!,
                widget.focusedWidth!,
              ),
              focusedErrorBorder: _getInputBorder(
                widget.focusedColor!,
                widget.focusedWidth!,
              ),
            ),
          ),
          isError
              ? TextWidget(
                text: widget.errorText ?? "",
                size: AppDimens.textSize14,
                color: AppColors.error,
              )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
