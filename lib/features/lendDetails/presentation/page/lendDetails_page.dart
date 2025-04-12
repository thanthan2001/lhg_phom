import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/configs/app_colors.dart';
import 'package:lhg_phom/core/ui/widgets/button/button_widget.dart';
import 'package:lhg_phom/core/ui/widgets/text/text_widget.dart';
import '../controller/lendDetails_controller.dart';

class LendDetailsPage extends GetView<LendDetailsController> {
  const LendDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        controller.selectedRowIndex.value = -1;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusBadge(controller.item.trangThai ?? "---"),
                const SizedBox(height: 10),
                _buildBorrowInfo(),
                const SizedBox(height: 10),
                _buildTable(),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: _buildReturnButton(),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const TextWidget(
        text: "Thông tin mượn",
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

  Widget _buildStatusBadge(String status) {
    final Color bgColor = _getStatusColor(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
          bottom: Radius.circular(0),
        ),
      ),
      child: Center(
        child: TextWidget(
          text: capitalizeFirstLetter(status),
          size: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'đăng ký mượn':
        return AppColors.green;
      case 'đang mượn':
        return AppColors.primary1;
      case 'đã trả':
        return AppColors.blue;
      case 'chưa trả':
        return AppColors.yellow;
      case 'trả chưa đủ':
        return AppColors.purple;
      default:
        return AppColors.grey;
    }
  }

  String capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  Widget _buildBorrowInfo() {
    final item = controller.item;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow("Số thẻ người mượn", item.idNguoiMuon?.userId ?? "---"),
        _infoRow("Tên người mượn", item.idNguoiMuon?.userName ?? "---"),
        _infoRow("Đơn vị", item.donVi ?? "---"),
        _infoRow("Ngày mượn", item.ngayMuon ?? "---"),
        _infoRow("Ngày trả", item.ngayTra ?? "Chưa có"),
        _infoRow("Mã số phom", item.maPhom?.toString() ?? "---"),
        _infoRow(
          "Tổng số lượng",
          controller.item.sizes
              .fold<int>(0, (sum, s) => sum + s.soLuong)
              .toString(),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: RichText(
        text: TextSpan(
          text: "- $label: ",
          style: const TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnButton() {
    return ButtonWidget(
      text: "Thực hiện trả phom",
      height: 50,
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
      ontap: controller.onFinish,
    );
  }

  Widget _buildTable() {
    return RawScrollbar(
      controller: controller.tableScrollController,
      thumbVisibility: true,
      radius: const Radius.circular(5),
      thickness: 2,
      thumbColor: AppColors.primary,
      child: SingleChildScrollView(
        controller: controller.tableScrollController,
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Obx(
            () => ConstrainedBox(
              constraints: BoxConstraints(minWidth: Get.width - 20),
              child: Table(
                border: TableBorder.all(color: AppColors.grey),
                defaultColumnWidth: const IntrinsicColumnWidth(),
                children: [
                  _buildTableRow([
                    'Size',
                    'Số lượng',
                    'Trái',
                    'Phải',
                    'Đã trả',
                    'Chưa trả',
                  ], isHeader: true),
                  ...controller.inventoryData.asMap().entries.map(
                    (entry) => _buildTableRow(entry.value, index: entry.key),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(
    List<String> values, {
    bool isHeader = false,
    int? index,
  }) {
    final isSelected =
        index != null && controller.selectedRowIndex.value == index;

    return TableRow(
      decoration: BoxDecoration(
        color:
            isHeader
                ? AppColors.grey3
                : isSelected
                ? AppColors.primary2.withOpacity(0.3)
                : null,
      ),
      children:
          values.map((value) {
            final cell = Padding(
              padding: const EdgeInsets.all(12),
              child: TextWidget(
                text: value,
                size: 14,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              ),
            );
            return isHeader
                ? cell
                : GestureDetector(
                  onTap: () => controller.selectedRowIndex.value = index,
                  child: cell,
                );
          }).toList(),
    );
  }
}
