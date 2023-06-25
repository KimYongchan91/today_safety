import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:today_safety/const/model/model_check_list.dart';
import 'package:today_safety/const/model/model_notice.dart';
import 'package:today_safety/const/model/model_site.dart';
import 'package:today_safety/const/model/model_user.dart';
import 'package:today_safety/const/value/key.dart';
import 'package:today_safety/const/value/router.dart';
import 'package:today_safety/const/value/value.dart';
import 'package:today_safety/custom/custom_text_field.dart';
import 'package:today_safety/ui/widget/icon_error.dart';

import '../../custom/custom_text_style.dart';
import '../../my_app.dart';
import '../../service/util/util_list.dart';
import '../../service/util/util_snackbar.dart';

const int _lengthTitleMin = 3;
const int _lengthTitleMax = 20;

const int _lengthBodyMin = 3;
const int _lengthBodyMax = 500;

class RouteNoticeNew extends StatefulWidget {
  final ModelSite modelSite;
  final ModelCheckList? modelCheckList;

  const RouteNoticeNew({required this.modelSite, required this.modelCheckList, Key? key}) : super(key: key);

  @override
  State<RouteNoticeNew> createState() => _RouteNoticeNewState();
}

class _RouteNoticeNewState extends State<RouteNoticeNew> {
  //site의 전체 체크리스트 목록
  List<ModelCheckList> listModelCheckListAll = [];
  late Completer<bool> completerLoadListModelCheckListAll;

  //선택한 체크 리스트 목록
  late ValueNotifier<List<ModelCheckList>> valueNotifierSelectedListModelCheckList;

  //제목
  final TextEditingController textEditingControllerTitle = TextEditingController();

  //본문
  final TextEditingController textEditingControllerBody = TextEditingController();

  //fcm 보낼지
  final ValueNotifier<bool> valueNotifierIsSendFcm = ValueNotifier(true);

