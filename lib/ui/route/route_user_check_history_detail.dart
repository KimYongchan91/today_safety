import 'dart:async';
import 'dart:ui' as ui;

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:today_safety/const/model/model_check.dart';
import 'package:today_safety/const/model/model_check_image.dart';
import 'package:today_safety/const/value/color.dart';
import 'package:today_safety/const/value/fuc.dart';
import 'package:today_safety/const/value/key.dart';
import 'package:today_safety/const/value/value.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/ui/route/route_check_image_detail.dart';
import 'package:today_safety/ui/route/route_user_check_history_detail_image.dart';
import 'package:today_safety/ui/widget/icon_error.dart';

import '../../const/model/model_check_list.dart';
import '../../const/model/model_user.dart';
import '../../const/model/model_user_check_history.dart';
import '../../const/value/router.dart';
import '../../my_app.dart';
import '../../service/util/util_app_link.dart';
import '../../service/util/util_user_check_history.dart';
import '../item/item_check.dart';
import '../widget/widget_app_bar.dart';

class RouteUserCheckHistoryDetail extends StatefulWidget {
  const RouteUserCheckHistoryDetail({Key? key}) : super(key: key);

  @override
  State<RouteUserCheckHistoryDetail> createState() => _RouteUserCheckHistoryDetailState();
}

class _RouteUserCheckHistoryDetailState extends State<RouteUserCheckHistoryDetail> {
  late Completer<bool> completerModelUserCheckHistory;
  ModelUserCheckHistory? modelUserCheckHistory;

  //이 인증 확인 결과
  final ValueNotifier<bool?> valueNotifierIsCheckGrant = ValueNotifier(null);

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

