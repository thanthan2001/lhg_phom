import 'package:get/get.dart';

class PhomController extends GetxController {
  var phoms = <Map<String, dynamic>>[].obs; // Danh sách phom

  @override
  void onInit() {
    super.onInit();
    loadSampleData();
  }

  // Dữ liệu mẫu
  void loadSampleData() {
    phoms.value = [
      {"phomCode": "P001", "phomName": "Phom A", "material": "Nhựa", "total": 1000},
      {"phomCode": "P002", "phomName": "Phom B", "material": "Nhựa", "total": 800},
      {"phomCode": "P003", "phomName": "Phom C", "material": "Nhựa", "total": 1200},
      {"phomCode": "P004", "phomName": "Phom D", "material": "Nhựa", "total": 500},
      {"phomCode": "P005", "phomName": "Phom E", "material": "Nhựa", "total": 1900},
    ];
  }
}
