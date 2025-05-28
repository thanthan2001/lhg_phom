// LendReturnPage.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/configs/app_colors.dart';
import 'package:lhg_phom/core/ui/widgets/textfield/custom_textfield_widget.dart';
import 'package:lhg_phom/core/ui/widgets/button/button_widget.dart';
import 'package:lhg_phom/core/ui/widgets/text/text_widget.dart';

import '../../../../core/ui/dialogs/showSearchableSelectionDialog.dart';
import '../../../../core/ui/widgets/textfield/custom_dropdownfield_widget.dart';
import '../controller/lendReturn_controller.dart'; // Đảm bảo đúng đường dẫn

class LendReturnPage extends GetView<LendReturnController> {
  const LendReturnPage({super.key});

  // THÊM PHƯƠNG THỨC NÀY
  // Trong LendReturnPage.dart

  @override
  Widget build(BuildContext context) {
    // Inject controller nếu chưa được inject ở binding
    // Get.lazyPut(() => LendReturnController(Get.find())); // Ví dụ

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        // controller.selectedRowIndex.value = -1; // Giữ nếu bảng inventoryData dùng
      },
      child: SafeArea(
        child: Scaffold(
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabelTextField("Mã số đơn mượn:", controller.bill_br_id),
                // _buildLabelTextField(
                //   "Tên người mượn:",
                //   controller
                //       .userNameController, // Đảm bảo controller này được khởi tạo giá trị
                // ),
                // const SizedBox(height: 10),
                // _buildDepartmentAndDate(),
                const SizedBox(height: 10),
                _buildCodePhomAndSum(), // Nút Search ở đây
                // const SizedBox(height: 10), // Xóa bớt 1 SizedBox

                // THÊM BẢNG KẾT QUẢ TÌM KIẾM VÀO ĐÂY
                _buildSearchResultsTable(),

                // const SizedBox(height: 10), // Giữ lại nếu _buildTable() được dùng
                // _buildTable(), // Bảng inventoryData cũ, bỏ comment nếu cần
                const SizedBox(height: 20),
                _buildRfidScan(),
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

  Widget _buildLabelTextField(String label, TextEditingController ctrl) {
    // đổi tên controller thành ctrl để tránh nhầm lẫn
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
              controller: ctrl, // sử dụng ctrl
              obscureText: false,
              borderRadius: 5,
              textColor: AppColors.black,
              // Thêm readOnly nếu muốn các trường này không cho sửa trực tiếp
              // readOnly: (label == "Tên người mượn:"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsTable() {
    return Obx(() {
      if (controller.isLoading.value && controller.searchResult.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (controller.searchResult.isEmpty && !controller.isLoading.value) {
        return const SizedBox.shrink();
      }

      if (controller.searchResult.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 16.0, bottom: 8.0, left: 10.0),
              child: TextWidget(
                text: "Kết quả tìm kiếm:",
                color: AppColors.black,
                fontWeight: FontWeight.bold,
                size: 16,
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 18.0,
                headingRowColor: MaterialStateColor.resolveWith(
                  (states) => AppColors.grey3,
                ),
                columns: <DataColumn>[
                  DataColumn(
                    label: Expanded(
                      // Sử dụng Expanded để Text chiếm hết không gian và canh giữa
                      child: Text(
                        'ID BILL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center, // CANH GIỮA HEADER
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'LastMatNo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center, // CANH GIỮA HEADER
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'LastSum',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center, // CANH GIỮA HEADER
                      ),
                    ),
                    numeric: true, // Vẫn giữ numeric nếu muốn căn phải số
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'TotalScanOut',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center, // CANH GIỮA HEADER
                      ),
                    ),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'Scanned',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center, // CANH GIỮA HEADER
                      ),
                    ),
                    numeric: true,
                  ),
                ],
                rows:
                    controller.searchResult.map((item) {
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(
                            Center(
                              // CANH GIỮA CELL
                              child: Text(item['ID_bill']?.toString() ?? 'N/A'),
                            ),
                          ),
                          DataCell(
                            Center(
                              // CANH GIỮA CELL
                              child: Text(
                                item['LastMatNo']?.toString() ?? 'N/A',
                              ),
                            ),
                          ),
                          DataCell(
                            Center(
                              // CANH GIỮA CELL
                              child: Text(item['LastSum']?.toString() ?? '0'),
                            ),
                          ),
                          DataCell(
                            Center(
                              // CANH GIỮA CELL
                              child: Text(
                                item['TotalScanOut']?.toString() ?? '0',
                              ),
                            ),
                          ),
                          DataCell(
                            Center(
                              // CANH GIỮA CELL
                              child: Obx(() {
                                return Text(controller.ScannedCount.toString());
                              }),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ],
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildCodePhomAndSum() {
    return Row(
      children: [
        // Expanded(
        //   child: Obx(
        //     () => CustomDropdownField(
        //       labelText: 'Mã số phom:',
        //       selectedValue: controller.selectedCodePhom.value,
        //       onTap:
        //           () => showSearchableSelectionDialog(
        //             title: 'Chọn mã số phom',
        //             itemList:
        //                 controller.codePhomList
        //                     .toList(), // Chuyển RxList thành List
        //             selectedItem: controller.selectedCodePhom.value,
        //             onSelected:
        //                 (val) => controller.selectedCodePhom.value = val,
        //           ),
        //     ),
        //   ),
        // ),
        // const SizedBox(width: 10),
        Expanded(
          child: ButtonWidget(
            width: 100, // width không có tác dụng khi Expanded
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

  Widget _buildDepartmentAndDate() {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => CustomDropdownField(
              labelText: 'Đơn vị:',
              selectedValue: controller.selectedDepartment.value,
              onTap:
                  () => showSearchableSelectionDialog(
                    title: 'Chọn đơn vị',
                    itemList:
                        controller.departmentList
                            .toList(), // Chuyển RxList thành List
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
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              CustomTextFieldWidget(
                enableColor: AppColors.grey2,
                height: 40, // Nên đồng nhất height với CustomDropdownField
                labelText: "Ngày mượn:",
                labelColor: AppColors.black,
                controller: controller.dateController,
                obscureText: false,
                borderRadius: 5,
                textColor: AppColors.black,
                keyboardType: TextInputType.datetime,
                // readOnly: true, // Ngăn sửa trực tiếp, chỉ cho chọn qua DatePicker
              ),
              IconButton(
                icon: const Icon(
                  Icons.calendar_month_outlined,
                  size: 30, // Điều chỉnh size nếu cần
                  color: AppColors.primary1,
                ),
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: Get.context!, // Đảm bảo Get.context! hợp lệ
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2101), // Sửa lỗi lastDate
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
          child: ButtonWidget(
            height: 48,
            backgroundColor: AppColors.grey,
            textColor: Colors.white,
            ontap: controller.onClear,
            text: "Clear",
            borderRadius: 5,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 1, // flex: 1 là mặc định cho Expanded
          child: ButtonWidget(
            height: 48,
            backgroundColor: AppColors.yellow,
            textColor: Colors.white,
            ontap: controller.onStop,
            text: "Stop",
            borderRadius: 5,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ButtonWidget(
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

  Widget _buildDoneButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ), // Giữ padding này cho ButtonWidget
      child: ButtonWidget(
        text: "Hoàn tất",
        height: 50,
        ontap: controller.onFinish,
        // width: double.infinity, // Nếu muốn nút chiếm toàn bộ chiều rộng trong Padding
      ),
    );
  }

  // Giữ lại _buildTable và _buildTableRow nếu bạn vẫn dùng bảng inventoryData
  Widget _buildTable() {
    return RawScrollbar(
      controller: controller.tableScrollController,
      thumbVisibility: true,
      trackVisibility: true,
      radius: const Radius.circular(5),
      thickness: 2, // Nên là double
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
              constraints: BoxConstraints(
                minWidth: Get.width - 20,
              ), // -20 là padding của body
              child: Table(
                border: TableBorder.all(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
                defaultColumnWidth: const IntrinsicColumnWidth(),
                children: [
                  _buildTableRow([
                    'Size',
                    'Tồn kho',
                    'Trái',
                    'Phải',
                    'Số lượng',
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
                  onTap: () {
                    if (index != null) {
                      // Kiểm tra index không null
                      controller.selectedRowIndex.value = index;
                    }
                  },
                  child: cell,
                );
          }).toList(),
    );
  }
}
