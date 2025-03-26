import 'package:flutter/material.dart';
import 'package:lhg_phom/core/configs/app_colors.dart';
import 'package:lhg_phom/core/ui/widgets/text/text_colum_widget.dart';
import 'package:lhg_phom/core/ui/widgets/text/text_pand_widget.dart';
import 'package:lhg_phom/core/ui/widgets/text/text_widget.dart';
import 'package:lhg_phom/features/main/nav/home/presentation/controller/home_controller.dart';
import 'package:get/get.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [_buildAppBar(), _buildBody()],
        ),
      ),
    );
  }

  Expanded _buildBody() {
    return Expanded(
      child: ListView.builder(
        itemCount: controller.items.length,
        itemBuilder: (context, index) {
          final item = controller.items[index];
          return _buildExpandableCard(item, index);
        },
      ),
    );
  }

  // Build Card Phom
  Widget _buildExpandableCard(Map<String, dynamic> item, int index) {
    return Obx(() {
      bool isExpanded = controller.expandedIndex.value == index;
      return Card(
        color: isExpanded ? AppColors.primary : Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => controller.toggleExpand(index),
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 6,
                      child: TextColumWidget(
                        text1: 'Mã phom',
                        text2: '${item['code']}',
                        textColor1:
                            isExpanded ? AppColors.white : AppColors.black,
                        textColor2:
                            isExpanded ? AppColors.white : AppColors.black,
                        fontWeight1: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: TextColumWidget(
                        text1: 'Tên phom',
                        text2: '${item['name']}',
                        textColor1:
                            isExpanded ? AppColors.white : AppColors.black,
                        textColor2:
                            isExpanded ? AppColors.white : AppColors.black,
                        fontWeight1: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: TextColumWidget(
                        text1: 'Chất liệu',
                        text2: '${item['material']}',
                        textColor1:
                            isExpanded ? AppColors.white : AppColors.black,
                        textColor2:
                            isExpanded ? AppColors.white : AppColors.black,
                        fontWeight1: FontWeight.bold,
                      ),
                      // Text("Chất liệu: ${item['material']}"),
                    ),
                    Expanded(
                      flex: 6,
                      child: TextColumWidget(
                        text1: 'Tổng số',
                        text2: '${_calculateTotal(item['details'])}',
                        textColor1:
                            isExpanded ? AppColors.white : AppColors.black,
                        textColor2:
                            isExpanded ? AppColors.white : AppColors.black,
                        fontWeight1: FontWeight.bold,
                      ),
                      // Text(
                      //   "Tổng số: ${_calculateTotal(item['details'])}",
                      // ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Icon(
                        color: isExpanded ? AppColors.white : AppColors.black,
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                      // onPressed: () => controller.toggleExpand(index),
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) _buildExpandedDetails(item['details'], isExpanded),
          ],
        ),
      );
    });
  }

  // Build Details Card Phom
  Widget _buildExpandedDetails(
    List<Map<String, dynamic>> details,
    bool isExpanded,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            // color: AppColors.white,
            padding: EdgeInsets.all(10),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              color: AppColors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Size số",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isExpanded ? AppColors.black : AppColors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    "Số lượng",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    "Tồn kho",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          ...details.map(
            (detail) => Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                border: Border(
                  top: BorderSide(color: AppColors.primary),
                  // top: BorderSide(color: AppColors.primary),
                  // right: BorderSide(color: AppColors.primary),
                  // left: BorderSide(color: AppColors.primary),
                ),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text("${detail['size']}")),
                  Expanded(child: Text("${detail['quantity']}")),
                  Expanded(child: Text("${detail['stock']}")),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Calculate Total
  int _calculateTotal(List<Map<String, dynamic>> details) {
    return details.fold<int>(0, (sum, item) => sum + (item['quantity'] as int));
  }
}

//Build Appbar
Container _buildAppBar() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.primary, // Thêm màu nền cho container
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextSpanWidget(
          text1: "Hello! - ",
          text2: "LHG",
          fontWeight2: FontWeight.bold,
          textColor1: Colors.white,
          textColor2: Colors.white,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoColumn(Icons.insert_drive_file, "Tổng số phom", "19.000"),
            _buildInfoColumn(Icons.grid_view, "Tổng số loại", "300"),
            _buildInfoColumn(Icons.warehouse, "Tổng tồn kho", "15.000"),
          ],
        ),
      ],
    ),
  );
}

// HEADER Info
Widget _buildInfoColumn(IconData icon, String title, String value) {
  return Column(
    children: [
      Icon(icon, color: Colors.white, size: 30),
      const SizedBox(height: 5),
      Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
