import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      getModelNoticeFromServerByDocId(Get.parameters[keyNoticeId]!).then((value) {
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
                    Container(
padding: const EdgeInsets.symmetric(horizontal: 20),
                      width: Get.width,
                      height: 60,
                      color: Colors.white,
                      child: Row(
                        children: [
                          InkWell(
                            onTap: (){
                              Get.back();
                            },
                            child: FaIcon(FontAwesomeIcons.angleLeft),
                          ),

                          const SizedBox(width: 20,),
                          const Text(
                            '공지사항',
                            style: CustomTextStyle.bigBlackBold(),
                          ),



                        ],
                      ),
                    ),

                    Container(
                      height: 1,
                      width: Get.width,
                      color: Colors.black54,
                    ),

                    const SizedBox(height: 50,),




                    Text(modelNotice!.title,style: const CustomTextStyle.bigBlackBold(),),

                    const SizedBox(height: 20,),
                    const Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text('시간'))),
                    const SizedBox(height: 40,),
                    Text(modelNotice!.body, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),),
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
