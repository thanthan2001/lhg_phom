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
          const Divider(color: AppColors.grey, thickness: 1),
          _buildRfidScan(),
          const SizedBox(height: 10),
          _buildListRfidScan(),
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
            onChanged: (value) {
              controller.callLastName(value);
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: [
              TextWidget(
                text: "Tên phom:",
                size: 16,
                fontWeight: FontWeight.bold,
              ),
              Obx(
                () => TextWidget(
                  text:
                      controller.phomName.value.isEmpty
                          ? "Chưa chọn phom"
                          : controller.phomName.value,
                  size: 16,
                  color: AppColors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
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
            ontap: controller.searchPhomBinding,
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

  Widget _buildRfidScan() {
    return Obx(() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          controller.isLoading.value
              ? const SizedBox(
                height: 50,
                width: 100,
                child: Center(child: CircularProgressIndicator()),
              )
              : Expanded(
                child: SizedBox(
                  height: 50,
                  width: 100,
                  child: ButtonWidget(
                    backgroundColor: AppColors.primary1,
                    textColor: AppColors.white,
                    ontap: controller.onScanMultipleTags,
                    text: "Scan",
                    borderRadius: 5,
                    fontSize: 16,
                  ),
                ),
              ),

          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                TextWidget(
                  text: "Thực hiện quét RFID",
                  size: 16,
                  fontWeight: FontWeight.bold,
                ),
                TextWidget(
                  text:
                      controller.listTagRFID.isEmpty
                          ? "Chưa quét.."
                          : "Đã quét: ${controller.listTagRFID.length} thẻ",
                  size: 16,
                  color: AppColors.black,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildListRfidScan() {
    return Obx(
      () => Container(
        constraints: const BoxConstraints(maxHeight: 400),
        padding: const EdgeInsets.all(0),
        child:
            controller.isLoading.value
                ? SizedBox(child: CircularProgressIndicator())
                : controller.listTagRFID.isEmpty
                ? const SizedBox()
                : Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: AppColors.grey, width: 0.5),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.listTagRFID.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: AppColors.grey3,
                        margin: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                          child: TextWidget(
                            text: controller.listTagRFID[index],
                            size: 15,
                            color: AppColors.black,
                          ),
                        ),
                      );
                    },
                  ),
                ),
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
                    'Loại Phom',
                    'Thương hiệu',
                    'Chất liệu',
                    'Kích thước',
                    'Số lượng',
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
