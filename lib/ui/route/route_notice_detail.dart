import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/ui/widget/icon_error.dart';

import '../../const/model/model_notice.dart';
import '../../const/value/router.dart';
import '../../my_app.dart';
import '../../service/util/util_notice.dart';

class RouteNoticeDetail extends StatefulWidget {
  const RouteNoticeDetail({Key? key}) : super(key: key);

  @override
  State<RouteNoticeDetail> createState() => _RouteNoticeDetailState();
}

class _RouteNoticeDetailState extends State<RouteNoticeDetail> {
  late Completer<bool> completerModelCheckList;
  ModelNotice? modelNotice;

  @override
  void initState() {
    MyApp.logger.d("keyNoticeId : ${Get.parameters[keyNoticeId]}");

    completerModelCheckList = Completer();

    if (Get.parameters[keyNoticeId] == null) {
      completerModelCheckList.complete(false);
      return;
    }

    if (Get.arguments?[keyModelNotice] != null) {
      modelNotice = Get.arguments[keyModelNotice];
      completerModelCheckList.complete(true);
    } else {
      getModelNoticeFromServerByDocId(Get.parameters[keyModelNotice]!).then((value) {
        if (value != null) {
          modelNotice = value;
          completerModelCheckList.complete(true);
        } else {
          modelNotice = null;
          completerModelCheckList.complete(false);
        }
      });
    }

/*
    completerModelCheckList.future.then((value) {
      if (value) {
        initByCheckList();
      }
    });
*/

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: completerModelCheckList.future,
          builder: (context, snapshot) {
            if (snapshot.hasData == false) {
              return LoadingAnimationWidget.inkDrop(color: Colors.green, size: 32);
            } else {
              if (snapshot.data == true) {
                return Column(
                  children: [
                    Text(
                      '공지사항',
                      style: CustomTextStyle.bigBlackBold(),
                    ),
                    Text(
                      '제목',
                      style: CustomTextStyle.normalBlackBold(),
                    ),
                    Text(modelNotice!.title),
                    Text(
                      '본문',
                      style: CustomTextStyle.normalBlackBold(),
                    ),
                    Text(modelNotice!.body),
                  ],
                );
              } else {
                return Center(
                  child: IconError(),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
