import 'package:flutter/material.dart';
import 'package:lhg_phom/core/ui/widgets/text/text_pand_widget.dart';
import 'package:lhg_phom/features/main/nav/home/presentation/controller/home_controller.dart';
import 'package:get/get.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            child: Column(
              children: [TextSpanWidget(text1: "Hello", text2: "LHG")],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.fetchData();
            },
            child: Text('Fetch Data'),
          ),
          Obx(() {
            return controller.isLoading.value
                ? CircularProgressIndicator()
                : Text('Data fetched successfully');
          }),
        ],
      ),
    );
  }
}
