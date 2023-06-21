import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:today_safety/const/model/model_check_list.dart';
import 'package:today_safety/const/value/color.dart';
import 'package:today_safety/ui/route/route_check_list_check_camera.dart';
import 'package:today_safety/ui/route/test/route_test_animation_container.dart';
import 'package:today_safety/ui/route/test/route_test_animation_hero.dart';
import 'package:today_safety/ui/route/test/route_test_check_sequence.dart';
import 'package:today_safety/ui/screen/screen_check_list_check_detail.dart';

import '../../const/value/router.dart';
import '../../custom/custom_text_style.dart';
import '../../my_app.dart';
import '../../service/util/util_check_list.dart';
import '../../service/util/util_permission.dart';
import '../item/item_check.dart';
import '../screen/screen_check_list_check_main.dart';

///실제로 인증하는 페이지(카메라)
class RouteCheckListCheck extends StatefulWidget {
  const RouteCheckListCheck({Key? key}) : super(key: key);

  @override
  State<RouteCheckListCheck> createState() => _RouteCheckListCheckState();
}

class _RouteCheckListCheckState extends State<RouteCheckListCheck> {
  late Completer<bool> completerGetModelCheckList;
  late ModelCheckList? modelCheckList;

  int indexCheck = 0;

  @override
  void initState() {
    MyApp.logger.d("keyCheckListId : ${Get.parameters[keyCheckListId]}");

    completerGetModelCheckList = Completer();

    if (Get.parameters[keyCheckListId] == null) {
      MyApp.logger.wtf("keyCheckListId == null");
      modelCheckList = null;
      completerGetModelCheckList.complete(true);
      return;
    }

    if (Get.arguments?[keyModelCheckList] != null) {
      modelCheckList = Get.arguments[keyModelCheckList];
      completerGetModelCheckList.complete(true);
    } else {
      getModelCheckListFromServerByDocId(Get.parameters[keyCheckListId]!).then((value) {
        modelCheckList = value;
        completerGetModelCheckList.complete(true);
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackground,
      body: SafeArea(
        child: FutureBuilder<bool>(
          future: completerGetModelCheckList.future,
          builder: (context, snapshot) {
            if (snapshot.hasData == false) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.data == true) {
              if (modelCheckList == null) {
                return const Center(
                  child: Icon(
                    Icons.error,
                    color: Colors.red,
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ScreenCheckListCheckMain(modelCheckList!),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                    child: _Button(
                      indexCheck == 0 ? '인증 시작' : '다음 인증',
                      startCheck,
                    ),
                  ),

                ],
              );
            } else {
              return Icon(
                Icons.error,
                color: Colors.red,
              );
            }
          },
        ),
      ),
    );
  }

  movePreviousCheck() {
    if (indexCheck == 0) {
      return;
    }

    setState(() {
      indexCheck--;
    });
  }

  moveNextCheck() async {
    if (completerGetModelCheckList.isCompleted == false) {
      return;
    }

    if (modelCheckList == null) {
      //
      MyApp.logger.wtf("modelCheckList ==null");
      return;
    }

    //예로 인증 항목이 3개 있음. 그러면 요약 페이지까지 총 4페이지가 있어야함.
    //현재 인덱스가 3이라면 return 시켜야함.
    //현재 2페이지
    if (indexCheck >= modelCheckList!.listModelCheck.length) {
      //
      return;
    }

    setState(() {
      indexCheck++;
    });
  }

  startCheck() async {
    bool isPermissionGranted = await requestPermission(Permission.camera);
    if (isPermissionGranted == false) {
      return;
    }

    isPermissionGranted = await requestPermission(Permission.locationWhenInUse);
    if (isPermissionGranted == false) {
      return;
    }

    //todo test
    /*var result = await Get.to(RouteCamera(
      modelCheckList: modelCheckList,
    ));*/
    //Get.to(OpenContainerTransformDemo());

    Get.to(RouteCheckListCheckCamera(modelCheckList!));

    /* var result = await Get.to(RouteTestCheckSequence(
      modelCheckList: modelCheckList,
    ));*/
  }
}

///이 페이지에서 쓰이는 다음 인증, 이전 인증 버튼
class _Button extends StatelessWidget {
  final String label;
  final void Function()? onTap;
  final Color colorBackground;

  const _Button(this.label, this.onTap, {this.colorBackground = const Color(0xfff84343), Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        //width: 147,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              label,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}
