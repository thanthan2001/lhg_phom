import 'package:get/get.dart';
import 'package:lhg_phom/core/data/pref/prefs.dart';
import 'package:lhg_phom/core/services/model/user/domain/usecase/get_user_use_case.dart';
import 'package:lhg_phom/features/splash/presentation/controller/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => Prefs(), fenix: true);
    Get.lazyPut(() => GetuserUseCase(Get.find()));
    Get.lazyPut(() => SplashController(Get.find(), Get.find()));
  }
}
