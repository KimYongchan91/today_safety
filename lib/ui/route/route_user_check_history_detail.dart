import 'dart:async';
import 'dart:ui' as ui;

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:today_safety/const/model/model_check.dart';
import 'package:today_safety/const/model/model_check_image.dart';
import 'package:today_safety/const/value/fuc.dart';
import 'package:today_safety/const/value/key.dart';
import 'package:today_safety/const/value/value.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/ui/route/route_check_image_detail.dart';
import 'package:today_safety/ui/widget/icon_error.dart';

import '../../const/model/model_check_list.dart';
import '../../const/model/model_user.dart';
import '../../const/model/model_user_check_history.dart';
import '../../const/value/router.dart';
import '../../my_app.dart';
import '../../service/util/util_app_link.dart';
import '../../service/util/util_user_check_history.dart';
import '../item/item_check.dart';

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
                      const SizedBox(
                        height: 10,
                      ),

                      ///앱 아이콘
                      Row(
                        children: [
                          const Spacer(),
                          AnimatedTextKit(
                            pause: const Duration(milliseconds: 1000),
                            repeatForever: true,
                            animatedTexts: [
                              ColorizeAnimatedText('오늘 안전',
                                  textStyle: const CustomTextStyle.bigBlackBold(),
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

                      const SizedBox(
                        height: 30,
                      ),

                      ///QR 코드 부분
                      SizedBox(
                        width: Get.width * 0.6,
                        height: Get.width * 0.6,
                        child: SfBarcodeGenerator(
                          value:
                              '$urlBaseAppLink$keyRouteUserCheckHistoryDetail/${Get.parameters[keyUserCheckHistoryId]}',
                          symbology: QRCode(),
                          showValue: false,
                        ),
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      ///사용자 이름
                      const Text(
                        '이름',
                        style: CustomTextStyle.smallBlackBold(),
                      ),

                      Text(
                        '${modelUserCheckHistory!.modelUser.name} (${modelUserCheckHistory!.modelUser.idExceptLT})',
                        style: const CustomTextStyle.bigBlackBold(),
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      ///근무지 이름
                      const Text(
                        '근무지',
                        style: CustomTextStyle.smallBlackBold(),
                      ),

                      Text(
                        modelUserCheckHistory!.modelCheckList.modelSite.name,
                        style: const CustomTextStyle.normalBlackBold(),
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      ///근무지 내 팀명
                      const Text(
                        '팀',
                        style: CustomTextStyle.smallBlackBold(),
                      ),

                      Text(
                        modelUserCheckHistory!.modelCheckList.name,
                        style: const CustomTextStyle.normalBlackBold(),
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      ///인증 날짜
                      const Text(
                        '인증일자',
                        style: CustomTextStyle.smallBlackBold(),
                      ),

                      Text(
                        DateFormat('yyyy-MM-dd hh:mm:ss').format(modelUserCheckHistory!.date.toDate()),
                        style: const CustomTextStyle.normalBlackBold(),
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      ///인증 날짜
                      const Text(
                        '유효기간',
                        style: CustomTextStyle.smallBlackBold(),
                      ),

                      Text(
                        // +1 일
                        '${DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(modelUserCheckHistory!.date.toDate().millisecondsSinceEpoch + millisecondDay))} 까지',
                        style: const CustomTextStyle.normalBlackBold(),
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      ///인증 사진
                      ExpandablePanel(
                        header: Container(
                          height: 40,
                          //decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                          child: const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '인증 사진',
                              style: CustomTextStyle.smallBlackBold(),
                            ),
                          ),
                        ),
                        theme: const ExpandableThemeData(
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
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder: (context, index) => const SizedBox(
                                height: 20,
                              ),
                            ),
                          ],
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
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        setCheckResult(false);
                                      },
                                      child: const Text('거절'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setCheckResult(true);
                                      },
                                      child: const Text('승인'),
                                    ),
                                    ValueListenableBuilder(
                                      valueListenable: valueNotifierIsCheckGrant,
                                      builder: (context, value, child) {
                                        if (value == true) {
                                          return const Text(
                                            '승인했어요.',
                                            style: CustomTextStyle.normalBlack(),
                                          );
                                        } else if (value == false) {
                                          return const Text(
                                            '거절했어요.',
                                            style: CustomTextStyle.normalBlack(),
                                          );
                                        } else {
                                          return Container();
                                        }
                                      },
                                    ),
                                  ],
                                )
                              : Container();
                        },
                      ),
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

      ModelUser modelUser =
          ModelUser.fromJson(querySnapshot.docs.first.data() as Map, querySnapshot.docs.first.id);

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

class _ItemCheckImage extends StatelessWidget {
  final ModelCheckImage modelCheckImage;

  const _ItemCheckImage(this.modelCheckImage, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ModelCheck modelCheck = getModelCheck(modelCheckImage.fac ?? '');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ///인증 항목 정보
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xffbbd6fd)),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset(
                  getPathCheckImage(modelCheck),
                  width: 50,
                  height: 50,
                ),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Text(
              modelCheck.name,
              style: const TextStyle(color: Colors.black54, fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ],
        ),

        ///인증 날짜
        Text('${DateFormat('yyyy-MM-dd hh:mm:ss').format(modelCheckImage.date.toDate())} 촬영'),

        ///인증 사진
        AspectRatio(
          aspectRatio: 1.618 / 1,
          child: CachedNetworkImage(
            imageUrl: modelCheckImage.urlImage,
            fit: BoxFit.cover,
          ),
        ),

        ///카메라 방향
        ///필요 없을 듯
        //Text('${modelCheckImage.cameraDirection}'),
      ],
    );
  }
}
