import 'package:get/get.dart';

class ShelfController extends GetxController {
  // Danh sách dữ liệu mẫu đa dạng hơn
  var shelves = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchShelves();
  }

  void fetchShelves() {
    shelves.value = [
      {"shelfCode": "A1B2C3", "shelfName": "Kệ A", "totalForms": 18500},
      {"shelfCode": "D4E5F6", "shelfName": "Kệ B", "totalForms": 19200},
      {"shelfCode": "G7H8I9", "shelfName": "Kệ C", "totalForms": 17450},
      {"shelfCode": "J1K2L3", "shelfName": "Kệ D", "totalForms": 20000},
      {"shelfCode": "M4N5O6", "shelfName": "Kệ H", "totalForms": 21050},
      {"shelfCode": "P7Q8R9", "shelfName": "Kệ F", "totalForms": 18900},
    ];
  }
}
