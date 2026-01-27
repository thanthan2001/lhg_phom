import 'package:get/get.dart';
import 'package:lhg_phom/core/data/pref/prefs.dart';
import 'package:lhg_phom/features/main/nav/home/presentation/controller/home_controller.dart';

import '../../../../../core/services/models/user/domain/usecase/get_user_use_case.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => Prefs(), fenix: true);
    Get.lazyPut(() => HomeController(Get.find()));
    Get.lazyPut(() => GetuserUseCase(Get.find()));
  }
}
