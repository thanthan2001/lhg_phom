import 'package:get/get.dart';

class HomeController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var counter = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize data or perform setup tasks here
  }

  // Simulate a loading process
  Future<void> fetchData() async {
    isLoading.value = true;
    await Future.delayed(Duration(seconds: 2)); // Simulate a network call
    isLoading.value = false;
  }

  @override
  void onClose() {
    // Clean up resources here
    super.onClose();
  }
}
