import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../core/configs/app_colors.dart';
import '../../../../../../core/routes/routes.dart';
import '../../../../../../core/ui/widgets/text/text_widget.dart';
import '../../../../../../core/services/model/lend_model.dart';
import '../controller/lendRegister_controller.dart';

class LendRegisterPage extends GetView<LendRegisterController> {
  const LendRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                _searchBar(),
                const SizedBox(height: 10),
                _buildLendList(
                  controller.registerlendItems,
                  AppColors.primary3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const TextWidget(
        text: "Danh sách đăng ký mượn",
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

  Widget _searchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: "Nhập để tìm kiếm...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary1,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            onPressed: () {},
            icon: Icon(Icons.search, size: 30, color: AppColors.white),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.tune, size: 40, color: AppColors.black),
        ),
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
            _buildColumn("Người mượn", item.idNguoiMuon?.userName ?? '---'),
            _buildColumn("Đơn vị", item.donVi ?? '---'),
            _buildColumn("Ngày mượn", item.ngayMuon ?? '---'),
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
