import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/ui/widgets/text/text_widget.dart';
import '../../../../../../core/configs/app_colors.dart';
import '../controller/languageSetting_controller.dart';

class LanguageSettingPage extends GetView<LanguageSettingController> {
  const LanguageSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          centerTitle: true,
          title: const TextWidget(text: "language", color: AppColors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
            onPressed: () => Get.back(result: controller.language.value),
          ),
        ),
        backgroundColor: AppColors.white,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildLanguageTile("English", "en", "assets/images/ic_en.png"),
              _buildLanguageTile("Tiếng Việt", "vi", "assets/images/ic_vn.png"),
              _buildLanguageTile("中文", "zh", "assets/images/ic_zh.png"),
              _buildLanguageTile("မြန်မာဘာသာ", "my", "assets/images/ic_my.png"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile(String language, String code, String iconPath) {
    return Obx(() {
      return ListTile(
        leading: Image.asset(iconPath, width: 30),
        title: Text(language),
        trailing: controller.language.value == language
            ? const Icon(Icons.check, color: AppColors.primary)
            : null,
        onTap: () => controller.changeLanguage(code),
      );
    });
  }
}
