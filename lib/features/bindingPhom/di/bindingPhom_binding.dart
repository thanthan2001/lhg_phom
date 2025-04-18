import 'package:get/get.dart';
import 'package:lhg_phom/core/data/pref/prefs.dart';

import '../presentation/controller/bindingPhom_controller.dart';

class BindingPhomBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => Prefs(), fenix: true);
    Get.lazyPut(() => BindingPhomController());
  }
}
