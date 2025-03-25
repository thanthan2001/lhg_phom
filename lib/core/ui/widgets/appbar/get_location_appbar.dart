import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../configs/app_colors.dart';
import '../../../configs/app_dimens.dart';
import '../../../configs/app_text_string.dart';

class GetLocationAppbar extends StatelessWidget implements PreferredSizeWidget {
  const GetLocationAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading:
          IconButton(onPressed: () {Get.back(result: {"closeDialog":true});}, icon: const Icon(Icons.arrow_back_ios)),
      title: const Text(
        "AppTextString.fLocationAppbar",
        style: TextStyle(
            fontSize: AppDimens.textSize22, fontWeight: FontWeight.w500),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: EdgeInsets.only(right: Get.width*0.04),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: AppColors.gray2, borderRadius: BorderRadius.circular(100)),
          child: IconButton(icon:const Icon(Icons.location_on_rounded), onPressed: () {  },),
        )
      ],

      //bottom line
      bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(2.0), // Adjust the height of the bottom border
          child: Container(
            color: AppColors.primary, // Border color
            height: 2, // Border height
          ),
        ),
    );
  }
  
  @override
  Size get preferredSize => AppBar().preferredSize;
}