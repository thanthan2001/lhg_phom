import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/configs/app_colors.dart';
import '../../../../core/ui/dialogs/showSearchableSelectionDialog.dart';
import '../../../../core/ui/widgets/button/button_widget.dart';
import '../../../../core/ui/widgets/text/text_widget.dart';
import '../../../../core/ui/widgets/textfield/custom_dropdownfield_widget.dart';
// import '../../../../core/ui/widgets/textfield/custom_textfield_widget.dart'; // Not used, can remove
import '../controller/update_binding_controller.dart';

class UpdateBindingPage extends GetView<UpdateBindingController> {
  const UpdateBindingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Binding'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildCodePhomAndSum(),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildSelectSize(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Align text to start
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const TextWidget(
                          text: "Tên phom:",
                          size: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 8), // Add some space
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
              ),
              const SizedBox(height: 20), // Increased space
              Container(
                width: double.infinity,
                child: ButtonWidget(
                  // width: 100, // width not needed due to container
                  height: 48,
                  backgroundColor: AppColors.primary1,
                  textColor: Colors.white,
                  ontap: controller.onSearch,
                  text: "Search",
                  borderRadius: 5,
                ),
              ),
              const SizedBox(height: 10),

              _buildLeftRightButtons(),
              const SizedBox(height: 10),
              _buildShelfDropdown(),
              const SizedBox(height: 10),

              // Table for search results
              Obx(() {
                if (controller.isSearching.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.searchResults.isEmpty) {
                  // Optionally show a message if search has been performed but no results
                  // For now, just show nothing if empty before first search
                  return const SizedBox.shrink();
                }
                return _buildSearchResultsTable();
              }),
              const SizedBox(height: 10),
              _buildRfidScan(),
              const SizedBox(height: 30),

              _buildDoneButton(),
            ],
          ),
        ),
      ),
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
              onSelected: (val) => {controller.selectedShelf.value = val},
            ),
      ),
    );
  }

  Widget _buildCodePhomAndSum() {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => CustomDropdownField(
              labelText: 'Mã số phom:',
              selectedValue: controller.selectedCodePhom.value,

              onTap: () {
                if (controller.codePhomList.isEmpty &&
                    !controller.isLoading.value) {
                  Get.snackbar("Thông báo", "Không có mã phom nào để chọn.");
                  return;
                }
                if (controller.isLoading.value)
                  return; // Prevent opening if still loading

                showSearchableSelectionDialog2(
                  title: 'Chọn mã số phom',
                  itemList: controller.codePhomList.toList(),
                  selectedItem: controller.selectedCodePhom.value,
                  onSelectedAndCallApi: (val) async {
                    print('Selected Code Phom: $val');
                    // No need to set controller.selectedCodePhom.value = val here
                    // as getInforbyLastMatNo will update it.
                    await controller.getInforbyLastMatNo(val);
                  },
                  onSelected:
                      (val) =>
                          controller.selectedCodePhom.value =
                              val, // Not strictly needed if onSelectedAndCallApi handles it
                );
              },
            ),
          ),
        ),
        // const SizedBox(width: 10), // Removed as there's no second item in this row now
      ],
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
                    ontap: controller.onClear,
                    text: "Clear",
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

  Widget _buildSelectSize() {
    return Expanded(
      child: Obx(
        () => CustomDropdownField(
          labelText: 'Size:',
          selectedValue: controller.selectedSize.value,

          onTap: () {
            if (controller.sizeList.isEmpty) {
              Get.snackbar(
                "Thông báo",
                "Chưa có size cho mã phom này hoặc chưa chọn mã phom.",
              );
              return;
            }
            showSearchableSelectionDialog(
              title: 'Chọn số size',
              itemList: controller.sizeList.toList(),
              selectedItem: controller.selectedSize.value,
              onSelected: (val) => controller.selectedSize.value = val,
            );
          },
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

  Widget _buildSearchResultsTable() {
    // Define your columns based on the expected data keys plus "Scanning"
    // Ensure the keys used here match exactly what's in your searchResults maps
    const List<String> columnKeys = [
      'LastMatNo',
      'LastName',
      'LastType',
      'LastBrand',
      'Material',
      'LastSize',
      'LastQty',
      'LeftCount',
      'RightCount',
      'BindingCount',
      'Scanning',
    ];

    const List<String> columnHeaders = [
      'Mã VT',
      'Tên Phom',
      'Loại',
      'Nhãn Hiệu',
      'Chất Liệu',
      'Size',
      'SL',
      'Trái',
      'Phải',
      'Binding',
      'Scanning',
    ];

    return SingleChildScrollView(
      scrollDirection:
          Axis.horizontal, // Allows table to scroll horizontally if too wide
      child: DataTable(
        border: TableBorder.all(
          // <--- THÊM DÒNG NÀY ĐỂ CÓ BORDER ĐẦY ĐỦ
          color: Colors.grey.shade400, // Có thể tùy chỉnh màu border
          width: 1, // Có thể tùy chỉnh độ dày border
        ),
        headingRowColor: MaterialStateProperty.all(
          AppColors.grey2, // Use primary color for header background
        ),
        columnSpacing: 15, // Adjust spacing between columns
        headingRowHeight: 40,
        dataRowMinHeight: 35,
        dataRowMaxHeight: 45,
        columns: List<DataColumn>.generate(
          columnHeaders.length,
          (index) => DataColumn(
            label: Text(
              columnHeaders[index],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
        rows:
            controller.searchResults.map((item) {
              return DataRow(
                cells:
                    columnKeys.map((key) {
                      // Trim string values to avoid extra spaces affecting display
                      var cellValue = item[key]?.toString() ?? '';
                      if (item[key] is String) {
                        cellValue = (item[key] as String).trim();
                      }
                      return DataCell(
                        Text(cellValue, style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
              );
            }).toList(),
      ),
    );
  }
}
