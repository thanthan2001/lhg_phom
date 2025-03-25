
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../configs/app_colors.dart';

class ImageNetWotkSquareWidget extends StatelessWidget {
  final double height;
  final double width;
  final String imageUrl;
  final double borderRadius;
  final Color backgroundColor;
  const ImageNetWotkSquareWidget(
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
      child: Uri.parse(imageUrl).isAbsolute
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) => _buildLoading(),
              errorWidget: (context, url, error) {
                return const Icon(Icons.error);
              },
              errorListener: null,
              // fit: BoxFit.contain,
            )
          : const Icon(Icons.error),
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