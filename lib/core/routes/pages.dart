import 'package:get/get.dart';

import '../../features/login/di/login_binding.dart';
import '../../features/login/presentation/page/login_page.dart';
import '../../features/main/di/main_binding.dart';
import '../../features/main/nav/lend/di/lend_binding.dart';
import '../../features/main/nav/lend/presentation/page/lend_page.dart';
import '../../features/main/nav/phom/di/phom_binding.dart';
import '../../features/main/nav/phom/presentation/page/phom_page.dart';
import '../../features/main/nav/shelf/di/home_binding.dart';
import '../../features/main/nav/shelf/di/shelf_binding.dart';
import '../../features/main/nav/shelf/presentation/page/home_page.dart';
import '../../features/main/nav/shelf/presentation/page/shelf_page.dart';
import '../../features/main/nav/user/di/user_binding.dart';
import '../../features/main/nav/user/presentation/page/user_page.dart';
import '../../features/main/presentation/page/main_page.dart';
import '../../features/splash/di/splash_binding.dart';
import '../../features/splash/presentation/page/splash_page.dart';
import 'routes.dart';

class Pages {
  static const initial = Routes.none;
  static const main = Routes.main;
  static final routes = [
    // màng hình chờ loading
    GetPage(
      name: Routes.none,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),

    // màng hình login
    GetPage(
      name: Routes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),

    // // màng hình chính
    GetPage(
      name: Routes.main,
      page: () => const MainPage(),
      binding: MainBinding(),
    ),
  ];
}
