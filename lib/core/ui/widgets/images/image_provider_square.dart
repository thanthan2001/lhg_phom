import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../configs/app_colors.dart';



class ImageProviderSquareWidget extends StatelessWidget {
  final double height;
  final double width;
  final File imageUrl;
  final double borderRadius;
  final Color backgroundColor;
  const ImageProviderSquareWidget(
      {super.key,
      required this.height,
      required this.width,
      required this.imageUrl,
      this.backgroundColor = AppColors.white,
      this.borderRadius = 10.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(
          Radius.circular(borderRadius),
        ),
      ),
      child: Image.file(
        imageUrl,
        errorBuilder: (context, url, error) => const Icon(Icons.error),
        fit: BoxFit.cover,
      ),
    );
  }

  _buildLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}