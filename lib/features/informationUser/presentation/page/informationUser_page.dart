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
        appBar: _appbar(),
        backgroundColor: AppColors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [

            ],
          ),
        ),
      ),
    );
  }

  AppBar _appbar() {
    return AppBar(
        backgroundColor: AppColors.primary,
        centerTitle: true,
        title: const TextWidget(text: "Thông tin cá nhân", color: AppColors.white,),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.white,),
          onPressed: () => Get.back(),
        ),
      );
  }

}