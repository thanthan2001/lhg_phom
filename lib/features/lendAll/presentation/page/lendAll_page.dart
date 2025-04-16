import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/ui/widgets/textfield/custom_textfield_widget.dart';
import '../../../../../../core/configs/app_colors.dart';
import '../../../../../../core/routes/routes.dart';
import '../../../../../../core/ui/widgets/text/text_widget.dart';
import '../controller/lendAll_controller.dart';
import '../../../../../../core/services/model/lend_model.dart';

class LendAllPage extends GetView<LendAllController> {
  const LendAllPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Scaffold(
          appBar: _buildAppBar(),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: _searchBar(context),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: Obx(() {
                  final items = controller.formlendItems;
                  if (items.isEmpty) {
                    return const Center(
                      child: TextWidget(
                        text: 'Không tìm thấy kết quả.',
                        color: AppColors.black,
                        size: 16,
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 5),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildLendItem(item, AppColors.secondary);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const TextWidget(
        text: "Danh sách mượn",
        color: AppColors.white,
        size: 18,
      ),
      backgroundColor: AppColors.primary,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
        onPressed: Get.back,
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: controller.searchLendItems,
            decoration: InputDecoration(
              hintText: "Nhập để tìm kiếm...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary1,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            onPressed: () => FocusScope.of(context).unfocus(),
            icon: const Icon(Icons.search, size: 30, color: AppColors.white),
          ),
        ),
        IconButton(
          onPressed: () => _showFilterBottomSheet(context),
          icon: const Icon(Icons.tune, size: 40, color: AppColors.black),
        ),
      ],
    );
  }

  Widget _buildLendItem(LendItemModel item, Color cardColor) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.lendDetails, arguments: item.idMuon),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: cardColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildColumn("Người mượn", item.idNguoiMuon?.userName ?? '---'),
            _buildColumn("Đơn vị", item.donVi ?? '---'),
            _buildColumn("Ngày mượn", item.ngayMuon ?? '---'),
          ],
        ),
      ),
    );
  }

  Widget _buildColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextWidget(text: title, fontWeight: FontWeight.bold),
        TextWidget(text: value),
      ],
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: AppColors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: TextWidget(
                    text: "Bộ lọc tìm kiếm",
                    fontWeight: FontWeight.bold,
                    size: 18,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDropdown(
                  label: "Trạng thái",
                  items: const [
                    'đăng ký mượn',
                    'đang mượn',
                    'đã trả',
                    'chưa trả',
                    'trả chưa đủ',
                  ],
                  value: controller.selectedTrangThai,
                ),
                _buildDateRangePicker(context),
                _buildDropdown(
                  label: "Đơn vị",
                  items:
                      controller.allLendItems
                          .map((e) => e.donVi ?? '')
                          .toSet()
                          .toList(),
                  value: controller.selectedDonVi,
                ),
                _buildFilterTextField("Mã phông", controller.selectedMaPhom),
                _buildFilterTextField(
                  "Người mượn",
                  controller.selectedUserName,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          controller.resetFilters();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text("Xoá bộ lọc"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          controller.applyFilters();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.check),
                        label: const Text("Áp dụng"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterTextField(String label, RxString controllerValue) {
    final textController = TextEditingController(text: controllerValue.value);
    textController.selection = TextSelection.fromPosition(
      TextPosition(offset: textController.text.length),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: CustomTextFieldWidget(
        controller: textController,
        onChanged: (value) => controllerValue.value = value,
        labelText: label,
        borderRadius: 10,
        enableColor: AppColors.grey,
        obscureText: false,
        textColor: AppColors.black,
        labelColor: AppColors.black,
      ),
    );
  }

  Widget _buildDropdown({
  required String label,
  required List<String> items,
  required RxString value,
}) {
  return Obx(() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value.value.isEmpty ? null : value.value,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary1),
          ),
          labelText: label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
            fontSize: 14,
          ),
          filled: true,
          fillColor: AppColors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
        ),
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.grey,
        ),
        dropdownColor: AppColors.white,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          );
        }).toList(),
        onChanged: (val) {
          if (val != null) value.value = val;
        },
      ),
    );
  });
}


  Widget _buildDateRangePicker(BuildContext context) {
    return Obx(() {
      final from = controller.selectedDateFrom.value;
      final to = controller.selectedDateTo.value;

      String label = "Chọn ngày mượn";
      if (from != null && to != null) {
        label =
            "Từ ${from.day}/${from.month}/${from.year} đến ${to.day}/${to.month}/${to.year}";
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: GestureDetector(
          onTap: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              controller.selectedDateFrom.value = picked.start;
              controller.selectedDateTo.value = picked.end;
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: "Khoảng ngày mượn",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
                const Icon(
                  Icons.calendar_month,
                  color: AppColors.primary,
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
