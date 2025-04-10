import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/configs/app_colors.dart';
import '../../../../../../core/routes/routes.dart';
import '../../../../../../core/ui/widgets/button/button_widget.dart';
import '../../../../../../core/ui/widgets/text/text_widget.dart';
import '../controller/phom_controller.dart';

class PhomPage extends GetView<PhomController> {
  const PhomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            // Nút thêm phom
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ButtonWidget(
                height: 70,
                backgroundColor: AppColors.primary1,
                text: "Nhấn để thêm phom",
                fontSize: 16,
                ontap: () {
                  Get.toNamed(Routes.bindingPhom);
                },
              ),
            ),
            // Danh sách phom
            Expanded(
              child: Obx(() {
                if (controller.phoms.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: controller.phoms.length,
                  itemBuilder: (context, index) {
                    final phom = controller.phoms[index];
                    return GestureDetector(
                      onTap: () {
                      
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary, width: 1),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildColumnData("Mã phom", phom["phomCode"]),
                                  _buildColumnData("Tên phom", phom["phomName"]),
                                  _buildColumnData("Chất liệu", phom["material"]),
                                  _buildColumnData("Tổng số", phom["total"].toString()),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm hiển thị dữ liệu theo cột
  Widget _buildColumnData(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextWidget(text:title, fontWeight: FontWeight.bold),
        TextWidget(text: value),
      ],
    );
  }
}
