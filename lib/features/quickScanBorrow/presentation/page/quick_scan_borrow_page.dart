import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/configs/app_colors.dart';
import 'package:lhg_phom/core/ui/dialogs/showSearchableSelectionDialog.dart';
import 'package:lhg_phom/core/ui/widgets/button/button_widget.dart';
import 'package:lhg_phom/core/ui/widgets/text/text_widget.dart';
import 'package:lhg_phom/core/ui/widgets/textfield/custom_dropdownfield_widget.dart';
import 'package:lhg_phom/core/ui/widgets/textfield/custom_textfield_widget.dart';

import '../controller/quick_scan_borrow_controller.dart';

class QuickScanBorrowPage extends GetView<QuickScanBorrowController> {
  const QuickScanBorrowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Obx(
          () => Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDepartmentSelection(),
                    const SizedBox(height: 12),
                    _buildUserIdInput(),
                    const SizedBox(height: 12),
                    _buildStatusCard(),
                    const SizedBox(height: 12),
                    _buildScanControl(),
                    const SizedBox(height: 12),
                    _buildResultTable(),
                    const SizedBox(height: 12),
                    _buildInvalidSection(),
                  ],
                ),
              ),
              if (controller.isLoading.value || controller.isSaving.value)
                Container(
                  color: Colors.black.withValues(alpha: 0.35),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
        bottomNavigationBar: _buildFinishButton(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const TextWidget(
        text: 'Quick Scan Borrow',
        color: AppColors.white,
        size: 18,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: AppColors.primary,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white),
        onPressed: Get.back,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.clear_all_rounded, color: Colors.white),
          onPressed: controller.onClear,
          tooltip: 'Xóa phiên quét',
        ),
      ],
    );
  }

  Widget _buildDepartmentSelection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Obx(
          () => CustomDropdownField(
            labelText: 'Đơn vị mượn',
            selectedValue: controller.selectedDepartment.value,
            onTap:
                () => showSearchableSelectionDialog(
                  title: 'Chọn đơn vị',
                  itemList: controller.departmentList.toList(),
                  selectedItem: controller.selectedDepartment.value,
                  onSelected: controller.onChangeDepartment,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildKpiTile(
                    title: 'EPC đã quét',
                    value: controller.totalScannedEPCs.value.toString(),
                    color: AppColors.primary1,
                    icon: Icons.radar_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildKpiTile(
                    title: 'Đôi hợp lệ',
                    value: controller.totalScannedPairs.value.toString(),
                    color: AppColors.green,
                    icon: Icons.check_circle_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              controller.lastScanStatus.value.isEmpty
                  ? 'Trạng thái: Chưa quét'
                  : 'Trạng thái: ${controller.lastScanStatus.value}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserIdInput() {
    return CustomTextFieldWidget(
      labelText: 'Nhập số thẻ người mượn',
      controller: controller.userIdController,
      obscureText: false,
      textColor: AppColors.black,
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildKpiTile({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScanControl() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: ButtonWidget(
              height: 48,
              backgroundColor:
                  controller.isScanning.value
                      ? AppColors.yellow
                      : AppColors.primary,
              textColor: Colors.white,
              borderRadius: 8,
              ontap: controller.toggleScan,
              text: controller.isScanning.value ? 'Dừng quét' : 'Bắt đầu quét',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultTable() {
    return Obx(() {
      if (controller.inventoryData.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Text(
            'Chưa có dữ liệu quét hợp lệ. Nhấn Bắt đầu quét để đọc EPC.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        );
      }

      return Container(
        height: 360,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 900,
            child: DataTable2(
              minWidth: 900,
              headingRowHeight: 44,
              dataRowHeight: 42,
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
              columns:
                  controller.headers
                      .map(
                        (header) => DataColumn2(
                          label: Text(
                            header,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                      .toList(),
              rows:
                  controller.inventoryData.map((row) {
                    final diff = int.tryParse(row[4]) ?? 0;
                    final pairs = double.tryParse(row[5]) ?? 0.0;

                    Color? bg;
                    if (diff > 0) {
                      bg = Colors.orange.withValues(alpha: 0.12);
                    } else if (pairs > 0) {
                      bg = Colors.green.withValues(alpha: 0.12);
                    }

                    return DataRow(
                      color: WidgetStateProperty.all(bg),
                      cells: row.map((cell) => DataCell(Text(cell))).toList(),
                    );
                  }).toList(),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildInvalidSection() {
    return Obx(() {
      final hasInvalid =
          controller.invalidRfids.isNotEmpty ||
          controller.outRfids.isNotEmpty ||
          controller.lostRfids.isNotEmpty;
      if (!hasInvalid) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.05),
          border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RFID lỗi trong phiên',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text('Không có dữ liệu: ${controller.invalidRfids.length}'),
            Text('Đã mượn: ${controller.outRfids.length}'),
            Text('Mất/hỏng: ${controller.lostRfids.length}'),
          ],
        ),
      );
    });
  }

  Widget _buildFinishButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Obx(
        () => ButtonWidget(
          text: 'Hoàn tất tạo phiếu nhanh',
          height: 50,
          ontap:
              (controller.isSaving.value ||
                      controller.scannedEpcList.isEmpty ||
                      controller.hasRfidErrors)
                  ? () {}
                  : controller.onFinish,
          backgroundColor:
              (controller.isSaving.value ||
                      controller.scannedEpcList.isEmpty ||
                      controller.hasRfidErrors)
                  ? Colors.grey
                  : AppColors.green,
        ),
      ),
    );
  }
}
