import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/configs/app_colors.dart';
import 'package:lhg_phom/core/ui/widgets/textfield/custom_textfield_widget.dart';
import 'package:lhg_phom/core/ui/widgets/button/button_widget.dart';
import 'package:lhg_phom/core/ui/widgets/text/text_widget.dart';
import '../../../../core/ui/dialogs/showSearchableSelectionDialog.dart';
import '../../../../core/ui/widgets/textfield/custom_dropdownfield_widget.dart';
import '../controller/lendGive_controller.dart';

class LendGivePage extends GetView<LendGiveController> {
  const LendGivePage({super.key});

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
                _buildLabelTextField(
                  "Số thẻ người mượn:",
                  controller.userIDController,
                ),
                _buildLabelTextField(
                  "Tên người mượn:",
                  controller.userNameController,
                ),
                const SizedBox(height: 10),
                _buildDepartmentAndDate(),
                const SizedBox(height: 10),
                _buildCodePhomAndSum(),
                const SizedBox(height: 10),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     ButtonWidget(
                //       width: 100,
                //       height: 48,
                //       backgroundColor: AppColors.primary1,
                //       textColor: Colors.white,
                //       ontap: controller.onSearch,
                //       text: "Search",
                //       borderRadius: 5,
                //     ),
                //   ],
                // ),
                const SizedBox(height: 10),
                Obx(
                  () => TextWidget(
                    text: 'Tổng số lượng: ${controller.LastSum.value}',
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                    size: 16,
                  ),
                ),

                const SizedBox(height: 10),

                Obx(() => buildInventoryTable()),
                const SizedBox(height: 20),

                _buildRfidScan(),
                const SizedBox(height: 10),
                Obx(() {
                  if (controller.epcDataTable.isEmpty) {
                    return const Text('Không có dữ liệu RFID nào');
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('RFID')),
                        DataColumn(label: Text('LastMatNo')),
                        DataColumn(label: Text('LastName')),
                        DataColumn(label: Text('LastType')),
                        DataColumn(label: Text('Material')),
                        DataColumn(label: Text('LastSize')),
                        DataColumn(label: Text('LastSide')),
                        DataColumn(label: Text('DateIn')),
                      ],
                      rows:
                          controller.epcDataTable.map((item) {
                            return DataRow(
                              cells: [
                                DataCell(Text(item['RFID'] ?? '')),
                                DataCell(Text(item['LastMatNo'] ?? '')),
                                DataCell(Text(item['LastName'] ?? '')),
                                DataCell(Text(item['LastType'] ?? '')),
                                DataCell(Text(item['Material'] ?? '')),
                                DataCell(Text(item['LastSize'] ?? '')),
                                DataCell(Text(item['LastSide'] ?? '')),
                                DataCell(
                                  Text(item['DateIn']?.toString() ?? ''),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  );
                }),
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
        text: "Phát mượn phom",
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
          child: Obx(
            () => CustomDropdownField(
              labelText: 'Mã số phom:',
              selectedValue: controller.selectedCodePhom.value,
              onTap:
                  () => showSearchableSelectionDialog(
                    title: 'Chọn mã số phom',
                    itemList: controller.codePhomList,
                    selectedItem: controller.selectedCodePhom.value,
                    onSelected:
                        (val) => controller.selectedCodePhom.value = val,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ButtonWidget(
            width: 100,
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
                    itemList: controller.departmentList,
                    selectedItem: controller.selectedDepartment.value,
                    onSelected:
                        (val) => controller.selectedDepartment.value = val,
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
                height: 40,
                labelText: "Ngày mượn:",
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
                icon: const Icon(
                  Icons.calendar_month_outlined,
                  size: 30,
                  color: AppColors.primary1,
                ),
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: Get.context!,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
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
          child: ButtonWidget(
            width: 100,
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
          flex: 1,
          child: ButtonWidget(
            width: 100,
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
            width: 100,
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ButtonWidget(
        text: "Hoàn tất",
        height: 50,
        ontap: controller.onFinish,
      ),
    );
  }

  Widget buildInventoryTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(color: Colors.black54),
        defaultColumnWidth: FixedColumnWidth(120.0),
        children: [
          _buildTableRow(controller.headers, isHeader: true),
          ...controller.inventoryData
              .map((row) => _buildTableRow(row))
              .toList(),
        ],
      ),
    );
  }

  TableRow _buildTableRow(
    List<String> cells, {
    bool isHeader = false,
    int? index,
  }) {
    return TableRow(
      decoration: BoxDecoration(
        color:
            isHeader
                ? Colors.grey[300]
                : (index != null && index % 2 == 0
                    ? Colors.grey[100]
                    : Colors.transparent), // ví dụ tô màu dòng chẵn
      ),
      children:
          cells.map((cell) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                cell,
                style: TextStyle(
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                  fontSize: isHeader ? 16 : 14,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }).toList(),
    );
  }
}
