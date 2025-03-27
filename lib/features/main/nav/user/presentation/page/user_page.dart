import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/configs/app_colors.dart';
import '../../../../../../core/routes/routes.dart';
import '../../../../../../core/ui/widgets/button/button_widget.dart';
import '../../../../../../core/ui/widgets/text/text_widget.dart';
import '../controller/user_controller.dart';

class UserPage extends GetView<UserController> {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileCard(),
              _buildInfoSection(),
              _buildSettingsSection(),
              SizedBox(height: Get.height * 0.1),
              _buttonLogout(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buttonLogout() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ButtonWidget(
        ontap: () {
          controller.logout();
        },
        text: "logout".tr,
      ),
    );
  }

  /// Thẻ hiển thị thông tin người dùng
  Widget _buildProfileCard() {
    return Card(
      color: AppColors.white,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            _avatarUser(),
            const SizedBox(width: 12),
            _infomationUser(),
          ],
        ),
      ),
    );
  }

  Widget _avatarUser() {
    return const CircleAvatar(
      radius: 40,
      backgroundColor: AppColors.primary2,
      child: Icon(Icons.person, size: 50, color: Colors.white),
    );
  }

  Widget _infomationUser() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextWidget(
          text: "TRẦN VĂN BÉ THÂN",
          size: 16,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 5),
        const TextWidget(text: "IT - Software", color: Colors.grey, size: 14),
        const SizedBox(height: 5),
        TextWidget(
          text: '${'date_joined'.tr}: 01/01/2021',
          color: Colors.black54,
          size: 14,
        ),
      ],
    );
  }

  /// Thẻ chứa phần "Thông tin"
  Widget _buildInfoSection() {
    return _buildCardWithTitle(
      title: 'information'.tr,
      children: [
        _buildMenuItem(
          Icons.info,
          'user_information'.tr,
          onTap: () {
            Get.toNamed(Routes.informationUser);
          },
        ),
      ],
    );
  }

  /// Thẻ chứa phần "Cài đặt"
  Widget _buildSettingsSection() {
    return _buildCardWithTitle(
      title: 'setting'.tr,
      children: [
        Obx(
        () => _buildMenuItem(
          Icons.language,
          controller.language.value,
          leadingIcon: Image.asset(controller.languageIcon.value, width: 30),
          onTap: () {
            Get.toNamed(Routes.settingLanguage);
            controller.loadLanguage();
          },
        ),
      ),
        _line(),
        _buildMenuItem(
          Icons.lock,
          'change_password'.tr,
          onTap: () {
            Get.toNamed(Routes.changePassword);
          },
        ),
        _line(),
        _buildDarkModeToggle(),
      ],
    );
  }

  Widget _line() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 0.2),
    );
  }

  /// Widget Card bao bọc từng mục "Thông tin" & "Cài đặt"
  Widget _buildCardWithTitle({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      color: AppColors.white,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 0, 0),
            child: TextWidget(
              text: title,
              fontWeight: FontWeight.bold,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          Column(children: children),
        ],
      ),
    );
  }

  /// Widget item trong menu
  Widget _buildMenuItem(
    IconData icon,
    String text, {
    Widget? leadingIcon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      leading: leadingIcon ?? Icon(icon, color: AppColors.primary, size: 30),
      title: Text(text),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  /// Widget bật/tắt giao diện tối
  Widget _buildDarkModeToggle() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      leading: const Icon(
        Icons.nightlight_round,
        color: AppColors.primary,
        size: 30,
      ),
      title: Text('dark_mode'.tr),
      trailing: Obx(
        () => Switch(
          activeColor: AppColors.primary1,
          inactiveThumbColor: AppColors.primary1,
          inactiveTrackColor: AppColors.white,
          trackOutlineColor: WidgetStateProperty.all(AppColors.primary1),
          value: controller.isDarkMode.value,
          onChanged: (value) {
            controller.toggleDarkMode();
          },
        ),
      ),
    );
  }
}
