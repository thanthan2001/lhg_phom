import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/ui/widgets/button/button_widget.dart';

import '../../../../../../core/configs/app_colors.dart';
import '../../../../../../core/routes/routes.dart';
import '../../../../../../core/ui/widgets/text/text_widget.dart';
import '../controller/lend_controller.dart';
import '../widgets/lend_card_widget.dart';

class LendPage extends GetView<LendController> {
  const LendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  backgroundColor: AppColors.primary,
                  title: TextWidget(
                    text: "Mượn trả phom",
                    color: AppColors.white,
                  ),
                  centerTitle: true,
                  floating: true,
                  snap: true,
                  pinned: false,
                ),
              ],
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                _buildButtonRow(),
                const SizedBox(height: 10),
                _searchBar(),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: controller.lendItems.length,
                  itemBuilder: (context, index) {
                    return LendCardWidget(item: controller.lendItems[index]);
                  },
                ),
              ],
            ),
          ),
        ),
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
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
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

  Widget _buildButtonRow() {
    return Row(
      children: [
        _buildButton("Phát cho mượn", AppColors.blue, "/lend/give"),
        const SizedBox(width: 10),
        _buildButton("Trả phom", AppColors.yellow, "/lend/return"),
        const SizedBox(width: 10),
        _buildButton(
          "Mượn từ nhà máy khác",
          AppColors.red,
          "/lend/borrowOthers",
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
        ontap: () {
          Get.toNamed(route);
        },
      ),
    );
  }
}
