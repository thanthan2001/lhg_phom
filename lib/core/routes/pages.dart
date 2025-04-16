import 'package:get/get.dart';

import '../../features/bindingPhom/di/bindingPhom_binding.dart';
import '../../features/bindingPhom/presentation/page/bindingPhom_page.dart';
import '../../features/changePassword/di/changePassword_binding.dart';
import '../../features/changePassword/presentation/page/changePassword_page.dart';
import '../../features/forgotPassword/di/forgotPassord_binding.dart';
import '../../features/forgotPassword/presentation/page/forgotPassword_page.dart';
import '../../features/informationUser/di/informationUser_binding.dart';
import '../../features/informationUser/presentation/page/informationUser_page.dart';
import '../../features/languageSetting/di/languageSetting_binding.dart';
import '../../features/languageSetting/presentation/page/languageSetting_page.dart';
import '../../features/lendAll/di/lendAll_binding.dart';
import '../../features/lendAll/presentation/page/lendAll_page.dart';
import '../../features/lendDetails/di/lendDetails_binding.dart';
import '../../features/lendDetails/presentation/page/lendDetails_page.dart';
import '../../features/lendGive/di/lendGive_binding.dart';
import '../../features/lendGive/presentation/page/lendGive_page.dart';
import '../../features/lendRegister/di/lendRegister_binding.dart';
import '../../features/lendRegister/presentation/page/lendRegister_page.dart';
import '../../features/lendReturn/di/lendReturn_binding.dart';
import '../../features/lendReturn/presentation/page/lendReturn_page.dart';
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

    // trang quên mật khẩu
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordPage(),
      binding: ForgotPasswordBinding(),
    ),

    //trang trang binding phom
    GetPage(
      name: Routes.bindingPhom,
      page: () => const BindingPhomPage(),
      binding: BindingPhomBinding(),
    ),

    //trang trả phom
    GetPage(
      name: Routes.lendReturn,
      page: () => const LendReturnPage(),
      binding: LendReturnBinding(),
    ),

    //trang phát cho mượn
    GetPage(
      name: Routes.lendGive,
      page: () => const LendGivePage(),
      binding: LendGiveBinding(),
    ),

    //trang chi tiết cho mượn
    GetPage(
      name: Routes.lendDetails,
      page: () => const LendDetailsPage(),
      binding: LendDetailsBinding(),
    ),

    //trang đăng ký cho mượn
    GetPage(
      name: Routes.lendRegister,
      page: () => const LendRegisterPage(),
      binding: LendRegisterBinding(),
    ),

    //trang tất cả cho mượn
    GetPage(
      name: Routes.lendAll,
      page: () => const LendAllPage(),
      binding: LendAllBinding(),
    ),
  ];
}
