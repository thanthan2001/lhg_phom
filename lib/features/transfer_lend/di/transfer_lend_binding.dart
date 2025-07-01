import 'package:get/get.dart';
import 'package:lhg_phom/core/services/models/user/domain/usecase/get_user_use_case.dart';
import 'package:lhg_phom/features/transfer_lend/presentation/controller/transfer_lend_controller.dart';

class TransferLendBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransferLendController>(
      () => TransferLendController(Get.find()),
    );
    Get.lazyPut(() => GetuserUseCase(Get.find()));
  }
}
