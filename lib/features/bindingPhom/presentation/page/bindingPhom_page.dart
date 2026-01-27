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
      child: Scaffold(appBar: _buildAppBar(), body: _buildBody(context)),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const TextWidget(
        text: "Binding Phom",
        color: AppColors.white,
        size: 18,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: AppColors.primary,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
        onPressed: Get.back,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSearchCard(context),
        const SizedBox(height: 20),
        _buildRfidControlCard(context),
        const SizedBox(height: 20),
        _buildResultsCard(context),
        const SizedBox(height: 30),
        _buildDoneButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSearchCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Thông tin tìm kiếm",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMaterialAndPhom(),
            const SizedBox(height: 16),
            _buildSizeAndSearch(),
          ],
        ),
      ),
    );
  }

  Widget _buildRfidControlCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Thao tác quét RFID",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildLeftRightButtons(),
            const SizedBox(height: 20),
            _buildRfidScanButtons(),
            const SizedBox(height: 16),
            _buildScanStatus(),
            const SizedBox(height: 10),
            _buildListRfidScan(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Text(
              "Kết quả",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),

          Obx(() {
            if (controller.inventoryData.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: TextWidget(
                    text: "Không có dữ liệu.\nVui lòng thực hiện tìm kiếm.",
                    textAlign: TextAlign.center,
                    color: AppColors.grey,
                  ),
                ),
              );
            }

            final columns =
                [
                      'Mã vật tư',
                      'Tên phom',
                      'Mã phom',
                      'Loại Phom',
                      'Thương hiệu',
                      'Chất liệu',
                      'Kích thước',
                      'Số lượng',
                      'Đã quét(Đôi)',
                    ]
                    .map(
                      (label) => DataColumn(
                        label: TextWidget(
                          text: label,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                    .toList();

            return RawScrollbar(
              controller: controller.tableScrollController,
              thumbVisibility: true,
              trackVisibility: true,
              radius: const Radius.circular(5),
              thickness: 4,
              thumbColor: AppColors.primary,
              child: SingleChildScrollView(
                controller: controller.tableScrollController,
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: columns,
                  rows: List<DataRow>.generate(
                    controller.inventoryData.length,
                    (index) {
                      final rowData = controller.inventoryData[index];

                      final isSelected =
                          controller.selectedRowIndex.value == index;
                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (selected) {
                          if (selected ?? false) {
                            controller.selectedRowIndex.value = index;
                          } else {
                            if (controller.selectedRowIndex.value == index) {
                              controller.selectedRowIndex.value = -1;
                            }
                          }
                        },
                        color: MaterialStateProperty.resolveWith<Color?>((
                          Set<MaterialState> states,
                        ) {
                          if (states.contains(MaterialState.selected)) {
                            return AppColors.primary.withOpacity(0.2);
                          }
                          return null;
                        }),
                        cells:
                            rowData
                                .map((cellData) => DataCell(Text(cellData)))
                                .toList(),
                      );
                    },
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMaterialAndPhom() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: CustomTextFieldWidget(
            height: 48,
            labelText: "Mã vật tư",
            labelColor: AppColors.black,
            controller: controller.materialCodeController,
            obscureText: false,
            borderRadius: 8,
            onCompleted: (value) {
              controller.callLastName(value);

              FocusScope.of(Get.context!).nextFocus();
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextWidget(
                text: "Tên phom:",
                size: 14,
                color: AppColors.grey,
              ),
              const SizedBox(height: 4),
              Obx(
                () => TextWidget(
                  text:
                      controller.phomName.value.isEmpty
                          ? "..."
                          : controller.phomName.value,
                  size: 16,
                  fontWeight: FontWeight.w500,
                  maxLines: 2,
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
          flex: 3,
          child: Obx(
            () => CustomDropdownField(
              labelText: 'Size số:',
              selectedValue: controller.selectedSize.value,
              onTap:
                  () => showSearchableSelectionDialog(
                    title: 'Chọn size số',
                    itemList: controller.sizeList,
                    selectedItem: controller.selectedSize.value,
                    onSelected: (val) => controller.selectedSize.value = val,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ButtonWidget(
            height: 48,
            text: "Tìm kiếm",
            ontap: controller.searchPhomBinding,
            backgroundColor: AppColors.primary,
            textColor: Colors.white,
            borderRadius: 8,
            leadingIcon: const Icon(
              Icons.search,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeftRightButtons() {
    return Obx(() {
      final isLeft = controller.isLeftSide.value;

      return Row(
        children: [
          Expanded(
            child: _buildSideButton("Trái", isLeft, controller.onSelectLeft),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildSideButton("Phải", !isLeft, controller.onSelectRight),
          ),
        ],
      );
    });
  }

  Widget _buildSideButton(String label, bool isSelected, VoidCallback onTap) {
    return ButtonWidget(
      height: 48,
      text: label,
      ontap: onTap,
      textColor: isSelected ? Colors.white : AppColors.primary,
      backgroundColor: isSelected ? AppColors.primary : AppColors.white,
      isBorder: true,
      borderColor: AppColors.primary,
      borderRadius: 8,
      leadingIcon:
          isSelected
              ? const Icon(Icons.check_circle, color: Colors.white, size: 20)
              : null,
    );
  }

  Widget _buildRfidScanButtons() {
    return Obx(() {
      if (controller.isScanning.value) {
        return Row(
          children: [
            const Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Đang quét...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ButtonWidget(
                height: 50,
                backgroundColor: AppColors.red,
                textColor: AppColors.white,
                ontap: controller.onStopRead,
                text: "Stop",
                borderRadius: 8,
                fontSize: 16,
              ),
            ),
          ],
        );
      }

      return Row(
        children: [
          Expanded(
            child: ButtonWidget(
              height: 50,
              backgroundColor: Colors.green,
              textColor: AppColors.white,
              ontap: controller.onStartRead,
              text: "Scan",
              borderRadius: 8,
              fontSize: 16,
              leadingIcon: const Icon(
                Icons.wifi_tethering,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ButtonWidget(
              height: 50,
              backgroundColor: AppColors.yellow,
              textColor: AppColors.black,
              ontap: controller.onClear,
              text: "Clear",
              borderRadius: 8,
              fontSize: 16,
              leadingIcon: const Icon(Icons.clear_all, color: Colors.black),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildScanStatus() {
    return Center(
      child: Obx(
        () => TextWidget(
          text:
              controller.totalCount.value == 0
                  ? "Chưa quét đôi nào"
                  : "Đã quét: ${controller.totalCount.value} chiếc",
          size: 16,
          color: AppColors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildListRfidScan() {
    return Obx(
      () =>
          controller.TagsList.isEmpty
              ? const SizedBox.shrink()
              : Container(
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grey2, width: 1),
                ),
                child: Scrollbar(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: controller.TagsList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 8.0,
                        ),
                        child: TextWidget(
                          text: controller.TagsList[index],
                          size: 14,
                          color: AppColors.black,
                        ),
                      );
                    },
                    separatorBuilder:
                        (context, index) =>
                            const Divider(height: 1, color: AppColors.grey2),
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
        borderRadius: 12,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
