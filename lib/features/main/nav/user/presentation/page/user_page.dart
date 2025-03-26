import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/configs/app_colors.dart';
import '../controller/user_controller.dart';

class UserPage extends GetView<UserController> {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileCard(),
              _buildInfoSection(),
              _buildSettingsSection(),
            ],
          ),
        ),
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


  CircleAvatar _avatarUser() {
    return const CircleAvatar(
      radius: 30,
      backgroundColor: AppColors.primary2,
      child: Icon(Icons.person, size: 40, color: Colors.white),
    );
  }

  Column _infomationUser() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "TRẦN VĂN BÉ THÂN",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Text("IT - Software", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 5),
        const Text(
          "Ngày vào công ty: 25-02-2025",
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  /// Thẻ chứa phần "Thông tin"
  Widget _buildInfoSection() {
    return _buildCardWithTitle(
      title: "Thông tin",
      children: [_buildMenuItem(Icons.info, "Thông tin cá nhân", onTap: () {})],
    );
  }

  /// Thẻ chứa phần "Cài đặt"
  Widget _buildSettingsSection() {
    return _buildCardWithTitle(
      title: "Cài đặt",
      children: [
        _buildMenuItem(
          Icons.language,
          "Tiếng Việt",
          leadingIcon: Image.asset("assets/images/ic_vn.png", width: 30),
          onTap: () {},
        ),
        _line(),
        _buildMenuItem(Icons.lock, "Đổi mật khẩu", onTap: () {}),
        _line(),
        _buildDarkModeToggle(),
      ],
    );
  }

  Padding _line() {
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
            padding: const EdgeInsets.all(12),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
      title: const Text("Giao diện tối"),
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
