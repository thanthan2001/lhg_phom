import 'package:get/get.dart';

import '../../../../../../core/services/model/lend_model.dart';

class LendController extends GetxController {
  var lendItems = <LendItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchLendItems();
  }

  void fetchLendItems() {
    lendItems.assignAll([
      LendItemModel(maPhom: "ADGGG", tenPhom: "ADDGG", soThe: "45647", ngayMuon: "19/2/2002", ngayTra: "Chưa trả"),
      LendItemModel(maPhom: "BDHJK", tenPhom: "BDHGG", soThe: "12345", ngayMuon: "20/2/2002", ngayTra: "25/2/2002"),
      LendItemModel(maPhom: "BDHJK", tenPhom: "BDHGG", soThe: "12345", ngayMuon: "20/2/2002", ngayTra: "25/2/2002"),
      LendItemModel(maPhom: "BDHJK", tenPhom: "BDHGG", soThe: "12345", ngayMuon: "20/2/2002", ngayTra: "25/2/2002"),
      LendItemModel(maPhom: "BDHJK", tenPhom: "BDHGG", soThe: "12345", ngayMuon: "20/2/2002", ngayTra: "25/2/2002"),
      LendItemModel(maPhom: "BDHJK", tenPhom: "BDHGG", soThe: "12345", ngayMuon: "20/2/2002", ngayTra: "25/2/2002"),
      LendItemModel(maPhom: "BDHJK", tenPhom: "BDHGG", soThe: "12345", ngayMuon: "20/2/2002", ngayTra: "25/2/2002"),
      LendItemModel(maPhom: "BDHJK", tenPhom: "BDHGG", soThe: "12345", ngayMuon: "20/2/2002", ngayTra: "25/2/2002"),
      LendItemModel(maPhom: "BDHJK", tenPhom: "BDHGG", soThe: "12345", ngayMuon: "20/2/2002", ngayTra: "25/2/2002"),
      // Thêm dữ liệu mẫu nếu cần
    ]);
  }
}
