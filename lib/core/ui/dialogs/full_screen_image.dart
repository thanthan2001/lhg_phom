import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FullScreenImage extends StatelessWidget {
  final int initialIndex;
  const FullScreenImage({
    super.key,
    required this.initialIndex,
    required this.controller,
  });

  final dynamic controller;

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Get.back();   
          },
        ),
      ),

      body: Stack(
        children: [
          PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: controller.listImagesPostDetail.length,
            onPageChanged: (index) {
              controller.currentIndex = index;
            },
            itemBuilder: (context, index) {
              return Center(
                child: Image.network(
                  controller.listImagesPostDetail[index],
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
