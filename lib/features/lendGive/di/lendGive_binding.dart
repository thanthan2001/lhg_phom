import 'package:get/get.dart';
import 'package:lhg_phom/core/data/pref/prefs.dart';

import '../presentation/controller/lendGive_controller.dart';

class LendGiveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => Prefs(), fenix: true);
    Get.lazyPut(() => LendGiveController(Get.find()));
  }
}
