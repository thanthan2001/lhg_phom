import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/ui/widgets/text/text_widget.dart';

import '../../../../../../core/configs/app_colors.dart';
import '../controller/informationUser_controller.dart';

class InformationUserPage extends GetView<InformationUserController> {
  const InformationUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      centerTitle: true,
      title: TextWidget(
        text: "user_information".tr,
        color: AppColors.white,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(),
        const SizedBox(height: 20),
        _buildUserInfo(),
      ],
    );
  }

  Widget _buildAvatar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 120,
          width: double.infinity,
          // ignore: deprecated_member_use
          color: AppColors.primary2.withOpacity(0.5),
        ),
        Positioned(
          top: Get.height * 0.08,
          left: Get.width / 2 - 50,
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.person,
              size: 70,
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserInfoRow("user_id".tr, controller.idUser),
          _buildUserInfoRow("department".tr, controller.department),
          _buildUserInfoRow("full_name".tr, controller.fullName),
          _buildUserInfoRow("birth_date".tr, controller.birthDate),
          _buildUserInfoRow("phone_number".tr, controller.phoneNumber),
          _buildUserInfoRow("hometown".tr, controller.hometown),
          _buildUserInfoRow("date_joined".tr, controller.joiningDate),
        ],
      ),
    );
  }

  Widget _buildUserInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontWeight: FontWeight.w500, 
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );
}

}
