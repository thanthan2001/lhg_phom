import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/shelf_controller.dart';

class ShelfPage extends GetView<ShelfController> {
  const ShelfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [Center(child: Text('Shelf Page'))]),
      ),
    );
  }
}
