import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../core/configs/app_colors.dart';
import '../../../../../../core/routes/routes.dart';
import '../../../../../../core/ui/widgets/text/text_widget.dart';
import '../controller/lend_controller.dart';
import '../../../../../../core/services/models/lend_model.dart';

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
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildQuickActions(),
                const SizedBox(height: 20),
                _buildSection(
                  title: "lend_register_list".tr,
                  onViewAll: () {
                    Get.toNamed(Routes.lendRegister);
                  },
                  items: controller.registerlendItems,
                  cardColor: AppColors.primary3,
                ),
                const SizedBox(height: 16),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: "lend_give".tr,
                  size: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 6),
                TextWidget(
                  text: "lend_give_list".tr,
                  size: 13,
                  color: Colors.white.withOpacity(0.9),
                ),
              ],
            ),
          ),
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: "Hành động nhanh",
          size: 16,
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionCard(
              title: "lend_give".tr,
              subtitle: "Tạo phiếu mượn",
              color: AppColors.blue,
              icon: Icons.qr_code_scanner_rounded,
              route: Routes.lendGive,
            ),
            _buildActionCard(
              title: "Quick Scan",
              subtitle: "Scan nhanh tạo phiếu",
              color: AppColors.green,
              icon: Icons.bolt_rounded,
              route: Routes.quickScanBorrow,
            ),
            _buildActionCard(
              title: "lend_return".tr,
              subtitle: "Trả phom nhanh",
              color: AppColors.yellow,
              icon: Icons.assignment_turned_in_rounded,
              route: Routes.lendReturn,
            ),
            _buildActionCard(
              title: "lend_others".tr,
              subtitle: "Khác",
              color: AppColors.red,
              icon: Icons.more_horiz_rounded,
              route: Routes.lendOthers,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required String route,
  }) {
    final cardWidth = (Get.width - 44) / 2;

    return SizedBox(
      width: cardWidth,
      child: GestureDetector(
        onTap: () => Get.toNamed(route),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 10),
              TextWidget(
                text: title,
                size: 14,
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 4),
              TextWidget(
                text: subtitle,
                size: 11,
                color: AppColors.black.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required VoidCallback onViewAll,
    required RxList<LendItemModel> items,
    required Color cardColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.grey2.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
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
                  size: 13,
                  color: AppColors.primary1,
                  textDecoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildLendList(items, cardColor),
        ],
      ),
    );
  }

  Widget _buildLendList(RxList<LendItemModel> items, Color cardColor) {
    return Obx(
      () => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cardColor.withOpacity(0.35), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.person_outline_rounded, color: cardColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: item.idNguoiMuon?.userName ?? '---',
                        fontWeight: FontWeight.bold,
                        size: 14,
                      ),
                      const SizedBox(height: 2),
                      TextWidget(
                        text: item.donVi ?? '---',
                        size: 12,
                        color: AppColors.black.withOpacity(0.6),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextWidget(
                    text: item.ngayMuon ?? '---',
                    size: 11,
                    color: cardColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: AppColors.grey2.withOpacity(0.7)),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildMetaChip(
                  "borrower".tr,
                  item.idNguoiMuon?.userName ?? '---',
                ),
                const SizedBox(width: 8),
                _buildMetaChip("department".tr, item.donVi ?? '---'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaChip(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.grey2.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              text: title,
              size: 11,
              color: AppColors.black.withOpacity(0.6),
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 2),
            TextWidget(text: value, size: 12, fontWeight: FontWeight.w600),
          ],
        ),
      ),
    );
  }
}
