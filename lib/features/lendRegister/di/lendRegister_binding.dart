import 'package:get/get.dart';
import 'package:lhg_phom/core/data/pref/prefs.dart';

import '../presentation/controller/lendRegister_controller.dart';

class LendRegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => Prefs(), fenix: true);
    Get.lazyPut(() => LendRegisterController());
  }
}
