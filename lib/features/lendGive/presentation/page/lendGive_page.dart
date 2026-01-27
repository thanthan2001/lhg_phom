import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/configs/app_colors.dart';
import 'package:lhg_phom/core/ui/widgets/textfield/custom_textfield_widget.dart';
import 'package:lhg_phom/core/ui/widgets/button/button_widget.dart';
import 'package:lhg_phom/core/ui/widgets/text/text_widget.dart';
import '../controller/lendGive_controller.dart';

class LendGivePage extends GetView<LendGiveController> {
  const LendGivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Scaffold(
          appBar: _buildAppBar(),
          body: Obx(
            () => Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  // 👉 Bọc toàn bộ bằng SingleChildScrollView
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSearchArea(),
                        const SizedBox(height: 12),
                        _buildScanStatus(),
                        const SizedBox(height: 12),
                        _buildInventoryTable(),
                        const SizedBox(height: 20),
                        _buildReceiverCardNumber(),
                        const SizedBox(height: 12),
                        // _buildTotalPhomNotBinding(),
                        // const SizedBox(height: 12),
                        _buildScanButtons(),
                      ],
                    ),
                  ),
                ),
                if (controller.isLoading.value)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          bottomNavigationBar: _buildDoneButton(),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const TextWidget(
        text: "Phát mượn phom",
        color: AppColors.white,
        size: 18,
      ),
      backgroundColor: AppColors.primary,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
        onPressed: Get.back,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.clear_all, color: Colors.white),
          onPressed: controller.onClear,
          tooltip: 'Xóa và làm mới',
        ),
      ],
    );
  }

  Widget _buildSearchArea() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 3,
          child: CustomTextFieldWidget(
            labelText: "Mã số đơn mượn",
            controller: controller.bill_br_id,
            obscureText: false,
            textColor: AppColors.black,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: ButtonWidget(
            height: 48,
            backgroundColor: AppColors.primary1,
            textColor: Colors.white,
            ontap: controller.onSearch,
            text: "Tìm kiếm",
            borderRadius: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildScanStatus() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(
                  TextSpan(
                    text: 'Đã quét: ',
                    style: const TextStyle(fontSize: 16),
                    children: [
                      TextSpan(
                        text: '${controller.totalScannedCount.value}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 18,
                        ),
                      ),
                      TextSpan(
                        text: ' / ${controller.totalExpectedCount.value} (đôi)',
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      controller.isScanning.value ? 'ĐANG QUÉT' : 'ĐÃ DỪNG',
                      style: TextStyle(
                        color:
                            controller.isScanning.value
                                ? Colors.redAccent
                                : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (controller.isScanning.value)
                      const SizedBox(
                        width: 8,
                        height: 15,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ],
            ),
            if (controller.lastScanStatus.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Trạng thái: ${controller.lastScanStatus.value}',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryTable() {
    if (!controller.isAvalableScan.value || controller.inventoryData.isEmpty) {
      return const Center(
        child: Text("Nhập mã phiếu và nhấn 'Tìm kiếm' để bắt đầu."),
      );
    }

    // Tính toán chiều cao động dựa trên số hàng
    final rowCount = controller.inventoryData.length;
    final tableHeight =
        (rowCount * 45.0) + 50.0 + 24.0; // rows + header + padding
    final maxHeight = 400.0; // Chiều cao tối đa để có thể scroll
    final actualHeight = tableHeight > maxHeight ? maxHeight : tableHeight;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      height: actualHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 1200,
          child: DataTable2(
            columnSpacing: 12,
            horizontalMargin: 12,
            minWidth: 1200,
            dataRowHeight: 45,
            headingRowHeight: 50,
            headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
            columns:
                controller.headers
                    .map(
                      (header) => DataColumn2(
                        label: Text(
                          header,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        size:
                            header == 'Tên Phom' ? ColumnSize.L : ColumnSize.M,
                      ),
                    )
                    .toList(),
            rows:
                controller.inventoryData.map((row) {
                  final scannedPairs = double.tryParse(row[6]) ?? 0.0; // pairs (min left/right)
                  final expectedPairs = double.tryParse(row[2]) ?? 0.0;
                  final diff = int.tryParse(row[5]) ?? 0;
                  Color? rowColor;

                  if (diff > 0) {
                    rowColor = Colors.red.withOpacity(0.12);
                  } else if (scannedPairs > 0 && scannedPairs < expectedPairs) {
                    rowColor = Colors.orange.withOpacity(0.12);
                  } else if (scannedPairs >= expectedPairs && expectedPairs > 0) {
                    rowColor = Colors.green.withOpacity(0.12);
                  }

                  return DataRow(
                    color: MaterialStateProperty.all(rowColor),
                    cells: row.map((cell) => DataCell(Text(cell))).toList(),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildScanButtons() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: ButtonWidget(
              height: 50,
              backgroundColor:
                  controller.isScanning.value
                      ? AppColors.yellow
                      : AppColors.primary1,
              textColor: Colors.white,
              ontap:
                  controller.isAvalableScan.value
                      ? controller.toggleScan
                      : () {},
              text: controller.isScanning.value ? "Dừng Quét" : "Bắt đầu Quét",
              borderRadius: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiverCardNumber() {
    return CustomTextFieldWidget(
      labelText: "Số thẻ người nhận",
      controller: controller.receiverCardNumberController,
      obscureText: false,
      keyboardType: TextInputType.text,
      textColor: AppColors.black,
    );
  }

  Widget _buildDoneButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Obx(
        () => ButtonWidget(
          text: "Hoàn tất",
          height: 50,
          ontap:
              (controller.isLoading.value ||
                      controller.isScanning.value ||
                      controller.scannedRfidDetailsList.isEmpty)
                  ? () {}
                  : () {
                    controller.onFinish();
                  },
          backgroundColor:
              (controller.isScanning.value ||
                      controller.scannedRfidDetailsList.isEmpty)
                  ? Colors.grey
                  : AppColors.green,
        ),
      ),
    );
  }
}
