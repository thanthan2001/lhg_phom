import 'package:get/get.dart';
import 'package:lhg_phom/core/data/pref/prefs.dart';
import 'package:lhg_phom/core/services/models/user/domain/usecase/save_user_use_case.dart';
import 'package:lhg_phom/features/login/presentation/controller/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => Prefs(), fenix: true);
    Get.lazyPut(() => SaveUserUseCase(Get.find()));
    Get.lazyPut(() => LoginController(Get.find()));
  }
}
