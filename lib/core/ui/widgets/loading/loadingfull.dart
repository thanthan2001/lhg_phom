// ignore: file_names
import 'package:flutter/cupertino.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../configs/app_colors.dart';

class LoadingFull extends StatelessWidget {
  const LoadingFull({super.key});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      child: Container(
        color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.3),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10)),
            child: LoadingAnimationWidget.staggeredDotsWave(
                color: AppColors.white, size: 90),
          ),
        ),
      ),
    );
  }
}