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

  var expandedIndex = (-1).obs;
  var isExpanded = false.obs;
  var items =
      [
        {
          'code': 'JDF123',
          'name': 'JDF123',
          'material': 'Nhựa',
          'details': [
            {'size': 36, 'quantity': 1200, 'stock': 1000},
            {'size': 37, 'quantity': 1500, 'stock': 1100},
          ],
        },
        {
          'code': 'JDF124',
          'name': 'JDF124',
          'material': 'Kim loại',
          'details': [
            {'size': 38, 'quantity': 1300, 'stock': 900},
            {'size': 39, 'quantity': 1100, 'stock': 700},
          ],
        },
        {
          'code': 'JDF123',
          'name': 'JDF123',
          'material': 'Nhựa',
          'details': [
            {'size': 36, 'quantity': 1200, 'stock': 1000},
            {'size': 37, 'quantity': 1500, 'stock': 1100},
          ],
        },
        {
          'code': 'JDF124',
          'name': 'JDF124',
          'material': 'Kim loại',
          'details': [
            {'size': 38, 'quantity': 1300, 'stock': 900},
            {'size': 39, 'quantity': 1100, 'stock': 700},
          ],
        },
        {
          'code': 'JDF123',
          'name': 'JDF123',
          'material': 'Nhựa',
          'details': [
            {'size': 36, 'quantity': 1200, 'stock': 1000},
            {'size': 37, 'quantity': 1500, 'stock': 1100},
          ],
        },
      ].obs;

  void toggleExpand(int index) {
    expandedIndex.value = (expandedIndex.value == index) ? -1 : index;
    isExpanded.value = !isExpanded.value;
  }
}
