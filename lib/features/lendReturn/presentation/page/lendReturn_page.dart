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
      child: SafeArea(
        child: Scaffold(
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchInput(),
                const SizedBox(height: 10),
                _buildSearchButton(),
                const SizedBox(height: 20),
                Obx(() {
                  if (controller.isLoading.value &&
                      controller.searchResult.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.searchResult.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: TextWidget(
                          text:
                              "Vui lòng nhập mã số đơn mượn và nhấn Tìm kiếm.",
                          color: AppColors.grey,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      _buildSearchResultsTable(),
                      const SizedBox(height: 20),
                      _buildRfidScanButtons(),
                      const SizedBox(height: 20),
                      _buildTotalPhomNotBinding(),
                    ],
                  );
                }),
              ],
            ),
          ),
          bottomNavigationBar: Obx(
            () =>
                controller.searchResult.isNotEmpty
                    ? _buildDoneButton()
                    : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalPhomNotBinding() {
    return CustomTextFieldWidget(
      labelText: "Số đôi chưa gán dữ liệu",
      controller: controller.totalPhomNotBindingController,
      obscureText: false,
      keyboardType: TextInputType.number,
      textColor: AppColors.black,
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

  Widget _buildSearchInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const TextWidget(
            text: "Mã số đơn mượn:",
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: CustomTextFieldWidget(
              decorationType: InputDecorationType.underline,
              enableColor: AppColors.grey2,
              height: 40,
              controller: controller.bill_br_id,
              obscureText: false,
              borderRadius: 5,
              textColor: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return Obx(
      () => ButtonWidget(
        width: double.infinity,
        height: 48,
        backgroundColor: AppColors.primary1,
        textColor: Colors.white,
        ontap: controller.isLoading.value ? () {} : controller.onSearch,
        text:
            controller.isLoading.value && controller.searchResult.isEmpty
                ? "Đang tìm..."
                : "Tìm kiếm",
        borderRadius: 5,
      ),
    );
  }

  Widget _buildSearchResultsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 18.0,
        headingRowColor: MaterialStateColor.resolveWith((_) => AppColors.grey3),
        columns: const <DataColumn>[
          DataColumn(
            label: Expanded(
              child: Text(
                'ID BILL',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                'Mã Phom',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                'Tổng Mượn (Đôi)',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                'Đã Phát (Đôi)',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                'Đã Quét (Đôi)',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
        rows:
            controller.searchResult.map((item) {
              return DataRow(
                cells: <DataCell>[
                  DataCell(
                    Center(child: Text(item['ID_bill']?.toString() ?? 'N/A')),
                  ),
                  DataCell(
                    Center(child: Text(item['LastMatNo']?.toString() ?? 'N/A')),
                  ),
                  DataCell(
                    Center(child: Text(item['LastSum']?.toString() ?? '0')),
                  ),
                  DataCell(
                    Center(
                      child: Text(
                        ((item['TotalScanOut'] ?? 0) / 2).toInt().toString(),
                      ),
                    ),
                  ),
                  DataCell(
                    Center(
                      child: Obx(
                        () => Text(
                          controller.ScannedCount.value.toInt().toString(),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildRfidScanButtons() {
    return Obx(() {
      if (controller.isScanning.value) {
        return Row(
          children: [
            Expanded(
              child: ButtonWidget(
                height: 48,
                backgroundColor: AppColors.yellow,
                textColor: Colors.white,
                ontap: controller.stopContinuousScan,
                text: "Dừng",
                borderRadius: 5,
              ),
            ),
            const SizedBox(width: 10),
            const CircularProgressIndicator(),
          ],
        );
      }

      return Row(
        children: [
          Expanded(
            child: ButtonWidget(
              height: 48,
              backgroundColor: AppColors.grey,
              textColor: Colors.white,
              ontap:
                  controller.listFinalRFID.isEmpty
                      ? () {}
                      : controller.onClearScanned,
              text: "Clear",
              borderRadius: 5,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ButtonWidget(
              height: 48,
              backgroundColor: AppColors.primary1,
              textColor: Colors.white,
              ontap: controller.startContinuousScan,
              text: "Scan",
              borderRadius: 5,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildDoneButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Obx(
        () => ButtonWidget(
          text: "Hoàn tất",
          height: 50,
          ontap:
              controller.listFinalRFID.isNotEmpty ? controller.onFinish : () {},
          backgroundColor:
              controller.listFinalRFID.isNotEmpty
                  ? AppColors.primary
                  : AppColors.grey,
        ),
      ),
    );
  }
}
