import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:today_safety/const/model/model_notice.dart';
import 'package:today_safety/custom/custom_text_style.dart';

import '../../const/value/router.dart';
import '../../const/value/value.dart';

class ItemNoticeSmall extends StatelessWidget {
  final ModelNotice modelNotice;

  const ItemNoticeSmall(this.modelNotice, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int millisecondGap = DateTime.now().millisecondsSinceEpoch - modelNotice.date.millisecondsSinceEpoch;
    String millisecondGapFormatted;
    if (millisecondGap < millisecondMinute) {
      millisecondGapFormatted = "방금";
    } else if (millisecondGap < millisecondHour) {
      millisecondGapFormatted = "${millisecondGap ~/ millisecondMinute}분 전";
    } else if (millisecondGap < millisecondDay) {
      millisecondGapFormatted = "${millisecondGap ~/ millisecondHour}시간 전";
    } else {
      millisecondGapFormatted = "${millisecondGap ~/ millisecondDay}일 전";
    }

    return InkWell(
      onTap: () {
        Get.toNamed('$keyRouteNoticeDetail/${modelNotice.docId}', arguments: {keyModelNotice: modelNotice});
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
          color: Colors.grey,
        )),
        child: Column(
          children: [
            ///날짜
            Text(
              millisecondGapFormatted,
              style: CustomTextStyle.normalBlack(),
            ),

            ///대상 팀
            Text(
              modelNotice.listModelCheckList.map((e) => e.name).toList().toString().replaceAll('[', '').replaceAll(']', ''),
              style: CustomTextStyle.normalBlack(),
            ),

            ///제목
            Text(
              modelNotice.title,
              style: CustomTextStyle.normalBlackBold(),
            ),

            ///본문
            Text(
              modelNotice.body,
              style: CustomTextStyle.normalBlack(),
            ),
          ],
        ),
      ),
    );
  }
}
