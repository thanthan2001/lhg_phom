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
import '../../features/transfer_lend/di/transfer_lend_binding.dart';
import '../../features/transfer_lend/presentation/page/transfer_lend_page.dart';
import '../../features/updatebinding/di/update_binding.dart';
import '../../features/updatebinding/presentation/page/update_binding_page.dart';
import 'routes.dart';

class Pages {
  static const initial = Routes.none;
  static const main = Routes.main;
  static final routes = [
    GetPage(
      name: Routes.none,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),

    GetPage(
      name: Routes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),

    GetPage(
      name: Routes.main,
      page: () => const MainPage(),
      binding: MainBinding(),
    ),

    GetPage(
      name: Routes.informationUser,
      page: () => const InformationUserPage(),
      binding: InformationUserBinding(),
    ),

    GetPage(
      name: Routes.settingLanguage,
      page: () => const LanguageSettingPage(),
      binding: LanguageSettingBinding(),
    ),

    GetPage(
      name: Routes.changePassword,
      page: () => const ChangePasswordPage(),
      binding: ChangePasswordBinding(),
    ),

    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordPage(),
      binding: ForgotPasswordBinding(),
    ),

    GetPage(
      name: Routes.bindingPhom,
      page: () => const BindingPhomPage(),
      binding: BindingPhomBinding(),
    ),

    GetPage(
      name: Routes.lendReturn,
      page: () => const LendReturnPage(),
      binding: LendReturnBinding(),
    ),

    GetPage(
      name: Routes.lendGive,
      page: () => const LendGivePage(),
      binding: LendGiveBinding(),
    ),

    GetPage(
      name: Routes.lendDetails,
      page: () => const LendDetailsPage(),
      binding: LendDetailsBinding(),
    ),

    GetPage(
      name: Routes.lendRegister,
      page: () => const LendRegisterPage(),
      binding: LendRegisterBinding(),
    ),

    GetPage(
      name: Routes.lendAll,
      page: () => const LendAllPage(),
      binding: LendAllBinding(),
    ),
    GetPage(
      name: Routes.updateBinding,
      page: () => const UpdateBindingPage(),
      binding: UpdateBinding(),
    ),
    GetPage(
      name: Routes.lendOthers,
      page: () => const TransferLendPage(),
      binding: TransferLendBinding(),
    ),
  ];
}
