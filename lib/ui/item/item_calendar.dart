import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:today_safety/const/model/model_daily_check_history.dart';

import '../../const/model/model_user_check_history.dart';
import '../../const/value/router.dart';
import '../../custom/custom_text_style.dart';

class ItemCalendar extends StatelessWidget {
  final String checkListId;
  final DateTime dateTime;
  final bool isToday;
  final ModelDailyCheckHistory modelDailyCheckHistory;

  //final List<ModelUserCheckHistory> listModelUserCheckHistory;

  const ItemCalendar({
    required this.checkListId,
    required this.dateTime,
    this.isToday = false,
    required this.modelDailyCheckHistory,
    Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final text = DateFormat('d').format(dateTime);

    return Padding(
      padding: const EdgeInsets.all(3),
      child: InkWell(
        onTap: onTapCalendar,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: isToday ? Colors.grey : Colors.transparent),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: const CustomTextStyle.normalBlack(),
                ),
                Text(
                  '${modelDailyCheckHistory.userCheckHistoryCount}건',
                  style: const CustomTextStyle.normalGrey(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  onTapCalendar() {
    Get.toNamed('$keyRouteCheckListDetail'
        '/$checkListId'
    '/$keyRouteCheckListDailyWithOutSlash'
    '/${DateFormat('yyyy-MM-dd').format(dateTime)}'
    );
  }
}
