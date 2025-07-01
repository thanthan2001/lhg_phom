import 'package:get/get.dart';
import 'package:lhg_phom/core/services/models/user/domain/usecase/get_user_use_case.dart';

import '../presentation/controller/update_binding_controller.dart';

class UpdateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UpdateBindingController(Get.find()));
    Get.lazyPut(() => GetuserUseCase(Get.find()));
  }
}
