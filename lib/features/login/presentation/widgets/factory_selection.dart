import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/login_controller.dart';

class FactorySelectionWidget extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.find();
    final RxString searchText = ''.obs;
    final List<String> allFactories = [
      "LYV",
      "LVL",
      "LHG",
      "LYM/POL",
      "JAZ",
      "LYN",
      "LTB",
      "LDT",
      "JZS",
    ];

    final RxList<String> filteredFactories = RxList<String>(allFactories);

    // Local RxString to manage selection within the dialog
    final RxString selectedFactory = RxString(
      loginController.selectedFactory.value,
    );

    // Function to filter the factory list
    void filterFactories(String text) {
      searchText.value = text;
      filteredFactories.value =
          allFactories
              .where(
                (factory) => factory.toLowerCase().contains(text.toLowerCase()),
              )
              .toList();
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Text(
        "Factory",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFBCE6FF),
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.blueGrey),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 10,
                  ),
                ),
                onChanged: filterFactories,
              ),
            ),
            SizedBox(height: 10),
            Obx(
              () => GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3.5,
                ),
                itemCount: filteredFactories.length,
                itemBuilder: (context, index) {
                  final factory = filteredFactories[index];
                  return Obx(
                    () => Row(
                      children: [
                        Checkbox(
                          value:
                              selectedFactory.value.toLowerCase() ==
                              factory.toLowerCase(),
                          onChanged: (value) {
                            selectedFactory.value =
                                value == true ? factory : "";
                            print(selectedFactory);
                          },
                          activeColor: Colors.blueAccent,
                        ),
                        Text(factory),
                      ],
                    ),
                  );
                },
              ),
            ),
            Center(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xff5790AB)),
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xffCAEAFF),
                ),
                child: TextButton(
                  child: Text(
                    "Done",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                  onPressed: () {
                    // Update the LoginController's selectedFactory
                    loginController.selectedFactory.value =
                        selectedFactory.value;
                    Get.back();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
