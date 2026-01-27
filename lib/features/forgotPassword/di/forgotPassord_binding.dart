import 'package:get/get.dart';
import 'package:lhg_phom/core/data/pref/prefs.dart';
import 'package:lhg_phom/core/services/models/user/domain/usecase/save_user_use_case.dart';

import '../presentation/controller/forgotPassword_controller.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => Prefs(), fenix: true);
    Get.lazyPut(() => SaveUserUseCase(Get.find()));
    Get.lazyPut(() => ForgotPasswordController(Get.find()));
  }
}
