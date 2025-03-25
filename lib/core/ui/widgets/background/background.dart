import 'package:flutter/material.dart';

import '../../../configs/app_colors.dart';
import '../../../configs/app_images_string.dart';
import '../../../services/images_service.dart';

class Background extends StatelessWidget {
  final String authorImg;
  final double heightBg;
  const Background({
    super.key,
    required this.authorImg,
    required this.heightBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: heightBg,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(.2),
            blurRadius: 1,
            spreadRadius: 1,
          ),
        ],
      ),
      child: FutureBuilder<bool>(
        future: ImagesService.doesImageLinkExist(authorImg),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              child: Center(child: CircularProgressIndicator(strokeWidth: 2,)),
            );
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == false) {
            return Image.asset(
              "AppImagesString.iBackgroundUserDefault",
              fit: BoxFit.cover,
            );
          } else {
            return Image.network(
              authorImg,
              fit: BoxFit.cover,
            );
          }
        },
      ),
    );
  }
}