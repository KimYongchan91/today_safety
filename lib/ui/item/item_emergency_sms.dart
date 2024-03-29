import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:today_safety/const/model/model_article.dart';
import 'package:today_safety/const/model/model_emergency_sms.dart';
import 'package:today_safety/const/value/color.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/ui/route/route_webview.dart';

class ItemEmergencySms extends StatelessWidget {
  final ModelEmergencySms modelEmergencySms;

  const ItemEmergencySms(this.modelEmergencySms, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            ///내 지역의 재난 문자라면 강조
            borderRadius: BorderRadius.circular(20),
            color: modelEmergencySms.isNearRegion ? Colors.red.shade700 : colorBackground,
          ),
          width: Get.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                  Text(
                    style: TextStyle(
                        color: modelEmergencySms.isNearRegion ? Colors.white : Colors.black54,
                        fontWeight: FontWeight.bold),
                    modelEmergencySms.locationName.contains(',')
                        ? '${modelEmergencySms.locationName.split(",").first} 외 ${modelEmergencySms.locationName.split(",").length - 1}지역'
                        : modelEmergencySms.locationName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  onTap() async {}
}
