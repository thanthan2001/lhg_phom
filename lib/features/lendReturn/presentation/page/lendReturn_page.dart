import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/configs/app_colors.dart';
import 'package:lhg_phom/core/ui/widgets/button/button_widget.dart';
import 'package:lhg_phom/core/ui/widgets/text/text_widget.dart';
import 'package:lhg_phom/core/ui/dialogs/showSearchableSelectionDialog.dart';
import 'package:lhg_phom/core/ui/widgets/textfield/custom_dropdownfield_widget.dart';
import '../controller/lendReturn_controller.dart';

class LendReturnPage extends GetView<LendReturnController> {
  const LendReturnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDepartmentSelection(),
              const SizedBox(height: 20),
              _buildTotalScanCard(),
              const SizedBox(height: 20),
              _buildScanControlCard(), 

              const SizedBox(height: 20),
              Obx(() {
                if (controller.scannedItems.isNotEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                    child: TextWidget(
                      text: "Kết quả quét hợp lệ:",
                      fontWeight: FontWeight.bold,
                      size: 16,
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              _buildResultsContent(),
            ],
          ),
        ),
        bottomNavigationBar: Obx(
          () =>
              controller.scannedItems.isNotEmpty
                  ? _buildDoneButton()
                  : const SizedBox.shrink(),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const TextWidget(
        text: "Trả Phom",
        color: AppColors.white,
        size: 18,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: AppColors.primary,
      centerTitle: true,
      elevation: 2,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.white,
          size: 20,
        ),
        onPressed: Get.back,
      ),
    );
  }

  Widget _buildDepartmentSelection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () => CustomDropdownField(
            labelText: 'Đơn vị trả phom:',
            selectedValue: controller.selectedDepartment.value,
            onTap:
                () => showSearchableSelectionDialog(
                  title: 'Chọn đơn vị',
                  itemList: controller.departmentList.toList(),
                  selectedItem: controller.selectedDepartment.value,
                  onSelected: (val) {
                    controller.selectedDepartment.value = val;
                    controller.selectedDepartmentId.value =
                        controller.depNameToIdMap[val] ?? "";
                  },
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalScanCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const TextWidget(
                    text: "Tổng chip đã quét", 
                    color: AppColors.grey,
                    size: 13,
                  ),
                  const SizedBox(height: 2),
                  Obx(
                    () => TextWidget(
                      text:
                          "${controller.totalScannedEPCs.value}", 
                      fontWeight: FontWeight.bold,
                      size: 24,
                      color: AppColors.purple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanControlCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const TextWidget(
                    text: "Phom hợp lệ",
                    color: AppColors.grey,
                    size: 13,
                  ),
                  const SizedBox(height: 2),

                  Obx(
                    () => TextWidget(
                      text:
                          "${double.parse((controller.listFinalRFID.length / 2).toString())}",
                      fontWeight: FontWeight.bold,
                      size: 24,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(flex: 7, child: _buildRfidScanButtons()),
          ],
        ),
      ),
    );
  }

  Widget _buildRfidScanButtons() {
    return Obx(() {
      final isScanning = controller.isScanning.value;
      return Row(
        children: [
          SizedBox(
            width: 50,
            child: ButtonWidget(
              height: 48,
              backgroundColor: AppColors.grey2,
              ontap:
                  controller.scannedItems.isEmpty &&
                          controller.returnedTags.isEmpty &&
                          controller.unborrowedTags.isEmpty
                      ? () {}
                      : controller.onClearScanned,
              borderRadius: 8,
              text: 'Xóa',
              child: const Icon(
                Icons.clear_all_rounded,
                color: AppColors.black,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ButtonWidget(
              height: 48,
              backgroundColor: isScanning ? AppColors.yellow : Colors.green,
              textColor: Colors.white,
              ontap:
                  isScanning
                      ? controller.stopContinuousScan
                      : controller.startContinuousScan,
              borderRadius: 8,
              text: '',
              child:
                  isScanning
                      ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Dừng'),
                        ],
                      )
                      : const Text('Scan'),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildResultsContent() {
    return Obx(() {
      if (controller.scannedItems.isEmpty) {
        return _buildInitialState();
      }
      return _buildScannedItemsList();
    });
  }

  Widget _buildInitialState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rss_feed,
              size: 60,
              color: AppColors.grey.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            const TextWidget(
              text: "Vui lòng nhấn 'Scan' để bắt đầu quét phom.",
              color: AppColors.grey,
              textAlign: TextAlign.center,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannedItemsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.scannedItems.length,
      itemBuilder: (context, index) {
        final item = controller.scannedItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TextWidget(
                            text: "Mã phom",
                            size: 12,
                            color: AppColors.grey,
                          ),
                          const SizedBox(height: 2),
                          TextWidget(
                            text: item['LastNo']?.toString() ?? 'N/A',
                            fontWeight: FontWeight.bold,
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8, width: 16),
                      Column(
                        children: [
                          const TextWidget(
                            text: "Size",
                            size: 12,
                            color: AppColors.grey,
                          ),
                          const SizedBox(height: 2),
                          TextWidget(
                            text: item['LastSize']?.toString() ?? 'N/A',
                            fontWeight: FontWeight.bold,
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 60,
                  child: VerticalDivider(thickness: 1, width: 24),
                ),
                Column(
                  children: [
                    const TextWidget(
                      text: "Đã quét",
                      size: 12,
                      color: AppColors.grey,
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => Chip(
                        label: Text(
                          (item['scannedCount'].value).toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildDoneButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Obx(
        () => ButtonWidget(
          text: controller.isFinishing.value ? "" : "Hoàn Tất",
          height: 50,
          borderRadius: 12,
          ontap: controller.isFinishing.value ? () {} : controller.onFinish,
          backgroundColor: AppColors.primary,
          child:
              controller.isFinishing.value
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                  : null,
        ),
      ),
    );
  }
}
