import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../core/configs/app_colors.dart';
import '../../../../core/ui/widgets/button/button_widget.dart';
import '../../../../core/ui/widgets/text/text_widget.dart';
import '../../../../core/ui/widgets/textfield/custom_textfield_widget.dart';
import '../controller/changePassword_controller.dart';

class ChangePasswordPage extends GetView<ChangePasswordController> {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: _appbar(),
          backgroundColor: AppColors.white,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _passwordField(
                  hintText: "Current password",
                  isHidden: controller.isPasswordHidden,
                  onToggle: controller.togglePasswordVisibility,
                ),
                const SizedBox(height: 10),
                _passwordField(
                  hintText: "New password",
                  isHidden: controller.isPasswordHidden,
                  onToggle: controller.togglePasswordVisibility,
                ),
                const SizedBox(height: 10),
                _passwordField(
                  hintText: "Confirm password",
                  isHidden: controller.isPasswordHidden,
                  onToggle: controller.togglePasswordVisibility,
                ),
                SizedBox(height: Get.height * 0.5),
                ButtonWidget(
                  ontap: () {}, 
                  text: "Save",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordField({
    required String hintText,
    required RxBool isHidden,
    required VoidCallback onToggle,
  }) {
    return Obx(
      () => CustomTextFieldWidget(
        textColor: AppColors.black,
        hintText: hintText,
        hintColor: AppColors.primary,
        obscureText: isHidden.value,
        suffixIcon: IconButton(
          icon: Icon(
            isHidden.value ? Icons.visibility_off : Icons.visibility,
            color: AppColors.primary1,
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  AppBar _appbar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      centerTitle: true,
      title: const TextWidget(text: "Đổi mật khẩu", color: AppColors.white),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
        onPressed: () => Get.back(),
      ),
    );
  }
}
