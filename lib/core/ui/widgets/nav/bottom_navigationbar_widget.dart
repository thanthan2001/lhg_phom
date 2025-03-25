import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; 
import '../../../configs/app_colors.dart';
import '../../../configs/app_images_string.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onPageChanged;
  final bool allowSelect;

  const BottomNavigationBarWidget({
    super.key,
    required this.currentIndex,
    required this.onPageChanged,
    this.allowSelect = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.primary, 
            width: 2.0, 
          ),
        ),
         borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10), 
          topRight: Radius.circular(10), 
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -2), 
            blurRadius: 10, 
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex, 
        onTap: allowSelect
            ? (index) {
                onPageChanged(index);
              }
            : null,
        backgroundColor: AppColors.white, 
        type: BottomNavigationBarType
            .fixed, 
        showSelectedLabels: true, 
        showUnselectedLabels: true, 
        selectedFontSize: 14, 
        unselectedFontSize: 12, 
        selectedItemColor:
            AppColors.primary, 
        unselectedItemColor: AppColors.primary
            .withOpacity(0.5), 
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "AppImagesString.eClothes", 
              height: 28,
              color: currentIndex == 0
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.5),
            ),
            label: 'Trang phục',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "AppImagesString.ePosts", 
              height: 28,
              color: currentIndex == 1
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.5),
            ),
            label: 'Góc Epose',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "AppImagesString.eHome",
              height: 28,
              color: currentIndex == 2
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.5),
            ),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "AppImagesString.eBill",
              height: 28,
              color: currentIndex == 3
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.5),
            ),
            label: 'Đơn hàng',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "AppImagesString.eProfile",
              height: 28,
              color: currentIndex == 4
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.5),
            ),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}