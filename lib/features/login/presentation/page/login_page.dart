import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/ui/widgets/button/button_widget.dart';
import '../controller/login_controller.dart';
import '../../../../core/configs/app_colors.dart';
import '../../../../core/configs/app_dimens.dart';
import '../../../../core/ui/widgets/text/text_widget.dart';
import '../../../../core/ui/widgets/textfield/custom_textfield_widget.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Unfocus Input
      onTap: () {
        FocusScope.of(context).unfocus(); // Hide keyboard
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg_login.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        TextWidget(
                          text: 'log_in'.tr,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff5790AB),
                          size: AppDimens.textSize30,
                        ),
                        TextWidget(
                          text: 'welcome'.tr,
                          color: Color(0xff5790AB),
                          size: AppDimens.textSize20,
                        ),
                        SizedBox(height: 30),
                        CustomTextFieldWidget(
                          obscureText: false,
                          enableColor: Color(0xff5790AB),
                          labelText: "user_id".tr,
                          controller: controller.userID,
                        ),
                        SizedBox(height: 10),
                        Obx(
                          () => CustomTextFieldWidget(
                            obscureText: controller.isShowPwd.value,
                            enableColor: Color(0xff5790AB),
                            labelText: "password".tr,
                            controller: controller.pwd,
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
                                border: Border.all(color: Color(0xff5790AB)),
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
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: Color(0xff5790AB),
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
                              onPressed: () {},
                              child: Text("forgot_password".tr),
                            ),
                          ],
                        ),
                        ButtonWidget(ontap: controller.login, text: 'login'.tr),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40, // Adjust position as needed
              left: 20,
              child: LanguageSelector(),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Text("version".tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LanguageSelector extends GetView<LoginController> {
  // Accessing the LoginController (where we'll manage isExpanded)
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              controller.toggleLanguageSelector();
            },
            child: Container(
              // Added Container to wrap Image.asset for rounded border
              decoration: BoxDecoration(
                shape: BoxShape.circle, // Make it a circle
                border: Border.all(
                  color: Colors.white, // Change to desired border color
                  width: 2.0, // Adjust border width as needed
                ),
              ),
              child: ClipOval(
                // Clip the image to make it circular
                child: Image.asset(
                  controller.currentFlag.value, // Use observable currentFlag
                  width: 32, // Adjust size as needed
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          if (controller.isLanguageSelectorExpanded.value)
            Column(
              children: [
                _buildLanguageOption('assets/images/ic_en.png', 'en'),
                _buildLanguageOption('assets/images/ic_vn.png', 'vn'),
                _buildLanguageOption('assets/images/ic_zh.png', 'zh'),
                _buildLanguageOption('assets/images/ic_my.png', 'my'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String imagePath, String languageName) {
    return GestureDetector(
      onTap: () {
        controller.selectLanguage(languageName);
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            Container(
              // Added Container to wrap Image.asset for rounded border
              decoration: BoxDecoration(
                shape: BoxShape.circle, // Make it a circle
                border: Border.all(
                  color: Colors.white, // Change to desired border color
                  width: 1.0, // Adjust border width as needed
                ),
              ),
              child: ClipOval(
                // Clip the image to make it circular
                child: Image.asset(
                  imagePath,
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 8),
            // Text(languageName),
          ],
        ),
      ),
    );
  }
}
