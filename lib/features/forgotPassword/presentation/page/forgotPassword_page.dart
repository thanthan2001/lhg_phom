import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/configs/app_images_string.dart';
import 'package:lhg_phom/core/ui/widgets/button/button_widget.dart';
import '../../../../core/routes/routes.dart';
import '../controller/forgotPassword_controller.dart';
import '../../../../core/configs/app_colors.dart';
import '../../../../core/configs/app_dimens.dart';
import '../../../../core/ui/widgets/text/text_widget.dart';
import '../../../../core/ui/widgets/textfield/custom_textfield_widget.dart';

class ForgotPasswordPage extends GetView<ForgotPasswordController> {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); 
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppImagesString.fBgLogin),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        TextWidget(
                          text: "Forgot Password",
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          size: 30,
                        ),
                        TextWidget(
                          text: "Please fill all to recieve a new password!",
                          color: AppColors.primary,
                          size: 16,
                        ),
                        SizedBox(height: 20),
                        CustomTextFieldWidget(
                          obscureText: false,
                          enableColor: AppColors.primary,
                          labelText: "User ID",
                          controller: controller.userID,
                        ),
                        SizedBox(height: 10),
                        CustomTextFieldWidget(
                          obscureText: false,
                          enableColor: AppColors.primary,
                          labelText: "Identity Card",
                          controller: controller.identityCard,
                        ),
                        SizedBox(height: 10),
                        CustomTextFieldWidget(
                          obscureText: false,
                          enableColor: AppColors.primary,
                          labelText: "Identity Card",
                          controller: controller.dateOfBirth,
                        ),
                        SizedBox(height: 10),
                        Obx(
                          () => CustomTextFieldWidget(
                            obscureText: controller.isShowPwd.value,
                            enableColor: AppColors.primary,
                            labelText: "New Password",
                            controller: controller.newPassword,
                            suffixIcon: IconButton(
                              onPressed: controller.showPwdStattus,
                              icon: Icon(
                                controller.isShowPwd.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Obx(
                          () => CustomTextFieldWidget(
                            obscureText: controller.isShowPwd.value,
                            enableColor: AppColors.primary,
                            labelText: "Confirm Password",
                            controller: controller.confirmPassword,
                            suffixIcon: IconButton(
                              onPressed: controller.showPwdStattus,
                              icon: Icon(
                                controller.isShowPwd.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Nút chọn nhà máy
                        Obx(
                          () => GestureDetector(
                            onTap: () => controller.showFactoryModal(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 15,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.primary),
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xffCAEAFF),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    controller.selectedFactory.value.isEmpty
                                        ? "choose_factory".tr
                                        : controller.selectedFactory.value,
                                    style: TextStyle(fontSize: 16, color: AppColors.primary),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Get.toNamed(Routes.login);
                              },
                              child: TextWidget(
                                text: "Sign In?",
                                color: AppColors.grey,
                                size: 14,
                                textDecoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                        ButtonWidget(
                          ontap:() {}, text: "Submit"),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
