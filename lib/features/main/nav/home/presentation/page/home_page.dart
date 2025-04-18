import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/configs/app_colors.dart';
import 'package:lhg_phom/core/ui/widgets/button/button_widget.dart';
import 'package:lhg_phom/core/ui/widgets/text/text_pand_widget.dart';
import 'package:lhg_phom/core/ui/widgets/text/text_widget.dart';
import 'package:lhg_phom/features/main/nav/home/presentation/controller/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _searchBar(),
            Expanded(
              child: ListView.builder(
                itemCount: controller.items.length,
                itemBuilder:
                    (context, index) =>
                        _buildExpandableCard(controller.items[index], index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card Phom
  Widget _buildExpandableCard(Map<String, dynamic> item, int index) {
    return Obx(() {
      final isExpanded = controller.expandedIndex.value == index;
      final textColor = _getColorBasedOnExpand(isExpanded);

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isExpanded ? AppColors.primary : AppColors.white,
          border: Border.all(color: AppColors.primary, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => controller.toggleExpand(index),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoTextColumn(
                          'phom_code'.tr,
                          '${item['code']}',
                          textColor,
                        ),
                        _buildInfoTextColumn(
                          'phom_name'.tr,
                          '${item['name']}',
                          textColor,
                        ),
                        _buildInfoTextColumn(
                          'material'.tr,
                          '${item['material']}',
                          textColor,
                        ),
                        _buildInfoTextColumn(
                          'total'.tr,
                          '${_calculateTotal(item['details'])}',
                          textColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.arrow_forward_ios_rounded,
                    color: textColor,
                    size: 24,
                  ),
                ],
              ),
            ),
            if (isExpanded) _buildExpandedDetails(item['details']),
          ],
        ),
      );
    });
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "input_to_search".tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ButtonWidget(
            borderRadius: 5,
            height: 48,
            width: 100,
            backgroundColor: AppColors.primary1,
            text: "search".tr,
            ontap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTextColumn(String label, String value, Color color) {
    return Column(
      children: [
        TextWidget(text: label, fontWeight: FontWeight.bold, color: color),
        TextWidget(text: value, color: color),
      ],
    );
  }

  Color _getColorBasedOnExpand(bool isExpanded) =>
      isExpanded ? AppColors.white : AppColors.black;

  Widget _buildExpandedDetails(List<Map<String, dynamic>> details) {
    return Column(
      children:
          details.map((detail) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDetailColumn("size".tr, "${detail['size']}"),
                  _buildDetailColumn("quantity".tr, "${detail['quantity']}"),
                  _buildDetailColumn("inventory".tr, "${detail['stock']}"),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Column(
      children: [
        TextWidget(text: label, fontWeight: FontWeight.bold),
        TextWidget(text: value),
      ],
    );
  }

  int _calculateTotal(List<Map<String, dynamic>> details) {
    return details.fold<int>(0, (sum, item) => sum + (item['quantity'] as int));
  }

  // AppBar
  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(color: AppColors.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextSpanWidget(
            text1: "hello".tr,
            text2: "LHG",
            fontWeight2: FontWeight.bold,
            textColor1: Colors.white,
            textColor2: Colors.white,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _HomeInfo(
                icon: Icons.insert_drive_file,
                title: "total_phom".tr,
                value: "19.000",
              ),
              _HomeInfo(
                icon: Icons.grid_view,
                title: "total_phom_code".tr,
                value: "300",
              ),
              _HomeInfo(
                icon: Icons.warehouse,
                title: "total_inventory".tr,
                value: "15.000",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _HomeInfo({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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
}
