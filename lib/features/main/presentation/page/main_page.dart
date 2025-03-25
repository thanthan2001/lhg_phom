//import 'package:epose_app/core/extensions/required.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/ui/widgets/loading/loadingfull.dart';

import '../../../../core/ui/widgets/nav/bottom_navigationbar_widget.dart';
import '../controller/main_controller.dart';

class MainPage extends GetView<MainController> {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Navigator(
            key: Get.nestedKey(10),
            initialRoute: "/home",
            // onGenerateRoute: controller.onGenerateRoute,
          ),

          // Obx(() {
          //   return !controller.isLocationServiceEnabled.value &&
          //           controller.showRequiredLocationBox.value
          //       ? RequiredLocation(controller: controller)
          //       : const SizedBox();
          // }),
          Obx(() {
            return controller.isLoading.value
                ? const LoadingFull()
                : const SizedBox();
          }),
        ],
      ),
      // bottomNavigationBar:
      //     Obx(() => _bottomNavigationBar(controller.isLoading.value)),
    );
  }

  // Widget _bottomNavigationBar(bool hidden) {
  //   return Obx(() {
  //     return BottomNavigationBarWidget(
  //       currentIndex: controller.currentIndex.value,
  //       onPageChanged: (index) {
  //         if (!hidden) controller.onChangeItemBottomBar(index);
  //       },
  //       allowSelect: !hidden,
  //     );
  //   });
  // }
}
