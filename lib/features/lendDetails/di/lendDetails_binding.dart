import 'package:get/get.dart';
import 'package:lhg_phom/core/data/pref/prefs.dart';

import '../presentation/controller/lendDetails_controller.dart';



class LendDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => Prefs(), fenix: true);
    Get.lazyPut(() => LendDetailsController());
  }
}
