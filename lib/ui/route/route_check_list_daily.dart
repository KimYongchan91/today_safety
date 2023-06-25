import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:today_safety/const/model/model_check_list.dart';
import 'package:today_safety/custom/custom_text_style.dart';

import '../../const/model/model_user_check_history.dart';
import '../../const/value/router.dart';
import '../../my_app.dart';
import '../item/item_user_check_history_small.dart';

class RouteCheckListDaily extends StatefulWidget {
  const RouteCheckListDaily({Key? key}) : super(key: key);

  @override
  State<RouteCheckListDaily> createState() => _RouteCheckListDailyState();
}

class _RouteCheckListDailyState extends State<RouteCheckListDaily> {
  String dateFormatted = '';
  ModelCheckList? modelCheckList;
  List<ModelUserCheckHistory> listModelUserCheckHistory = [];
  late Completer<bool> comparableGetListModelUserCheckHistory;

  @override
  void initState() {
    super.initState();

    MyApp.logger.d(
        "keyCheckListId : ${Get.parameters[keyCheckListId]}, keyDailyDateFormatted : ${Get.parameters[keyDailyDateFormatted]}");

    dateFormatted = Get.parameters[keyDailyDateFormatted] ?? '날짜 없음';

    modelCheckList = Get.arguments[keyModelCheckList];

    comparableGetListModelUserCheckHistory = Completer();
    if (Get.arguments[keyListModelUserCheckHistory] != null) {
      //그 전 루트에서 받아옴
      listModelUserCheckHistory = Get.arguments[keyListModelUserCheckHistory];
    } else {
      //서버에서 받아옴
      //현재 안함
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                dateFormatted,
                style: CustomTextStyle.bigBlackBold(),
              ),
              ListView.builder(
                itemCount: listModelUserCheckHistory.length,
                itemBuilder: (context, index) => ItemUserCheckHistorySmall(
                  listModelUserCheckHistory[index],
                  modelCheckList: modelCheckList,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
