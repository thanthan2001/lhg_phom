import 'package:get/get.dart';
import 'package:lhg_phom/core/data/pref/prefs.dart';

import '../../../../../core/services/models/user/domain/usecase/get_user_use_case.dart';
import '../presentation/controller/user_controller.dart';

class UserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => Prefs(), fenix: true);
    Get.lazyPut(() => UserController(Get.find()));
    Get.lazyPut(() => GetuserUseCase(Get.find()));
  }
}
