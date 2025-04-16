import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lhg_phom/core/configs/app_colors.dart';
import 'package:lhg_phom/core/ui/widgets/text/text_widget.dart';

Future<void> showSearchableSelectionDialog({
  required String title,
  required List<String> itemList,
  required Function(String) onSelected,
  String? selectedItem,
}) async {
  final searchText = ''.obs;
  final filteredList = itemList.obs;

  void filter(String text) {
    searchText.value = text;
    filteredList.value = itemList
        .where((e) => e.toLowerCase().contains(text.toLowerCase()))
        .toList();
  }

  Get.dialog(
    AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: TextWidget(
        text: title,
        textAlign: TextAlign.center,
        fontWeight: FontWeight.bold,
        size: 20,
      ),
      content: SizedBox(
        width: Get.width * 0.6,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.grey1,
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextField(
                onChanged: filter,
                decoration: InputDecoration(
                  hintText: "Tìm kiếm",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: AppColors.grey),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Obx(
              () => ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: Scrollbar(
                  thumbVisibility: true,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredList.length,
                    itemBuilder: (_, index) {
                      final item = filteredList[index];
                      return ListTile(
                        title: Text(item),
                        trailing: item == selectedItem
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                        onTap: () {
                          onSelected(item);
                          Get.back();
                        },
                        selected: item == selectedItem,
                        selectedTileColor:
                            AppColors.primary2.withOpacity(0.1),
                        selectedColor: AppColors.primary1,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
