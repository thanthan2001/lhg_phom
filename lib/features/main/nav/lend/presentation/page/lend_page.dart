import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/ui/widgets/button/button_widget.dart';
import '../../../../../../core/configs/app_colors.dart';
import '../../../../../../core/routes/routes.dart';
import '../../../../../../core/ui/widgets/text/text_widget.dart';
import '../controller/lend_controller.dart';
import '../../../../../../core/services/model/lend_model.dart';

class LendPage extends GetView<LendController> {
  const LendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                _buildButtonRow(),
                const SizedBox(height: 10),
                _buildSection(
                  title: "lend_register_list".tr,
                  onViewAll: () {
                    Get.toNamed(Routes.lendRegister);
                  },
                  items: controller.registerlendItems,
                  cardColor: AppColors.primary3,
                ),
                _buildSection(
                  title: "lend_give_list".tr,
                  onViewAll: () {
                    Get.toNamed(Routes.lendAll);
                  },
                  items: controller.formlendItems,
                  cardColor: AppColors.secondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonRow() {
    return Row(
      children: [
        _buildButton("lend_give".tr, AppColors.blue, Routes.lendGive),
        const SizedBox(width: 10),
        _buildButton("lend_return".tr, AppColors.yellow, Routes.lendReturn),
        const SizedBox(width: 10),
        _buildButton(
          "lend_others".tr,
          AppColors.red,
          Routes.lendOthers,
        ),
      ],
    );
  }

  Widget _buildButton(String text, Color color, String route) {
    return Expanded(
      child: ButtonWidget(
        width: (Get.width - 20) / 3,
        height: 80,
        text: text,
        backgroundColor: color,
        textColor: AppColors.black,
        ontap: () => Get.toNamed(route),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required VoidCallback onViewAll,
    required RxList<LendItemModel> items,
    required Color cardColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            TextWidget(
              text: title,
              size: 16,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            const Spacer(),
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: TextWidget(
                text: "lend_all".tr,
                size: 14,
                color: AppColors.primary1,
                textDecoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        _buildLendList(items, cardColor),
      ],
    );
  }

  Widget _buildLendList(RxList<LendItemModel> items, Color cardColor) {
    return Obx(
      () => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 5),
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildLendItem(item, cardColor);
        },
      ),
    );
  }

  Widget _buildLendItem(LendItemModel item, Color cardColor) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.lendDetails, arguments: item.idMuon);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: cardColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: cardColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildColumn("borrower".tr, item.idNguoiMuon?.userName ?? '---'),
            _buildColumn("department".tr, item.donVi ?? '---'),
            _buildColumn("lend_date".tr, item.ngayMuon ?? '---'),
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
