import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/configs/app_colors.dart';
import '../../../../core/ui/dialogs/showSearchableSelectionDialog.dart';
import '../../../../core/ui/widgets/textfield/custom_dropdownfield_widget.dart';

import '../controller/update_binding_controller.dart';

class UpdateBindingPage extends GetView<UpdateBindingController> {
  const UpdateBindingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Update Binding',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            try {
              if (Get.context != null) {
                Navigator.of(Get.context!).pop();
              }
            } catch (e) {
              print('Error closing page: $e');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search Section Card
              _buildSearchSection(),
              const SizedBox(height: 16),

              // Search Results
              Obx(() {
                if (controller.isSearching.value) {
                  return const Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
                if (controller.searchResults.isEmpty) {
                  return const SizedBox.shrink();
                }
                return _buildSearchResultsCard();
              }),
              const SizedBox(height: 16),

              // Side Selection Card
              _buildSideSelectionCard(),
              const SizedBox(height: 16),

              // Scan Controls Card
              _buildScanControlsCard(),
              const SizedBox(height: 16),

              // Scan Status Card
              _buildScanStatusCard(),
              const SizedBox(height: 20),

              // Finish Button
              _buildDoneButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.search, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Thông tin tìm kiếm',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCodePhomAndSum(),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSelectSize(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tên phom:",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            controller.phomName.value.isEmpty
                                ? "Chưa chọn phom"
                                : controller.phomName.value,
                            style: TextStyle(
                              fontSize: 15,
                              color:
                                  controller.phomName.value.isEmpty
                                      ? Colors.grey
                                      : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.onSearch,
                icon: const Icon(Icons.search, size: 20),
                label: const Text(
                  "Tìm kiếm",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.table_chart, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Kết quả tìm kiếm',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSearchResultsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildSideSelectionCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.switch_left, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Chọn bên',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildLeftRightButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildScanControlsCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.nfc, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Điều khiển quét RFID',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRfidScan(),
          ],
        ),
      ),
    );
  }

  Widget _buildScanStatusCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [AppColors.primary.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.qr_code_scanner, size: 48, color: AppColors.primary),
            const SizedBox(height: 12),
            const Text(
              "Trạng thái quét",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Text(
                controller.totalCount.value == 0
                    ? "Chưa quét thẻ nào"
                    : "Đã quét: ${controller.totalCount.value} chiếc",
                style: TextStyle(
                  fontSize: 24,
                  color:
                      controller.totalCount.value == 0
                          ? Colors.grey
                          : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () =>
                  controller.isScanning.value
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Đang quét...",
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                      : const SizedBox.shrink(),
            ),
          ],
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
                if (controller.isLoading.value) return;

                showSearchableSelectionDialog2(
                  title: 'Chọn mã số phom',
                  itemList: controller.codePhomList.toList(),
                  selectedItem: controller.selectedCodePhom.value,
                  onSelectedAndCallApi: (val) async {
                    await controller.getInforbyLastMatNo(val);
                  },
                  onSelected: (val) => controller.selectedCodePhom.value = val,
                );
              },
            ),
          ),
        ),
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
                height: 54,
                width: 100,
                child: Center(child: CircularProgressIndicator()),
              )
              : Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.onStartRead,
                  icon: const Icon(Icons.play_arrow, size: 20),
                  label: const Text(
                    "Scan",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
          const SizedBox(width: 10),
          controller.isLoading.value
              ? const SizedBox(
                height: 54,
                width: 100,
                child: Center(child: CircularProgressIndicator()),
              )
              : Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.onClear,
                  icon: const Icon(Icons.clear_all, size: 20),
                  label: const Text(
                    "Clear",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                ),
              ),

          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: controller.onStopRead,
              icon: const Icon(Icons.stop, size: 20),
              label: const Text(
                "Stop",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
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
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: controller.onFinish,
        icon: const Icon(Icons.check_circle, size: 24),
        label: const Text(
          "Hoàn tất",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftRightButtons() {
    return Obx(() {
      final isLeft = controller.isLeftSide.value;
      return Row(
        children: [
          Expanded(
            child: _buildSideButton(
              "Trái",
              Icons.arrow_back,
              isLeft,
              controller.onSelectLeft,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSideButton(
              "Phải",
              Icons.arrow_forward,
              !isLeft,
              controller.onSelectRight,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSideButton(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient:
            isSelected
                ? LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                )
                : null,
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
                : null,
      ),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.transparent : Colors.grey[200],
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? AppColors.primary : Colors.grey[400]!,
              width: isSelected ? 2 : 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultsTable() {
    const List<String> columnKeys = [
      'LastMatNo',
      'LastName',
      'LastType',
      'LastNo',
      'LastBrand',
      'Material',
      'LastSize',
      'LastQty',
      'BindingCount',
      'Scanning',
    ];

    const List<String> columnHeaders = [
      'Mã VT',
      'Tên Phom',
      'Loại',
      'Mã phom',
      'Nhãn Hiệu',
      'Chất Liệu',
      'Size',
      'SL',
      'Binding (Đôi)',
      'Đang quét',
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            border: TableBorder.all(color: Colors.grey.shade300, width: 1),
            headingRowColor: WidgetStateProperty.all(
              AppColors.primary.withOpacity(0.1),
            ),
            columnSpacing: 20,
            headingRowHeight: 48,
            dataRowMinHeight: 40,
            dataRowMaxHeight: 50,
            columns: List<DataColumn>.generate(
              columnHeaders.length,
              (index) => DataColumn(
                label: Text(
                  columnHeaders[index],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            rows:
                controller.searchResults.map((item) {
                  return DataRow(
                    cells:
                        columnKeys.map((key) {
                          var cellValue = item[key]?.toString() ?? '';
                          if (item[key] is String) {
                            cellValue = (item[key] as String).trim();
                          }
                          return DataCell(
                            Text(
                              cellValue,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}
