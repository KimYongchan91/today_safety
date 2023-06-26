import 'dart:async';
import 'dart:ui' as ui;

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:today_safety/const/model/model_check_image.dart';
import 'package:today_safety/const/value/value.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/ui/route/route_check_image_detail.dart';
import 'package:today_safety/ui/widget/icon_error.dart';

import '../../const/model/model_check_list.dart';
import '../../const/model/model_user_check_history.dart';
import '../../const/value/router.dart';
import '../../my_app.dart';
import '../../service/util/util_app_link.dart';
import '../../service/util/util_user_check_history.dart';

class RouteUserCheckHistoryDetail extends StatefulWidget {
  const RouteUserCheckHistoryDetail({Key? key}) : super(key: key);

  @override
  State<RouteUserCheckHistoryDetail> createState() => _RouteUserCheckHistoryDetailState();
}

class _RouteUserCheckHistoryDetailState extends State<RouteUserCheckHistoryDetail> {
  late Completer<bool> completerModelUserCheckHistory;
  ModelUserCheckHistory? modelUserCheckHistory;

  @override
  void initState() {
    MyApp.logger.d("keyUserCheckHistoryId : ${Get.parameters[keyUserCheckHistoryId]}");

    completerModelUserCheckHistory = Completer();

    if (Get.parameters[keyUserCheckHistoryId] == null) {
      completerModelUserCheckHistory.complete(false);
      return;
    }

    if (Get.arguments?[keyModelUserCheckHistory] != null) {
      modelUserCheckHistory = Get.arguments[keyModelUserCheckHistory];
      completerModelUserCheckHistory.complete(true);
    } else {
      getModelUserCheckHistoryFromServerByDocId(Get.parameters[keyUserCheckHistoryId]!).then((value) {
        if (value != null) {
          modelUserCheckHistory = value;
          completerModelUserCheckHistory.complete(true);
        } else {
          modelUserCheckHistory = null;
          completerModelUserCheckHistory.complete(false);
        }
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: completerModelUserCheckHistory.future,
          builder: (context, snapshot) {
            if (snapshot.hasData == false) {
              return Center(
                child: LoadingAnimationWidget.inkDrop(color: Colors.green, size: 32),
              );
            } else {
              if (snapshot.data == true) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),

                      ///앱 아이콘
                      Row(
                        children: [
                          Spacer(),
                          AnimatedTextKit(
                            pause: Duration(milliseconds: 1000),
                            repeatForever: true,
                            animatedTexts: [
                              ColorizeAnimatedText('오늘 안전',
                                  textStyle: CustomTextStyle.bigBlackBold(),
                                  colors: [
                                    Colors.yellow,
                                    Colors.green,
                                    Colors.orange,
                                  ],
                                  speed: const Duration(milliseconds: 1000)),
                            ],
                            isRepeatingAnimation: true,
                            onTap: () {
                              print("Tap Event");
                            },
                          ),
                          Image.asset(
                            'assets/images/logo/sample_logo_230625.jpg',
                            width: 40,
                            height: 40,
                          )
                        ],
                      ),

                      SizedBox(
                        height: 30,
                      ),

                      ///QR 코드 부분
                      SizedBox(
                        width: Get.width * 0.6,
                        height: Get.width * 0.6,
                        child: SfBarcodeGenerator(
                          value: '$urlBaseAppLink$keyRouteUserCheckHistoryDetail/${Get.parameters[keyUserCheckHistoryId]}',
                          symbology: QRCode(),
                          showValue: false,
                        ),
                      ),

                      SizedBox(
                        height: 30,
                      ),

                      ///사용자 이름
                      Text(
                        '이름',
                        style: CustomTextStyle.smallBlackBold(),
                      ),

                      Text(
                        '${modelUserCheckHistory!.modelUser.name} (${modelUserCheckHistory!.modelUser.idExceptLT})',
                        style: CustomTextStyle.bigBlackBold(),
                      ),

                      SizedBox(
                        height: 30,
                      ),

                      ///근무지 이름
                      Text(
                        '근무지',
                        style: CustomTextStyle.smallBlackBold(),
                      ),

                      Text(
                        modelUserCheckHistory!.modelCheckList.modelSite.name,
                        style: CustomTextStyle.normalBlackBold(),
                      ),

                      SizedBox(
                        height: 30,
                      ),

                      ///근무지 내 팀명
                      Text(
                        '팀',
                        style: CustomTextStyle.smallBlackBold(),
                      ),

                      Text(
                        modelUserCheckHistory!.modelCheckList.name,
                        style: CustomTextStyle.normalBlackBold(),
                      ),

                      SizedBox(
                        height: 30,
                      ),

                      ///인증 날짜
                      Text(
                        '인증일자',
                        style: CustomTextStyle.smallBlackBold(),
                      ),

                      Text(
                        DateFormat('yyyy-MM-dd hh:mm:ss').format(modelUserCheckHistory!.date.toDate()),
                        style: CustomTextStyle.normalBlackBold(),
                      ),

                      SizedBox(
                        height: 30,
                      ),

                      ///인증 날짜
                      Text(
                        '유효기간',
                        style: CustomTextStyle.smallBlackBold(),
                      ),

                      Text(
                        // +1 일
                        '${DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(modelUserCheckHistory!.date.toDate().millisecondsSinceEpoch + millisecondDay))} 까지',
                        style: CustomTextStyle.normalBlackBold(),
                      ),

                      SizedBox(
                        height: 30,
                      ),

                      ///인증 사진
                      ExpandablePanel(
                        header: Container(
                          height: 40,
                          //decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '인증 사진',
                              style: CustomTextStyle.smallBlackBold(),
                            ),
                          ),
                        ),
                        theme: ExpandableThemeData(
                          tapBodyToExpand: true,
                        ),
                        collapsed: Container(),
                        expanded: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListView.separated(
                              itemCount: modelUserCheckHistory!.listModelCheckImage.length,
                              itemBuilder: (context, index) => InkWell(
                                  onTap: () {
                                    onTapCheckImage(index);
                                  },
                                  child: _ItemCheckImage(modelUserCheckHistory!.listModelCheckImage[index])),
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              separatorBuilder: (context, index) => SizedBox(
                                height: 20,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
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

  onTapCheckImage(int index) {
    Get.to(
      () => RouteCheckImageDetail(
        modelUserCheckHistory!.listModelCheckImage,
        index: index,
        modelUser: modelUserCheckHistory!.modelUser,
        modelDevice: modelUserCheckHistory!.modelDevice,
      ),
    );
  }
}

class _ItemCheckImage extends StatelessWidget {
  final ModelCheckImage modelCheckImage;

  const _ItemCheckImage(this.modelCheckImage, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${modelCheckImage.name}'),
        Text('${modelCheckImage.cameraDirection}'),
        Text('${modelCheckImage.date}'),
        CachedNetworkImage(
          imageUrl: modelCheckImage.urlImage,
          fit: BoxFit.fitWidth,
        )
      ],
    );
  }
}
