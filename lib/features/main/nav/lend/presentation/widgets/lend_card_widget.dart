import 'package:flutter/material.dart';

import '../../../../../../core/services/model/lend_model.dart';

class LendCardWidget extends StatelessWidget {
  final LendItemModel item;

  const LendCardWidget({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Mã phom: ${item.maPhom}", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Tên phom: ${item.tenPhom}"),
            Text("Số thẻ: ${item.soThe}"),
            Text("Ngày mượn: ${item.ngayMuon}"),
            Text("Ngày trả: ${item.ngayTra}"),
          ],
        ),
      ),
    );
  }
}
