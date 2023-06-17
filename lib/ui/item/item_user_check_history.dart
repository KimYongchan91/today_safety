import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:today_safety/const/model/model_user_check_history.dart';

class ItemUserCheckHistory extends StatelessWidget {
  final ModelUserCheckHistory modelUserCheckHistory;

  const ItemUserCheckHistory(this.modelUserCheckHistory, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
        color: Colors.grey,
      )),
      child: ExpandablePanel(
        header: Text(modelUserCheckHistory.modelUser.name), //todo kyc, 인증 시간 추가
        collapsed: Container(),
        expanded: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                "인증 위치 :${modelUserCheckHistory.modelLocation.si} ${modelUserCheckHistory.modelLocation.gu} "
                    "${modelUserCheckHistory.modelLocation.dong}")
          ],
        ), //todo kyc, 인증 주소 등 추가
      ),
    );
  }
}