  //전송 관련
  ValueNotifier<bool> valueNotifierIsUploading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    completerLoadListModelCheckListAll = Completer();
    _loadListModelCheckListAll();
  }

  @override
  void dispose() {
    super.dispose();

    textEditingControllerTitle.dispose();
    textEditingControllerBody.dispose();
  }

  _loadListModelCheckListAll() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(keyCheckListS)
          .where('$keySite.$keyDocId', isEqualTo: widget.modelSite.docId)
          .orderBy(keyDate)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var element in querySnapshot.docs) {
          ModelCheckList modelCheckList = ModelCheckList.fromJson(element.data() as Map, element.id);
          listModelCheckListAll.add(modelCheckList);
        }

        if (widget.modelCheckList != null) {
          //사전에 미리 선택된 특정 체크리스트가 있음

          valueNotifierSelectedListModelCheckList = ValueNotifier([widget.modelCheckList!]);
        } else {
          //특정 체크리스트가 없음
          //모두 선택
          valueNotifierSelectedListModelCheckList = ValueNotifier([...listModelCheckListAll]);
        }

        completerLoadListModelCheckListAll.complete(true);
      } else {
        completerLoadListModelCheckListAll.complete(false);
      }
    } catch (e) {
      MyApp.logger.wtf("_loadListModelCheckListAll 오류 : ${e.toString()}");
      completerLoadListModelCheckListAll.complete(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      '새 공지 사항',
                      style: CustomTextStyle.bigBlackBold(),
                    ),
                    const SizedBox(
                      height: 20,
                    ),

                    const Text(
                      '대상 팀',
                      style: CustomTextStyle.normalBlackBold(),
                    ),

                    ///대상 팀 리스트뷰
                    FutureBuilder(
                      future: completerLoadListModelCheckListAll.future,
                      builder: (context, snapshot) {
                        if (snapshot.hasData == false) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: LoadingAnimationWidget.inkDrop(color: Colors.green, size: 48),
                          );
                        } else {
                          if (snapshot.data == true) {
                            return ValueListenableBuilder(
                                valueListenable: valueNotifierSelectedListModelCheckList,
                                builder: (context, value, child) => Wrap(
                                      children: [
                                        ...listModelCheckListAll
                                            .map((e) => _ItemSelectedModelCheckList(e, value.contains(e), onTap))
                                      ],
                                    ));
                          } else {
                            return const IconError();
                          }
                        }
                      },
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    ///제목
                    const Text(
                      '제목',
                      style: CustomTextStyle.normalBlackBold(),
                    ),

                    TextField(
                      maxLines: 1,
                      controller: textEditingControllerTitle,
                      maxLength: _lengthTitleMax,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                          enabledBorder: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          hintText: '제목'),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    ///본문
                    const Text(
                      '본문',
                      style: CustomTextStyle.normalBlackBold(),
                    ),

                    TextField(
                      maxLength: _lengthBodyMax,
                      minLines: 8,
                      maxLines: 8,
                      controller: textEditingControllerBody,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                          enabledBorder: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          hintText: '제목'),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    ValueListenableBuilder(
                      valueListenable: valueNotifierIsSendFcm,
                      builder: (context, value, child) => Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: value,
                            onChanged: (value) {
                              if (value != null) {
                                valueNotifierIsSendFcm.value = value;
                              }
                            },
                          ),
                          const Text('사용자에게 알림 전송')
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            ///완료 버튼
            InkWell(
              onTap: complete,
              child: Container(
                width: Get.width,
                height: 70,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: ValueListenableBuilder(
                    valueListenable: valueNotifierIsUploading,
                    builder: (context, value, child) => value
                        ? const CircularProgressIndicator()
                        : const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Text(
                              '완료',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onTap(ModelCheckList modelCheckList) {
    List<ModelCheckList> listModelCheckListNew = [...valueNotifierSelectedListModelCheckList.value];

    if (listModelCheckListNew.contains(modelCheckList)) {
      //이미 포함함
      //제거

      //만약 단 1개뿐이라면
      if (listModelCheckListNew.length == 1) {
        showSnackBarOnRoute('공지사항의 대상 팀은 반드시 있어야 해요.');
        return;
      }
      listModelCheckListNew.removeWhere((element) => element == modelCheckList);
    } else {
      //포함 안됨
      //추가
      listModelCheckListNew.add(modelCheckList);
    }

    valueNotifierSelectedListModelCheckList.value = listModelCheckListNew;
  }

  complete() async {
    if (valueNotifierIsUploading.value == true) {
      return;
    }

    if (textEditingControllerTitle.text.isEmpty) {
      showSnackBarOnRoute('공지사항의 제목을 입력해 주세요.');
      return;
    }

    if (textEditingControllerTitle.text.length < _lengthTitleMin) {
      showSnackBarOnRoute('공지사항의 제목은 최소 $_lengthTitleMin글자예요.');
      return;
    }

    if (textEditingControllerTitle.text.length > _lengthTitleMax) {
      showSnackBarOnRoute('공지사항의 제목은 최대 $_lengthTitleMax글자예요.');
      return;
    }

    if (textEditingControllerBody.text.isEmpty) {
      showSnackBarOnRoute('공지사항의 본문을 입력해 주세요.');
      return;
    }

    if (textEditingControllerBody.text.length < _lengthBodyMin) {
      showSnackBarOnRoute('공지사항의 본문은 최소 $_lengthBodyMin글자예요.');
      return;
    }

    if (textEditingControllerBody.text.length > _lengthBodyMax) {
      showSnackBarOnRoute('공지사항의 본문은 최대 $_lengthBodyMax글자예요.');
      return;
    }

    valueNotifierIsUploading.value = true;

    ModelNotice modelNotice = ModelNotice(
      modelSite: widget.modelSite,
      listModelCheckList: valueNotifierSelectedListModelCheckList.value,
      date: Timestamp.now(),
      title: textEditingControllerTitle.text,
      body: textEditingControllerBody.text,
      isSendFcm: valueNotifierIsSendFcm.value,
    );

    try {
      DocumentReference documentReference =
          await FirebaseFirestore.instance.collection(keyNoticeS).add(modelNotice.toJson());

      Get.toNamed('$keyRouteNoticeDetail/${documentReference.id}', arguments: {keyModelNotice: modelNotice});

      showSnackBarOnRoute('공지사항을 게시했어요.');

      //fcm 전송
      sendFcm(modelNotice, documentReference);
      //최근 7일 이내에 이 팀에 인증한 사용자 찾기

      valueNotifierIsUploading.value = false;
    } catch (e) {
      MyApp.logger.wtf('공지사항 게시 실패 : ${e.toString()}');
      valueNotifierIsUploading.value = false;
    }
  }

  sendFcm(ModelNotice modelNotice, DocumentReference documentReference) async {
    //토큰 리스트를 받아와야함

    List<String> listCheckListId = [
      ...valueNotifierSelectedListModelCheckList.value.map(
        (e) => e.docId,
      )
    ];
    MyApp.logger.d("listCheckListId : ${listCheckListId.toString()}");

    Timestamp timestampBefore =
        Timestamp.fromMillisecondsSinceEpoch(Timestamp.now().millisecondsSinceEpoch - millisecondDay * 7); //7일전

    //유저 정보 조회
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(keyUserCheckHistories)
          .where('$keyCheckList.$keyDocId', whereIn: listCheckListId)
          .where(keyDate, isGreaterThanOrEqualTo: timestampBefore)
          .get();

      //유저 아이디 set
      Set<String> setUserId = {};

      if (querySnapshot.docs.isNotEmpty) {
        for (var element in querySnapshot.docs) {
          Map data = element.data() as Map;
          String? id = data[keyUser]?[keyId];
          if (id != null) {
            setUserId.add(id);
          }
        }
      }

      List<List<String>> listUserIdSliced = getListSlice<String>(setUserId.toList(), 10);

      List<Future> listFuture = [];
      Set<String> setToken = {};
      for (var element in listUserIdSliced) {
        listFuture
            .add(FirebaseFirestore.instance.collection(keyUserS).where(keyId, whereIn: element).get().then((value) {
          for (var element in value.docs) {
            ModelUser modelUser = ModelUser.fromJson(element.data() as Map, element.id);
            setToken.addAll([...modelUser.listToken]);
          }
        }).catchError((e) {
          MyApp.logger.wtf("에러 발생 : ${e.toString()}");
        }));
      }

      await Future.wait(listFuture);

      ///fcm 전송
      /*data = {
         tokens : [...token],
         notice : {...공지사항}
       }*/

      Map<String, dynamic> dataNotice = modelNotice.toJson(isForServerForm: true);
      dataNotice[keyDocId] = documentReference.id;
      //임시로 check_list 값을 없앰.
      //timestamp data type 문제
      dataNotice.remove(keyCheckList);
      MyApp.logger.d("요청 데이터 : ${dataNotice.toString()}");

      //전송 시작
      HttpsCallableResult<dynamic> result = await FirebaseFunctions.instanceFor(region: "asia-northeast3")
          .httpsCallable('sendFcmNotice')
          .call(<String, dynamic>{
        'tokens': setToken.toList(),
        'notice': dataNotice,
      });

      MyApp.logger.d("응답 결과 : ${result.data}");

      //if (result.data[keyAuthenticated] == true) {}
    } catch (e) {
      MyApp.logger.wtf("sendFcm 실패 : ${e.toString()}");
    }
  }
}

class _ItemSelectedModelCheckList extends StatelessWidget {
  final ModelCheckList modelCheckList;
  final bool isSelected;
  final void Function(ModelCheckList) onTap;

  const _ItemSelectedModelCheckList(this.modelCheckList, this.isSelected, this.onTap, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap(modelCheckList);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.red : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(modelCheckList.name),
        ),
      ),
    );
  }
}
