
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/configs/app_colors.dart';
import 'package:lhg_phom/core/ui/widgets/textfield/custom_textfield_widget.dart';
import 'package:lhg_phom/core/ui/widgets/button/button_widget.dart';
import 'package:lhg_phom/core/ui/widgets/text/text_widget.dart';

import '../../../../core/ui/dialogs/showSearchableSelectionDialog.dart';
import '../../../../core/ui/widgets/textfield/custom_dropdownfield_widget.dart';
import '../controller/lendReturn_controller.dart';

class LendReturnPage extends GetView<LendReturnController> {
  const LendReturnPage({super.key});

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
        _buildLabelTextField("Số thẻ người trả:", controller.userIDController),
        _buildLabelTextField("Tên người trả:", controller.userNameController),
        const SizedBox(height: 10),
        _buildDepartmentAndDate(),
        const SizedBox(height: 10),
        _buildCodePhomAndSum(),
        const SizedBox(height: 10),
        _buildRfidScan(),
        const SizedBox(height: 10),
        _buildTable(),
        const SizedBox(height: 20),
      ],
    ),
  ),
  bottomNavigationBar: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: _buildDoneButton(),
  ),
),

      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const TextWidget(
        text: "Trả phom",
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

  Widget _buildCodePhomAndSum() {
    return Row(
      children: [
        Expanded(
          child: Obx(() => CustomDropdownField(
                labelText: 'Mã số phom:',
                selectedValue: controller.selectedCodePhom.value,
                onTap: () => showSearchableSelectionDialog(
                  title: 'Chọn mã số phom',
                  itemList: controller.codePhomList,
                  selectedItem: controller.selectedCodePhom.value,
                  onSelected: (val) => controller.selectedCodePhom.value = val,
                ),
              )),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CustomTextFieldWidget(
            enableColor: AppColors.grey2,
            height: 40,
            labelText: "Tổng số lượng:",
            labelColor: AppColors.black,
            controller: controller.sumController,
            obscureText: false,
            borderRadius: 5,
            textColor: AppColors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildDepartmentAndDate() {
    return Row(
      children: [
        Expanded(
          child: Obx(() => CustomDropdownField(
                labelText: 'Đơn vị:',
                selectedValue: controller.selectedDepartment.value,
                onTap: () => showSearchableSelectionDialog(
                  title: 'Chọn đơn vị',
                  itemList: controller.departmentList,
                  selectedItem: controller.selectedDepartment.value,
                  onSelected: (val) =>
                      controller.selectedDepartment.value = val,
                ),
              )),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              CustomTextFieldWidget(
                enableColor: AppColors.grey2,
                height: 40,
                labelText: "Ngày trả:",
                labelColor: AppColors.black,
                controller: controller.dateController,
                obscureText: false,
                borderRadius: 5,
                textColor: AppColors.black,
                keyboardType: TextInputType.datetime,
                onChanged: (value) {
                  // Xử lý validation nếu cần
                },
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month_outlined,
                    size: 30, color: AppColors.primary1),
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: Get.context!,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    controller.dateController.text =
                        "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRfidScan() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CustomTextFieldWidget(
            enableColor: AppColors.grey2,
            backgroundColor: AppColors.grey1,
            height: 40,
            labelText: "RFID:",
            labelColor: AppColors.black,
            controller: controller.rfidController,
            obscureText: false,
            borderRadius: 5,
            textColor: AppColors.black,
          ),
        ),
        const SizedBox(width: 10),
        ButtonWidget(
          width: 100,
          height: 48,
          backgroundColor: AppColors.primary1,
          textColor: Colors.white,
          ontap: controller.onScan,
          text: "Scan",
          borderRadius: 5,
        ),
      ],
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

  Widget _buildTable() {
    return RawScrollbar(
      controller: controller.tableScrollController,
      thumbVisibility: true,
      trackVisibility: true,
      radius: const Radius.circular(5),
      thickness: 2,
      thumbColor: AppColors.primary,
      trackColor: AppColors.grey3,
      trackBorderColor: AppColors.grey3,
      child: SingleChildScrollView(
        controller: controller.tableScrollController,
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Obx(
            () => ConstrainedBox(
              constraints: BoxConstraints(minWidth: Get.width - 20),
              child: Table(
                border: TableBorder.all(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
                defaultColumnWidth: const IntrinsicColumnWidth(),
                children: [
                  _buildTableRow(
                    ['Size', 'Tồn kho', 'Trái', 'Phải', 'Số lượng'],
                    isHeader: true,
                  ),
                  ...controller.inventoryData.asMap().entries.map(
                        (entry) => _buildTableRow(
                          entry.value,
                          index: entry.key,
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(List<String> values,
      {bool isHeader = false, int? index}) {
    final isSelected =
        index != null && controller.selectedRowIndex.value == index;

    return TableRow(
      decoration: BoxDecoration(
        color: isHeader
            ? AppColors.grey3
            : isSelected
                ? AppColors.primary2.withOpacity(0.3)
                : null,
      ),
      children: values.map((value) {
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
