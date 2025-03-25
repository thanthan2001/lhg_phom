import 'package:flutter/material.dart';
import 'package:lhg_phom/features/home/presentation/controller/home_controller.dart';
import 'package:get/get.dart';

class HomePage extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Column(
                children: [
                  Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Hello',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'Hello',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ],
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
      ),
    );
  }
}
