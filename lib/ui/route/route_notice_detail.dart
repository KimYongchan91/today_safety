import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
                            onTap: () {
                              Get.back();
                            },
                            child: const FaIcon(FontAwesomeIcons.angleLeft),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          const Text(
                            '공지사항',
                            style: CustomTextStyle.bigBlackBold(),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 0.5,
                      width: Get.width,
                      color: Colors.black45,
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    ///회사 정보 영역
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Card(
                        elevation: 2,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),

                                ///회사 로고
                                child: CachedNetworkImage(
                                  imageUrl: modelNotice!.modelSite.urlLogoImage,
                                  width: 70,
                                  height: 70,
                                ),
                              ),
                            ),
SizedBox(width: 10,),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ///회사 이름
                                  Text(
                                    modelNotice!.modelSite.name,
                                    style: const CustomTextStyle.normalBlackBold(),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),

                                  ///팀 이름
                                  Text(
                                    [...modelNotice!.listModelCheckList.map((e) => e.name)]
                                        .toString()
                                        .replaceAll('[', '')
                                        .replaceAll(']', ''),
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),

                    ///제목
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        modelNotice!.title,
                        style: const CustomTextStyle.bigBlackBold(),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),

                    ///시간
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          DateFormat('yyyy-MM-dd hh:mm:ss').format(modelNotice!.date.toDate()),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),

                    ///본문
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        modelNotice!.body,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(
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
