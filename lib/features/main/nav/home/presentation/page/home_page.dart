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
                padding: const EdgeInsets.only(bottom: 10),
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

  Widget _buildExpandableCard(Map<String, dynamic> item, int index) {
    return Obx(() {
      final isExpanded = controller.expandedIndex.value == index;
      final textColor = isExpanded ? AppColors.white : AppColors.black;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isExpanded ? AppColors.primary : AppColors.white,
          border: Border.all(color: AppColors.primary, width: 1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (!isExpanded)
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: InkWell(
          onTap: () => controller.toggleExpand(index),
          borderRadius: BorderRadius.circular(11),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildHeaderCell(
                                'phom_code'.tr,
                                textColor,
                                flex: 3,
                              ),
                              _buildHeaderCell(
                                'phom_name'.tr,
                                textColor,
                                flex: 3,
                              ),
                              _buildHeaderCell(
                                'material'.tr,
                                textColor,
                                flex: 2,
                              ),
                              _buildHeaderCell('total'.tr, textColor, flex: 2),
                            ],
                          ),
                          const SizedBox(height: 4),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildValueCell(
                                '${item['code']}',
                                textColor,
                                flex: 3,
                              ),
                              _buildValueCell(
                                '${item['name']}',
                                textColor,
                                flex: 3,
                              ),
                              _buildValueCell(
                                '${item['material']}',
                                textColor,
                                flex: 2,
                              ),
                              _buildValueCell(
                                '${_calculateTotal(item['details'])}',
                                textColor,
                                flex: 2,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.arrow_forward_ios_rounded,
                        color: isExpanded ? AppColors.white : AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                if (isExpanded) _buildExpandedDetails(item['details']),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeaderCell(String text, Color color, {int flex = 1}) {
    return Expanded(
      flex: flex,

      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 13,
          ),
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _buildValueCell(String text, Color color, {int flex = 1}) {
    return Expanded(
      flex: flex,

      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(color: color, fontSize: 14),
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 15),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "input_to_search".tr,
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ButtonWidget(
            borderRadius: 8,
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

  Widget _buildExpandedDetails(List<Map<String, dynamic>> details) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        children:
            details.map((detail) {
              return Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailColumn("size".tr, "${detail['size']}"),
                    _buildDetailColumn("quantity".tr, "${detail['quantity']}"),
                    _buildDetailColumn("inventory".tr, "${detail['stock']}"),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextWidget(
            text: label,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
            color: AppColors.black,
          ),
          const SizedBox(height: 2),
          TextWidget(
            text: value,
            color: AppColors.black,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  int _calculateTotal(List<Map<String, dynamic>> details) {
    return details.fold<int>(0, (sum, item) => sum + (item['quantity'] as int));
  }

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextSpanWidget(
            text1: "hello".tr,
            text2: " LHG",
            fontWeight2: FontWeight.bold,
            textColor1: Colors.white,
            textColor2: Colors.white,
            size: 16,
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _HomeInfo(
                icon: Icons.insert_drive_file_outlined,
                title: "total_phom".tr,
                value: controller.items[0]["TongPhom"].toString(),
              ),
              _HomeInfo(
                icon: Icons.grid_view_rounded,
                title: "total_phom_code".tr,
                value: controller.items.length.toString(),
              ),
              _HomeInfo(
                icon: Icons.warehouse_outlined,
                title: "total_inventory".tr,
                value: controller.items[0]["TongTonKho"].toString(),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 4),
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
