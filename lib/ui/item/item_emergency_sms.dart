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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          ///내 지역의 재난 문자라면 강조
          borderRadius: BorderRadius.circular(20),
          color: modelEmergencySms.isNearRegion ? Colors.redAccent : Colors.white,
        ),
        width: Get.width,
        child: Column(
          children: [
            Row(
              children: [
                ///제목
                Expanded(
                  child: Text(
                    modelEmergencySms.msg,
                    style: TextStyle(
                        fontSize: 16,
                        color: modelEmergencySms.isNearRegion ? Colors.white : Colors.black54,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ///날짜
                Text(
                  DateFormat('MM-dd hh:mm').format(modelEmergencySms.dateTime),
                  style: TextStyle(
                      color: modelEmergencySms.isNearRegion ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 10,
                ),

                ///지역
                Expanded(
                  child: Text(
                    style: TextStyle(
                        color: modelEmergencySms.isNearRegion ? Colors.white : Colors.black54,
                        fontWeight: FontWeight.bold),
                    modelEmergencySms.locationName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  onTap() async {}
}
