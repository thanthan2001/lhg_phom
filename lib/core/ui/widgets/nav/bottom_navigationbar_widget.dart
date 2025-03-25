import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import '../../../configs/app_colors.dart';

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
    return CurvedNavigationBar(
      index: currentIndex,
      height: 60,
      backgroundColor: Colors.white,
      color: AppColors.primary,
      animationDuration: const Duration(milliseconds: 300),
      onTap: allowSelect ? onPageChanged : null,
      items: const [
        Icon(Icons.home, size: 30, color: Colors.white), // Trang chủ
        Icon(Icons.category, size: 30, color: Colors.white), // Phom
        Icon(Icons.shelves, size: 30, color: Colors.white), // Shelf
        Icon(Icons.list_alt_sharp, size: 30, color: Colors.white), // Lend
        Icon(Icons.person, size: 30, color: Colors.white), // User
      ],
    );
  }
}
