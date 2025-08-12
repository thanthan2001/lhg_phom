import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/configs/app_colors.dart';
import 'package:lhg_phom/core/ui/widgets/textfield/custom_textfield_widget.dart';
import 'package:lhg_phom/core/ui/widgets/button/button_widget.dart';
import 'package:lhg_phom/core/ui/widgets/text/text_widget.dart';

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
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            80,
          ), // Thêm padding dưới
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSearchCard(), // Sử dụng Card cho khu vực tìm kiếm
              const SizedBox(height: 20),
              Obx(() {
                // Tách riêng widget Loading
                if (controller.isLoading.value &&
                    controller.searchResult.isEmpty) {
                  return _buildLoadingState();
                }
                // Tách riêng widget trạng thái ban đầu/rỗng
                if (controller.searchResult.isEmpty) {
                  return _buildInitialState();
                }
                // Widget hiển thị kết quả
                return _buildResultsContent();
              }),
            ],
          ),
        ),
        // Bottom nav bar không đổi
        bottomNavigationBar: Obx(
          () =>
              controller.searchResult.isNotEmpty
                  ? _buildDoneButton()
                  : const SizedBox.shrink(),
        ),
      ),
    );
  }

  // --- WIDGETS ĐƯỢC THIẾT KẾ LẠI ---

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

  Widget _buildSearchCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchInput(),
            const SizedBox(height: 16),
            _buildSearchButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchInput() {
    return CustomTextFieldWidget(
      height: 55, // Tăng chiều cao để hợp với icon
      controller: controller.bill_br_id,
      labelText: "Mã số đơn mượn",
      prefixIcon: Icon(Icons.qr_code_scanner, color: AppColors.primary),
      textColor: AppColors.black,
      borderRadius: 8,
      obscureText: false,
    );
  }

  Widget _buildSearchButton() {
    return Obx(
      () => ButtonWidget(
        width: double.infinity,
        height: 48,
        backgroundColor: AppColors.primary1,

        ontap:
            controller.isLoading.value
                ? () {
                  print("Đang tìm kiếm...");
                }
                : controller.onSearch,
        borderRadius: 8,
        text: 'Tìm Kiếm',
        textColor: AppColors.white,
        child:
            controller.isLoading.value && controller.searchResult.isEmpty
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
                    const TextWidget(
                      text: 'Đang tìm...',
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      size: 14,
                    ),
                  ],
                )
                : const TextWidget(
                  text: 'Tìm Kiếm',
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  size: 14,
                ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.only(top: 50.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildInitialState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: AppColors.grey.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            const TextWidget(
              text: "Vui lòng nhập mã số đơn mượn và nhấn Tìm kiếm để bắt đầu.",
              color: AppColors.grey,
              textAlign: TextAlign.center,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsContent() {
    return Column(
      children: [
        _buildProgressInfoCard(),
        const SizedBox(height: 20),
        _buildScanControlCard(),
        const SizedBox(height: 20),
        _buildSearchResultsTable(),
      ],
    );
  }

  Widget _buildProgressInfoCard() {
    // Tính toán tổng số lượng
    double totalToReturn = 0;
    for (var item in controller.searchResult) {
      totalToReturn += (item['SoLuong'] as num?) ?? 0;
    }

    return Card(
      elevation: 2,
      color: AppColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const TextWidget(
              text: "Tiến độ quét:",
              fontWeight: FontWeight.bold,
            ),
            Obx(
              () => TextWidget(
                text:
                    "${controller.listFinalRFID.length / 2} / $totalToReturn Đôi",
                fontWeight: FontWeight.bold,
                size: 18,
                color: AppColors.primary,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildRfidScanButtons(),
            const SizedBox(height: 16),
            _buildTotalPhomNotBinding(),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalPhomNotBinding() {
    return CustomTextFieldWidget(
      labelText: "Số đôi chưa gán dữ liệu",
      controller: controller.totalPhomNotBindingController,
      keyboardType: TextInputType.number,
      textColor: AppColors.black,
      borderRadius: 8,
      prefixIcon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
      obscureText: false,
    );
  }

  Widget _buildRfidScanButtons() {
    return Obx(() {
      if (controller.isScanning.value) {
        return ButtonWidget(
          height: 48,
          backgroundColor: AppColors.yellow,
          textColor: Colors.white,
          ontap: controller.stopContinuousScan,
          borderRadius: 8,
          text: 'Dừng quét',
        );
      }

      return Row(
        children: [
          Expanded(
            child: ButtonWidget(
              height: 48,
              backgroundColor: AppColors.grey2,
              textColor: AppColors.black,
              ontap:
                  controller.listFinalRFID.isEmpty
                      ? () {
                        print("Không có dữ liệu để xóa");
                      }
                      : controller.onClearScanned,
              text: "Clear",
              borderRadius: 8,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ButtonWidget(
              height: 48,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              ontap: controller.startContinuousScan,
              borderRadius: 8,
              text: 'Bắt đầu Scan',
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSearchResultsTable() {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 24.0,
          headingRowColor: MaterialStateColor.resolveWith(
            (_) => AppColors.primary.withOpacity(0.1),
          ),
          dataRowColor: MaterialStateColor.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.primary.withOpacity(0.2);
            }
            return Colors.white;
          }),
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          columns: const <DataColumn>[
            DataColumn(label: Text('Mã Phom')),
            DataColumn(label: Text('Dạng Phom')),
            DataColumn(label: Text('Size')),
            DataColumn(label: Text('Đã Phát')),
            DataColumn(label: Text('Đang Quét')),
          ],
          rows:
              controller.searchResult.map((item) {
                int index = controller.searchResult.indexOf(item);
                return DataRow(
                  color: MaterialStateProperty.resolveWith<Color?>((
                    Set<MaterialState> states,
                  ) {
                    // Màu xen kẽ cho các dòng
                    return index.isEven ? Colors.grey.withOpacity(0.05) : null;
                  }),
                  cells: <DataCell>[
                    DataCell(
                      Center(
                        child: Text(item['LastMatNo']?.toString() ?? 'N/A'),
                      ),
                    ),
                    DataCell(
                      Center(child: Text(item['LastNo']?.toString() ?? 'N/A')),
                    ),
                    DataCell(
                      Center(
                        child: Text(item['LastSize']?.toString() ?? 'N/A'),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: TextWidget(
                          text: item['SoLuong']?.toString() ?? 'N/A',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: Obx(
                          () => Chip(
                            label: Text(
                              (item['scannedCount'].value).toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildDoneButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Obx(
        () => ButtonWidget(
          text: "Hoàn Tất",
          height: 50,
          borderRadius: 12,
          ontap:
              controller.listFinalRFID.isNotEmpty
                  ? controller.onFinish
                  : () {
                    print("Không có dữ liệu để hoàn tất");
                  },
          backgroundColor:
              controller.listFinalRFID.isNotEmpty
                  ? AppColors.primary
                  : AppColors.grey,
        ),
      ),
    );
  }
}
