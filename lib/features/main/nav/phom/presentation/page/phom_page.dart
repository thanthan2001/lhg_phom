import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/phom_controller.dart';

class PhomPage extends GetView<PhomController> {
  const PhomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [Center(child: Text('Phom Page'))]),
      ),
    );
  }
}
