import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/configs/app_images_string.dart';
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
            onPressed: () => Get.back(result: true),
          ),
        ),
        backgroundColor: AppColors.white,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildLanguageTile("English", "en", AppImagesString.fEn),
              _buildLanguageTile("Tiếng Việt", "vi", AppImagesString.fVi),
              _buildLanguageTile("中文", "zh", AppImagesString.fZh),
              _buildLanguageTile("မြန်မာဘာသာ", "my", AppImagesString.fMy),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile(String language, String code, String iconPath) {
    return Obx(() {
      return ListTile(
        leading: Image.asset(iconPath, width: 40, height: 28, fit: BoxFit.cover),
        title: Text(language),
        trailing:
            controller.language.value == language
                ? const Icon(Icons.check, color: AppColors.primary)
                : null,
        onTap: () => controller.changeLanguage(code),
      );
    });
  }
}
