import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:today_safety/const/model/model_check_list.dart';

import '../../const/value/router.dart';
import '../../my_app.dart';
import '../../service/util/util_check_list.dart';

class RouteCheckListCheck extends StatefulWidget {
  const RouteCheckListCheck({Key? key}) : super(key: key);

  @override
  State<RouteCheckListCheck> createState() => _RouteCheckListCheckState();
}

class _RouteCheckListCheckState extends State<RouteCheckListCheck> {
  late Completer<ModelCheckList?> completerModelCheckList;

  @override
  void initState() {
    MyApp.logger.d("keyCheckListId : ${Get.parameters[keyCheckListId]}");

    completerModelCheckList = Completer();

    if (Get.parameters[keyCheckListId] == null) {
      MyApp.logger.wtf("keyCheckListId == null");
      completerModelCheckList.complete(null);
      return;
    }

    if (Get.arguments?[keyModelCheckList] != null) {
      completerModelCheckList.complete(Get.arguments[keyModelCheckList]);

    } else {
      getModelCheckListFromServerByDocId(Get.parameters[keyCheckListId]!).then((value) {
        completerModelCheckList.complete(value);
      });
    }

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(),
      ),
    );
  }

  init() {}
}
