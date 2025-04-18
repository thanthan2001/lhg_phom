import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/services/model/lend_model.dart';

class LendAllController extends GetxController {
  var formlendItems = <LendItemModel>[].obs;
  var allLendItems = <LendItemModel>[];

  var searchQuery = ''.obs;

  // Bộ lọc
  var selectedTrangThai = ''.obs;
  var selectedNgayMuon = ''.obs;
  var selectedDonVi = ''.obs;
  var selectedMaPhom = ''.obs;
  var selectedUserName = ''.obs;
  var selectedDateFrom = Rxn<DateTime>();
  var selectedDateTo = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    formLend();
  }

  void formLend() {
    allLendItems = exampleLendItems.where((item) => item.trangThai != 'đăng ký mượn').toList();
    formlendItems.value = allLendItems;
  }

  void searchLendItems(String query) {
    searchQuery.value = query.toLowerCase();
    applyFilters();
  }

  void applyFilters() {
  final dateFormatter = DateFormat('dd/MM/yyyy');

  formlendItems.value = allLendItems.where((item) {
    final name = item.idNguoiMuon?.userName?.toLowerCase() ?? '';
    final donVi = item.donVi?.toLowerCase() ?? '';
    final ngayMuonStr = item.ngayMuon ?? '';
    final maPhom = item.maPhom?.toLowerCase() ?? '';
    final trangThai = item.trangThai?.toLowerCase() ?? '';

    DateTime? itemDate;
    try {
      itemDate = dateFormatter.parseStrict(ngayMuonStr);
    } catch (e) {
      // Không parse được ngày → bỏ qua item này
      return false;
    }

    final inDateRange =
        (selectedDateFrom.value == null || itemDate.isAfter(selectedDateFrom.value!.subtract(const Duration(days: 1)))) &&
        (selectedDateTo.value == null || itemDate.isBefore(selectedDateTo.value!.add(const Duration(days: 1))));

    final matches = 
        (selectedTrangThai.value.isEmpty || trangThai == selectedTrangThai.value.toLowerCase()) &&
        (selectedDonVi.value.isEmpty || donVi == selectedDonVi.value.toLowerCase()) &&
        (selectedMaPhom.value.isEmpty || maPhom.contains(selectedMaPhom.value.toLowerCase())) &&
        (selectedUserName.value.isEmpty || name.contains(selectedUserName.value.toLowerCase())) &&
        inDateRange;

    return matches;
  }).toList();
}



  void resetFilters() {
  selectedTrangThai.value = '';
  selectedDonVi.value = '';
  selectedMaPhom.value = '';
  selectedUserName.value = '';
  selectedDateFrom.value = null;
  selectedDateTo.value = null;
  applyFilters();
}
}
