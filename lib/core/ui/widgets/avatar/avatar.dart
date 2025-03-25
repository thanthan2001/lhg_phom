import 'package:flutter/material.dart';
import 'package:lhg_phom/core/services/images_service.dart';

import '../../../configs/app_colors.dart';
import '../../../configs/app_images_string.dart';

class Avatar extends StatelessWidget {
  final double radius;
  final String? authorImg;
  const Avatar({super.key, this.authorImg, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(.2),
            blurRadius: 1,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10000),
        child: FutureBuilder<bool>(
          future: ImagesService.doesImageLinkExist(authorImg ?? ""),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                width: radius,
                height: radius,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            } else if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data == false) {
              return Image.asset(
                "AppImagesString.eAvatarUserDefault,",
                width: radius,
                height: radius,
                fit: BoxFit.cover,
              );
            } else {
              return Image.network(
                authorImg ?? "",
                width: radius,
                height: radius,
                fit: BoxFit.cover,
              );
            }
          },
        ),
      ),
    );
  }
}
