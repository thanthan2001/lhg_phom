import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/configs/app_images_string.dart';
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
                              child: TextWidget(
                                text: "forgot_password".tr,
                                color: AppColors.grey,
                                size: 14,
                                textDecoration: TextDecoration.underline,
                              ),
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
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Danh sách các ngôn ngữ có sẵn
      final List<Map<String, String>> languages = [
        {'code': 'en', 'flag': AppImagesString.fEn},
        {'code': 'vi', 'flag': AppImagesString.fVi},
        {'code': 'zh', 'flag': AppImagesString.fZh},
        {'code': 'my', 'flag': AppImagesString.fMy},
      ];

      // Xác định ngôn ngữ hiện tại
      final String currentFlag = controller.currentFlag.value;

      // Lọc ra 3 ngôn ngữ còn lại
      final List<Map<String, String>> otherLanguages =
          languages.where((lang) => lang['flag'] != currentFlag).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              controller.toggleLanguageSelector();
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.0),
              ),
              child: ClipOval(
                child: Image.asset(
                  currentFlag,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          if (controller.isLanguageSelectorExpanded.value)
            Column(
              children: [
                for (var lang in otherLanguages)
                  _buildLanguageOption(lang['flag']!, lang['code']!),
              ],
            ),
        ],
      );
    });
  }

  Widget _buildLanguageOption(String imagePath, String languageCode) {
    return GestureDetector(
      onTap: () {
        controller.selectLanguage(languageCode);
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.0),
              ),
              child: ClipOval(
                child: Image.asset(
                  imagePath,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 5),
          ],
        ),
      ),
    );
  }
}
