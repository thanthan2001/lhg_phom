import 'package:get/get.dart';
import 'package:lhg_phom/core/data/pref/prefs.dart';

import '../presentation/controller/phom_controller.dart';

class PhomBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => Prefs(), fenix: true);
    Get.lazyPut(() => PhomController());
  }
}
