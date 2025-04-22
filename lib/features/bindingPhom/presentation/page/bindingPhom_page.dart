import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/configs/app_colors.dart';
import 'package:lhg_phom/core/ui/widgets/textfield/custom_textfield_widget.dart';
import 'package:lhg_phom/core/ui/widgets/button/button_widget.dart';
import 'package:lhg_phom/core/ui/widgets/text/text_widget.dart';

import '../../../../core/ui/dialogs/showSearchableSelectionDialog.dart';
import '../../../../core/ui/widgets/textfield/custom_dropdownfield_widget.dart';
import '../controller/bindingPhom_controller.dart';

class BindingPhomPage extends GetView<BindingPhomController> {
  const BindingPhomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        controller.selectedRowIndex.value = -1;
      },
      child: SafeArea(
        child: Scaffold(appBar: _buildAppBar(), body: _buildBody()),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const TextWidget(
        text: "Binding Phom",
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

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _buildMaterialAndPhom(),
          const SizedBox(height: 10),
          _buildSizeAndSearch(),
          const SizedBox(height: 10),
          _buildShelfDropdown(),
          const SizedBox(height: 10),
          _buildLeftRightButtons(),
          const SizedBox(height: 10),
          _buildRfidScan(),
          const SizedBox(height: 10),
          _buildRfidStopScan(),
          const SizedBox(height: 10),
          _buildTable(),
          const SizedBox(height: 30),
          _buildDoneButton(),
        ],
      ),
    );
  }

  Widget _buildMaterialAndPhom() {
    return Row(
      children: [
        Expanded(
          child: CustomTextFieldWidget(
            enableColor: AppColors.grey2,
            height: 40,
            labelText: "Mã vật tư:",
            labelColor: AppColors.black,
            controller: controller.materialCodeController,
            obscureText: false,
            borderRadius: 5,
            textColor: AppColors.black,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Obx(
            () => CustomDropdownField(
              labelText: 'Loại phom:',
              selectedValue: controller.selectedPhomType.value,
              onTap:
                  () => showSearchableSelectionDialog(
                    title: 'Chọn loại phom',
                    itemList: controller.phomTypeList,
                    selectedItem: controller.selectedPhomType.value,
                    onSelected:
                        (val) => controller.selectedPhomType.value = val,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeAndSearch() {
    return Row(
      children: [
        Expanded(
          child: CustomTextFieldWidget(
            enableColor: AppColors.grey2,
            height: 40,
            labelText: "Size:",
            labelColor: AppColors.black,
            controller: controller.sizeController,
            obscureText: false,
            borderRadius: 5,
            textColor: AppColors.black,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ButtonWidget(
            height: 48,
            text: "Tìm kiếm",
            ontap: controller.onSearch,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            borderRadius: 5,
          ),
        ),
      ],
    );
  }

  Widget _buildShelfDropdown() {
    return Obx(
      () => CustomDropdownField(
        labelText: 'Kệ:',
        selectedValue: controller.selectedShelf.value,
        onTap:
            () => showSearchableSelectionDialog(
              title: 'Chọn kệ',
              itemList: controller.shelfList,
              selectedItem: controller.selectedShelf.value,
              onSelected: (val) => controller.selectedShelf.value = val,
            ),
      ),
    );
  }

  Widget _buildLeftRightButtons() {
    return Obx(() {
      final isLeft = controller.isLeftSide.value;
      return Row(
        children: [
          _buildSideButton("Trái", isLeft, controller.onSelectLeft),
          const SizedBox(width: 10),
          _buildSideButton("Phải", !isLeft, controller.onSelectRight),
        ],
      );
    });
  }

  Widget _buildSideButton(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: ButtonWidget(
        height: 46,
        text: label,
        ontap: onTap,
        textColor: isSelected ? AppColors.primary1 : AppColors.primary2,
        backgroundColor: isSelected ? AppColors.primary2 : AppColors.grey1,
        isBorder: true,
        borderColor: isSelected ? AppColors.primary1 : AppColors.primary2,
        borderRadius: 5,
        leadingIcon:
            isSelected
                ? const Icon(Icons.check, color: AppColors.green)
                : const SizedBox(),
      ),
    );
  }

  Widget _buildRfidStopScan() {
    return Row(
      children: [
        Obx(
          () =>
              controller.isLoadingStop.value
                  ? const SizedBox(
                    width: 100,
                    height: 48,
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : ButtonWidget(
                    width: 100,
                    height: 48,
                    backgroundColor: AppColors.primary1,
                    textColor: Colors.white,
                    ontap: controller.onStopRead,
                    text: "STOP",
                    borderRadius: 5,
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
        Obx(
          () =>
              controller.isLoading.value
                  ? const SizedBox(
                    width: 100,
                    height: 48,
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : ButtonWidget(
                    width: 100,
                    height: 48,
                    backgroundColor: AppColors.primary1,
                    textColor: Colors.white,
                    ontap: controller.onScan,
                    text: "Scan",
                    borderRadius: 5,
                  ),
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
                  _buildTableRow([
                    'Mã vật tư',
                    'Tên phom',
                    'Size',
                    'Tồn kho',
                    'Trái',
                    'Phải',
                    'Đã quét',
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
