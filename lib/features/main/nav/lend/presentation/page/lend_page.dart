import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/lend_controller.dart';

class LendPage extends GetView<LendController> {
  const LendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [Center(child: Text('Lend Page'))]),
      ),
    );
  }
}