    //이미 승인했는지 아닌지
    completerModelUserCheckHistory.future.then((value) {
      if (value) {
        if (modelUserCheckHistory?.state == keyOn) {
          valueNotifierIsCheckGrant.value = true;
        } else if (modelUserCheckHistory?.state == keyPend) {
          //
        } else if (modelUserCheckHistory?.state == keyReject) {
          valueNotifierIsCheckGrant.value = false;
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackground,
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
                      const WidgetAppBar(),

                      const SizedBox(
                        height: 10,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          color: Colors.white,
                          child: Container(
                            width: Get.width,
                            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                            child: Column(
                              children: [
                                Text(
                                  modelUserCheckHistory!.modelCheckList.modelSite.name,
                                  style: const CustomTextStyle.bigBlackBold(),
                                ),

                                const SizedBox(
                                  height: 10,
                                ),

                                Text(
                                  modelUserCheckHistory!.modelCheckList.name,
                                  style: const CustomTextStyle.bigBlackBold().copyWith(fontSize: 25),
                                ),

                                const SizedBox(
                                  height: 20,
                                ),

                                ///QR 코드 부분
                                SizedBox(
                                  width: Get.width * 0.5,
                                  height: Get.width * 0.5,
                                  child: SfBarcodeGenerator(
                                    value:
                                        '$urlBaseAppLink$keyRouteUserCheckHistoryDetail/${Get.parameters[keyUserCheckHistoryId]}',
                                    symbology: QRCode(),
                                    showValue: false,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  '${modelUserCheckHistory!.modelUser.name}',
                                  style: const CustomTextStyle.normalBlackBold().copyWith(fontSize: 20),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  '${modelUserCheckHistory!.modelUser.idExceptLT}',
                                  style: const CustomTextStyle.normalBlackBold(),
                                ),

                                const SizedBox(
                                  height: 20,
                                ),

                                ///승인 상태
                                ValueListenableBuilder(
                                  valueListenable: valueNotifierIsCheckGrant,
                                  builder: (context, value, child) {
                                    String text;
                                    Color color;

                                    if (value == true) {
                                      text = '승인됨';
                                      color =colorCheckStateOn;
                                    } else if (value == false) {
                                      text = '거절됨';
                                      color =colorCheckStateReject;
                                    } else {
                                      text = '승인 대기 중';
                                      color =colorCheckStatePend;
                                    }

                                    return Text(text,style: TextStyle(color: color, fontSize: 24,fontWeight: FontWeight.bold),);
                                  },
                                ),

                                const SizedBox(
                                  height: 20,
                                ),

                                ///인증 날짜
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '인증일자',
                                    style: CustomTextStyle.smallBlackBold(),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    DateFormat('yyyy-MM-dd hh:mm:ss').format(modelUserCheckHistory!.date.toDate()),
                                    style: const CustomTextStyle.normalBlackBold(),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),

                                ///인증 날짜
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '유효기간',
                                    style: CustomTextStyle.smallBlackBold(),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    // +1 일
                                    '${DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(modelUserCheckHistory!.date.toDate().millisecondsSinceEpoch + millisecondDay))} 까지',
                                    style: const CustomTextStyle.normalBlackBold(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      ///인증내역보기 버튼
                      InkWell(
                        onTap: () {
                          Get.to(() => RouteUserCheckHistoryDetailImage(modelUserCheckHistory!));
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Card(
                            elevation: 2,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                              width: Get.width,
                              child: InkWell(
                                onTap: () {},
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '인증내역보기',
                                      style: TextStyle(fontWeight: FontWeight.w800),
                                    ),
                                    FaIcon(
                                      FontAwesomeIcons.angleRight,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      ///관리자라면 보이는 승인, 거절 버튼 영역
                      Builder(
                        builder: (context) {
                          MyApp.logger.d(
                              "modelUserCheckHistory!.modelCheckList.modelSite.master : ${modelUserCheckHistory!.modelCheckList.modelSite.master}\n"
                              "MyApp.providerUser.modelUser?.id : ${MyApp.providerUser.modelUser?.id}");
                          return modelUserCheckHistory!.modelCheckList.modelSite.master ==
                                  MyApp.providerUser.modelUser?.id
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(width: 1, color: Colors.orange),
                                          color: Colors.white),
                                      child: InkWell(
                                        onTap: () {
                                          setCheckResult(false);
                                        },
                                        child: Text(
                                          '거절하기',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 30,
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(width: 1, color: Colors.orange),
                                          color: Colors.orange),
                                      child: InkWell(
                                        onTap: () {
                                          setCheckResult(true);
                                        },
                                        child: Text(
                                          '승인처리',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Container();
                        },
                      ),

                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
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

  setCheckResult(bool isGrant) async {
    try {
      MyApp.logger.d("modelUserCheckHistory!.docId : ${modelUserCheckHistory!.docId}");

      await FirebaseFirestore.instance
          .collection(keyUserCheckHistories)
          .doc(modelUserCheckHistory!.docId)
          .update({keyState: isGrant ? keyOn : keyReject});

      valueNotifierIsCheckGrant.value = isGrant;

      //fcm 전송
      sendFcm(isGrant);
    } catch (e) {
      MyApp.logger.wtf("setCheckResult 실패 : ${e.toString()}");
    }
  }

  sendFcm(bool isGrant) async {
    //유저 정보 조회
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(keyUserS)
          .where(keyId, isEqualTo: modelUserCheckHistory!.modelUser.id)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("문서 없음");
      }

      ModelUser modelUser = ModelUser.fromJson(querySnapshot.docs.first.data() as Map, querySnapshot.docs.first.id);

      ///fcm 전송
      /*data = {
         tokens : [...token],
         check : {...유저 인증 내용}
       }*/

      Map<String, dynamic> dataUserCheckHistory = {
        keySite: {
          keyName: modelUserCheckHistory!.modelCheckList.modelSite.name,
        },
        keyCheckList: {
          keyName: modelUserCheckHistory!.modelCheckList.name,
        },
        keyUser: {
          keyName: modelUserCheckHistory!.modelUser.name,
          keyId: modelUserCheckHistory!.modelUser.id,
        }
      };

      dataUserCheckHistory[keyDocId] = Get.parameters[keyUserCheckHistoryId]!;
      MyApp.logger.d("요청 데이터 : ${dataUserCheckHistory.toString()}");

      //전송 시작
      HttpsCallableResult<dynamic> result = await FirebaseFunctions.instanceFor(region: "asia-northeast3")
          .httpsCallable('sendFcmCheckResult')
          .call(<String, dynamic>{
        'tokens': modelUser.listToken,
        'check': dataUserCheckHistory,
        'result': isGrant ? keyOn : keyReject,
      });

      MyApp.logger.d("응답 결과 : ${result.data}");

      //if (result.data[keyAuthenticated] == true) {}
    } catch (e) {
      MyApp.logger.wtf("sendFcm 실패 : ${e.toString()}");
    }
  }
}
