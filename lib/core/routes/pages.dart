import 'package:get/get.dart';

import '../../features/login/di/login_binding.dart';
import '../../features/login/presentation/page/login_page.dart';
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

    // // màng hình register
    // GetPage(
    //   name: Routes.register,
    //   page: () => const RegisterPage(),
    //   binding: RegisterBinding(),
    // ),

    // // màng hình chính
    // GetPage(
    //   name: Routes.main,
    //   page: () => const MainPage(),
    //   binding: MainBinding(),
    // ),


    // // trang home
    // GetPage(
    //   name: Routes.home,
    //   page: () => const HomePage(),
    //   binding: HomeBinding(),
    // ),

  ];
}