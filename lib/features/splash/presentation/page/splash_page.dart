import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/configs/app_colors.dart';
import 'package:lhg_phom/features/splash/presentation/controller/splash_controller.dart';

import '../../../../core/configs/app_images_string.dart';
import '../../../../core/ui/widgets/text/text_widget.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary1,
      body: Stack(
        children: [
          // Logo có hiệu ứng scale mượt
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 5),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AppImagesString.fLogo,
                    width: 150.0,
                    height: 150.0,
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          ),

          // Tiến trình & % hiển thị
          Positioned(
            bottom: Get.height * 0.1,
            left: 70.0,
            right: 70.0,
            child: Column(
              children: [
                Obx(() => LinearProgressIndicator(
                      value: controller.loadingValue.value,
                      backgroundColor: AppColors.grey1,
                      borderRadius: BorderRadius.circular(5.0),
                      color: AppColors.primary,
                      minHeight: 8.0,
                    )),
                const SizedBox(height: 10.0),
                Obx(() => AnimatedOpacity(
                      opacity: controller.loadingValue.value > 0 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: TextWidget(
                        text:
                            '${(controller.loadingValue.value * 100).toInt()}%',
                        size: 12,
                        color: AppColors.primary,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
