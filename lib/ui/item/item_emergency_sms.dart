import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:today_safety/const/model/model_article.dart';
import 'package:today_safety/const/model/model_emergency_sms.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/ui/route/route_webview.dart';

class ItemEmergencySms extends StatelessWidget {
  final ModelEmergencySms modelEmergencySms;

  const ItemEmergencySms(this.modelEmergencySms, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          ///내 지역의 재난 문자라면 강조
          color: modelEmergencySms.isNearRegion ? Colors.red : Colors.white,
        ),
        width: Get.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ///날짜
                Text(DateFormat('MM-dd hh:mm:ss').format(modelEmergencySms.dateTime)),
                SizedBox(
                  width: 10,
                ),

                ///지역
                Expanded(
                  child: Text(
                    modelEmergencySms.locationName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                ///제목
                Expanded(
                  child: Text(
                    modelEmergencySms.msg,
                    style: CustomTextStyle.normalBlackBold(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  onTap() async {}
}
