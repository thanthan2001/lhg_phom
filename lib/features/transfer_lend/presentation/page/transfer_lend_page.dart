import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

import '../../../../core/configs/app_colors.dart';
import '../../../../core/ui/dialogs/showSearchableSelectionDialog.dart';
import '../../../../core/ui/widgets/button/button_widget.dart';
import '../../../../core/ui/widgets/text/text_widget.dart';
import '../../../../core/ui/widgets/textfield/custom_dropdownfield_widget.dart';
import '../../../../core/ui/widgets/textfield/custom_textfield_widget.dart';
import '../controller/transfer_lend_controller.dart';

class TransferLendPage extends GetView<TransferLendController> {
  const TransferLendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transfer Lend')),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildLabelTextField("Mã số đơn mượn:", controller.bill_br_id),
              const SizedBox(height: 10),
              _buildButtonSearch(),
              const SizedBox(height: 10),
              Obx(
                () =>
                    controller.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : controller.inventoryData.isEmpty
                        ? TextWidget(
                          text: "No data found",
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        )
                        : buildInventoryTable(),
              ),
              const SizedBox(height: 20),
              Obx(
                () =>
                    controller.isShowDep.value
                        ? Column(
                          children: [
                            _buildDepartmentAndDate(),
                            const SizedBox(height: 10),
                            _buildRfidScan(),
                          ],
                        )
                        : Container(),
              ),
              const SizedBox(height: 20),
              _buildDoneButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRfidScan() {
    return Row(
      children: [
        Expanded(
          child: ButtonWidget(
            width: 100,
            height: 48,
            backgroundColor: AppColors.grey,
            textColor: Colors.white,
            ontap: controller.onClear,
            text: "Clear",
            borderRadius: 5,
          ),
        ),
        const SizedBox(width: 10),

        const SizedBox(width: 10),
        Expanded(
          child: ButtonWidget(
            width: 100,
            height: 48,
            backgroundColor: AppColors.primary1,
            textColor: Colors.white,
            ontap: controller.onScanMultipleTags,
            text: "Scan",
            borderRadius: 5,
          ),
        ),
      ],
    );
  }

  Widget _buildButtonSearch() {
    return Row(
      children: [
        Expanded(
          child: ButtonWidget(
            width: 100,
            height: 48,
            backgroundColor: AppColors.primary1,
            textColor: Colors.white,
            ontap: controller.onSearch,
            text: "Search",
            borderRadius: 5,
          ),
        ),
      ],
    );
  }

  Widget _buildLabelTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          TextWidget(
            text: label,
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            size: 16,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: CustomTextFieldWidget(
              decorationType: InputDecorationType.underline,
              enableColor: AppColors.grey2,
              height: 30,
              controller: controller,
              obscureText: false,
              borderRadius: 5,
              textColor: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(
    List<String> cells, {
    bool isHeader = false,
    int? index,
  }) {
    return TableRow(
      decoration: BoxDecoration(
        color:
            isHeader
                ? Colors.grey[300]
                : (index != null && index % 2 == 0
                    ? Colors.grey[100]
                    : Colors.transparent), 
      ),
      children:
          cells.map((cell) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                cell,
                style: TextStyle(
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                  fontSize: isHeader ? 16 : 14,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }).toList(),
    );
  }

  Widget buildInventoryTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(color: Colors.black54),
        defaultColumnWidth: FixedColumnWidth(120.0),
        children: [
          _buildTableRow(controller.headers, isHeader: true),
          ...controller.inventoryData
              .map((row) => _buildTableRow(row))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildDoneButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ButtonWidget(
        text: "Hoàn tất",
        height: 50,
        ontap: controller.onFinish,
      ),
    );
  }

  Widget _buildDepartmentAndDate() {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => CustomDropdownField(
              labelText: 'Đơn vị chuyển:',
              selectedValue: controller.selectedDepartment.value,
              onTap:
                  () => showSearchableSelectionDialog(
                    title: 'Chọn đơn vị',
                    itemList:
                        controller.departmentList
                            .toList(), 
                    selectedItem: controller.selectedDepartment.value,
                    onSelected: (val) {
                      controller.selectedDepartment.value = val;
                      controller.selectedDepartmentId.value =
                          controller.depNameToIdMap[val] ?? "";
                      print(
                        "Đơn vị được chọn: $val, ID tương ứng: ${controller.selectedDepartmentId.value}",
                      );
                    },
                  ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Obx(
            () => CustomDropdownField(
              labelText: 'Đơn vị nhận:',
              selectedValue: controller.selectedDepartmentReceiver.value,
              onTap:
                  () => showSearchableSelectionDialog(
                    title: 'Chọn đơn vị',
                    itemList:
                        controller.departmentList
                            .toList(), 
                    selectedItem: controller.selectedDepartmentReceiver.value,
                    onSelected: (val) {
                      controller.selectedDepartmentReceiver.value = val;
                      controller.selectedDepartmentReceiverId.value =
                          controller.depNameToIdMap[val] ?? "";
                      print(
                        "Đơn vị được chọn: $val, ID tương ứng: ${controller.selectedDepartmentReceiverId.value}",
                      );
                    },
                  ),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}
