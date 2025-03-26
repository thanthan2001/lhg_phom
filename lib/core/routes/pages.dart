import 'package:get/get.dart';

import '../../features/changePassword/di/changePassword_binding.dart';
import '../../features/changePassword/presentation/page/changePassword_page.dart';
import '../../features/informationUser/di/informationUser_binding.dart';
import '../../features/informationUser/presentation/page/informationUser_page.dart';
import '../../features/languageSetting/di/languageSetting_binding.dart';
import '../../features/languageSetting/presentation/page/languageSetting_page.dart';
import '../../features/login/di/login_binding.dart';
import '../../features/login/presentation/page/login_page.dart';
import '../../features/main/di/main_binding.dart';
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

    // trang thông tin người dùng
    GetPage(
      name: Routes.informationUser,
      page: () => const InformationUserPage(),
      binding: InformationUserBinding(),
    ),

    // trang đổi ngôn ngữ
    GetPage(
      name: Routes.settingLanguage,
      page: () => const LanguageSettingPage(),
      binding: LanguageSettingBinding(),
    ),

    // trang đổi mật khẩu
    GetPage(
      name: Routes.changePassword,
      page: () => const ChangePasswordPage(),
      binding: ChangePasswordBinding(),
    ),
  ];
}
