import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/features/main/nav/shelf/di/shelf_binding.dart';
import 'package:lhg_phom/features/main/nav/shelf/presentation/page/shelf_page.dart';

import '../../../../core/configs/enum.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/model/user/domain/usecase/get_user_use_case.dart';
import '../../../../core/ui/dialogs/dialogs.dart';
import '../../nav/home/presentation/page/home_page.dart';
import '../../nav/lend/di/lend_binding.dart';
import '../../nav/lend/presentation/page/lend_page.dart';
import '../../nav/phom/di/phom_binding.dart';
import '../../nav/phom/presentation/page/phom_page.dart';
import '../../nav/shelf/di/home_binding.dart';
import '../../nav/user/di/user_binding.dart';
import '../../nav/user/presentation/page/user_page.dart';

class MainController extends GetxController {
  RxInt currentIndex = 0.obs;
  final pages = <String>['/home', '/phom', '/shelf', '/lend', '/user'];
  var isLoading = false.obs;
  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/home':
        return GetPageRoute(
          settings: settings,
          page: () => const HomePage(),
          binding: HomeBinding(),
          transition: Transition.fadeIn,
        );
      case '/phom':
        return GetPageRoute(
          settings: settings,
          page: () => const PhomPage(),
          binding: PhomBinding(),
          transition: Transition.fadeIn,
        );
      case '/shelf':
        print("Navigating to ListTourPage");
        return GetPageRoute(
          settings: settings,
          page: () => const ShelfPage(),
          binding: ShelfBinding(),
          transition: Transition.fadeIn,
        );
      case '/lend':
        return GetPageRoute(
          settings: settings,
          page: () => LendPage(),
          binding: LendBinding(),
          transition: Transition.fadeIn,
        );
      case '/user':
        return GetPageRoute(
          settings: settings,
          page: () => const UserPage(),
          binding: UserBinding(),
          transition: Transition.fadeIn,
        );
      default:
        return null;
    }
  }

  void onChangeItemBottomBar(int index) {
    if (currentIndex.value == index) return;
    currentIndex.value = index;
    Get.offNamed(pages[index], id: 10);
  }
}
