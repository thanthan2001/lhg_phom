import 'package:get/get.dart';

class LendController extends GetxController {
  var registerlendItems = <Map<String, dynamic>>[].obs;
  var formlendItems = <Map<String, dynamic>>[].obs; 

  @override
  void onInit() {
    super.onInit();
    registerLend();
    formLend();
  }

  // Dữ liệu mẫu
  void registerLend() {
    registerlendItems.value = [
      {"nguoiMuon": "Nguyễn Văn A", "donVi": "ADDGG", "ngayMuon": "19/2/2002" },
      {"nguoiMuon": "Nguyễn Văn B", "donVi": "ADDGG", "ngayMuon": "19/2/2002" },
      {"nguoiMuon": "Nguyễn Văn N", "donVi": "ADDGG", "ngayMuon": "19/2/2002" },
      {"nguoiMuon": "Nguyễn Văn A", "donVi": "ADDGG", "ngayMuon": "19/2/2002" },
    ];
  }

  void formLend() {
    formlendItems.value = [
      {"nguoiMuon": "Nguyễn Văn B", "donVi": "ADDGG", "ngayMuon": "19/2/2002" },
      {"nguoiMuon": "Nguyễn Văn B", "donVi": "ADDGG", "ngayMuon": "19/2/2002" },
      {"nguoiMuon": "Nguyễn Văn V", "donVi": "ADDGG", "ngayMuon": "19/2/2002" },
      {"nguoiMuon": "Nguyễn Văn V", "donVi": "ADDGG", "ngayMuon": "19/2/2002" },
      {"nguoiMuon": "Nguyễn Văn C", "donVi": "ADDGG", "ngayMuon": "19/2/2002" },
      {"nguoiMuon": "Nguyễn Văn C", "donVi": "ADDGG", "ngayMuon": "19/2/2002" },
    ];
  }
}
