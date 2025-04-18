import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/configs/app_colors.dart';
import '../../../../../../core/ui/widgets/text/text_widget.dart';
import '../controller/shelf_controller.dart';

class ShelfPage extends GetView<ShelfController> {
  const ShelfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Obx(() => controller.shelves.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _buildShelfList()),
      ),
    );
  }

  // AppBar widget
  AppBar _buildAppBar() {
    return AppBar(
      title: TextWidget(text: "list_shelf".tr, size: 18, color: AppColors.white),
      centerTitle: true,
      backgroundColor: AppColors.primary,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: AppColors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  // Danh sách kệ
  Widget _buildShelfList() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: ListView.builder(
        itemCount: controller.shelves.length,
        itemBuilder: (context, index) {
          final shelf = controller.shelves[index];
          return _buildShelfItem(shelf);
        },
      ),
    );
  }

  // Widget hiển thị từng kệ
  Widget _buildShelfItem(Map<String, dynamic> shelf) {
    return GestureDetector(
      onTap: () {

      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: AppColors.primary2.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary2, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildColumn("shelf_code".tr, shelf["shelfCode"]),
            _buildColumn("shelf_name".tr, shelf["shelfName"]),
            _buildColumn("total_phom".tr, shelf["totalForms"].toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextWidget(text: title, fontWeight: FontWeight.bold),
        TextWidget(text: value),
      ],
    );
  }
}
