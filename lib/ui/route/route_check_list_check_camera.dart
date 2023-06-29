import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:today_safety/const/model/model_check.dart';
import 'package:today_safety/const/model/model_check_list.dart';
import 'package:today_safety/const/model/model_device.dart';
import 'package:today_safety/const/model/model_location.dart';
import 'package:today_safety/const/model/model_notice.dart';
import 'package:today_safety/const/model/model_user.dart';
import 'package:today_safety/const/model/model_user_check_history.dart';
import 'package:today_safety/const/value/color.dart';
import 'package:today_safety/const/value/key.dart';
import 'package:today_safety/const/value/router.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/custom/custom_value_listenable_builder2.dart';
import 'package:today_safety/service/util/util_location.dart';
import 'package:path/path.dart' as pt;
import 'package:today_safety/service/util/util_snackbar.dart';

import '../../const/model/model_check_image.dart';
import '../../const/model/model_check_image_local.dart';
import '../../const/value/fuc.dart';
import '../../my_app.dart';
import '../../service/util/util_firestore.dart';
import '../dialog/dialog_close_route.dart';
import '../item/item_check_image_local.dart';

const double _sizeImageCheckSequence = 50;

class RouteCheckListCheckCamera extends StatefulWidget {
  final ModelCheckList modelCheckList;

  const RouteCheckListCheckCamera(this.modelCheckList, {Key? key}) : super(key: key);

  @override
  State<RouteCheckListCheckCamera> createState() => _RouteCheckListCheckCameraState();
}

class _RouteCheckListCheckCameraState extends State<RouteCheckListCheckCamera> {
  //카메라 관련
  late Completer<bool> completerInit;
  bool isInitSuccess = false;
  late CameraController cameraController;
  late List<CameraDescription> listCameraDescription;

  //현재 몇 번째 체크를 인증하는 중인지
  //밑의 valueNotifierIndexCheckShowResult와 null이 아닐 경우의 값이 같아야 함.
  ValueNotifier<int> valueNotifierIndexCheck = ValueNotifier(0);

  //check별로 사진 촬영 정보를 담은 map
  //해당 check를 인증하기 전이라면 값은 null
  ValueNotifier<Map<ModelCheck, ModelCheckImageLocal>> valueNotifierMapCheckImageLocal = ValueNotifier({});

  //현재 사진 촬영 결과를 보여준다면 해당 index를, 아니면 null을 저장하는 벨류 노티파이어
  //위의 valueNotifierIndexCheck null이 아닐 경우의 값이 같아야 함.
  ValueNotifier<int?> valueNotifierIndexCheckShowResult = ValueNotifier(null);

  //촬영 과정을 circular 인디케이터를 이용해 보여주기 위한 벨류 노티파이어
  ValueNotifier<bool> valueNotifierIsProcessingTakePhoto = ValueNotifier(false);

  //위치 관련
  ModelLocation? modelLocation;
  late Completer completerGetModelLocation;

  //서버로 전송
  ValueNotifier<bool> valueNotifierIsUploadingToServer = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    //카메라 초기화
    initCamera();
    initLocation();
    //
    for (var element in widget.modelCheckList.listModelCheck) {}
  }

  @override
  void dispose() {
    if (isInitSuccess) {
      MyApp.logger.d("카메라 컨트롤 dispose");
      cameraController.dispose();
    }
    super.dispose();
  }

  initLocation() async {
    completerGetModelLocation = Completer();
    Position? position;

    try {
      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      MyApp.logger.d("위치 조회 성공 : ${position.latitude}, ${position.longitude}");
    } on Exception catch (e) {
      MyApp.logger.wtf("위치 조회 실패 : ${e.toString()}");
    }

    if (position == null) {
      //showSnackBarOnRoute('위치 조회에 실패했어요.\n잠시 후 다시 시도해 주세요.');
      completerGetModelLocation.complete();
      return;
    }

    modelLocation = await getModelLocationWeatherFromLatLng(
      position.latitude,
      position.longitude,
    );
    if (modelLocation == null) {
      //showSnackBarOnRoute('위치 조회에 실패했어요.\n잠시 후 다시 시도해 주세요.');
      completerGetModelLocation.complete();
      return;
    }

    MyApp.logger.d("카카오에서 받아온 주소 정보 : ${modelLocation!.toJson().toString()}");

    //인증한 사진이 있다면 뒤늦게 라도 적용
    //해당 기능 삭제
/*    if (valueNotifierMapCheckHistoryLocal.value.isNotEmpty) {
      MyApp.logger.d("뒤늦게 위치 적용함");

      Map<ModelCheck, ModelCheckHistoryLocal> mapNew = {...valueNotifierMapCheckHistoryLocal.value};
      for (var element in valueNotifierMapCheckHistoryLocal.value.keys) {
        mapNew[element]?.modelLocation = modelLocation;
      }
    }*/
  }

  initCamera() async {
    completerInit = Completer();

    completerInit.future.then((value) {
      isInitSuccess = value;
    });

    try {
      listCameraDescription = await availableCameras();
    } on Exception catch (e) {
      MyApp.logger.wtf('카메라 정보 불러오는 데 실패 : ${e.toString()}');
      completerInit.complete(false);
      return;
    }
    CameraDescription? cameraDescriptionFront;

    for (var element in listCameraDescription) {
      if (element.lensDirection == CameraLensDirection.back) {
        cameraDescriptionFront = element;
      }
    }

    if (cameraDescriptionFront == null) {
      MyApp.logger.wtf('후면 카메라 없음');
      completerInit.complete(false);
      return;
    }

    cameraController = CameraController(cameraDescriptionFront, ResolutionPreset.medium);

    try {
      await cameraController.initialize();
      completerInit.complete(true);
    } on Exception catch (e) {
      MyApp.logger.wtf('카메라 컨트롤러 초기화 실패 : ${e.toString()}');
      completerInit.complete(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: SizedBox(
            width: Get.width,
            height: Get.height,
            child: FutureBuilder<bool>(
              future: completerInit.future,
              builder: (context, snapshot) {
                if (snapshot.hasData == false) {
                  return  Center(
                    child: LoadingAnimationWidget.inkDrop(color: Colors.green, size: 32),
                  );
                } else if (snapshot.data == false) {
                  return const Center(
                    child: Icon(Icons.error),
                  );
                } else {
                  return Stack(
                    children: [
                      ///카메라 뷰 (전체화면)
                      Positioned.fill(
                        child: ValueListenableBuilder(
                          valueListenable: valueNotifierIndexCheckShowResult,
                          builder: (context, value, child) => value != null

                              ///사진 촬영 결과를 보여주는 부분
                              ? ItemCheckImageLocal(valueNotifierMapCheckImageLocal
                                  .value[widget.modelCheckList.listModelCheck[valueNotifierIndexCheck.value]])
                              :

                              ///촬영 전 카메라 뷰
                              CameraPreview(cameraController),
                        ),
                      ),

                      ///인증 진행도 부분
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          color: const Color(0x55000000),
                          width: Get.width,
                          height: Get.height / 6,
                          child: Container(
                            height: _sizeImageCheckSequence + 10,
                            child: CustomValueListenableBuilder2(
                              a: valueNotifierMapCheckImageLocal,
                              b: valueNotifierIndexCheck,
                              builder: (context, a, b, child) => ListView.builder(
                                itemCount: widget.modelCheckList.listModelCheck.length,

                                ///진행도 아이템
                                itemBuilder: (context, index) => InkWell(
                                  onTap: () {
                                    changeIndexCheck(index);
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ///이미지
                                      Container(
                                        width: _sizeImageCheckSequence,
                                        height: _sizeImageCheckSequence,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: a[widget.modelCheckList.listModelCheck[index]] != null
                                                ? Colors.green
                                                : b == index
                                                    ? Colors.blueAccent
                                                    : Colors.red,
                                            width: 3,
                                          ),
                                        ),
                                        child: Image.asset(
                                          getPathCheckImage(widget.modelCheckList.listModelCheck[index]),
                                          width: _sizeImageCheckSequence,
                                          height: _sizeImageCheckSequence,
                                        ),
                                      ),

                                      ///현재 진행 중이라면 현재 체크 항목의 제목까지
                                      b == index
                                          ? Text(
                                              widget.modelCheckList.listModelCheck[index].name,
                                              style: CustomTextStyle.bigBlackBold(),
                                            )
                                          : Container()
                                    ],
                                  ),
                                ),
                                scrollDirection: Axis.horizontal,
                              ),
                            ),
                          ),
                        ),
                      ),

                      ///인증 방법 설명 부분
/*                  Positioned(
                        top: Get.mediaQuery.viewPadding.top,
                        left: 0,
                        right: 0,
                        child: Visibility(
                            visible: widget.modelCheckList != null,
                            child: ValueListenableBuilder(
                              valueListenable: valueNotifierIndexCheck,
                              builder: (context, value, child) => ExpandablePanel(
                                ///설명의 헤더 (항상 보이는)
                                header: Text(widget.modelCheckList!.listModelCheck[value].name),

                                ///설명의 바디 (축소되었을 때)
                                collapsed: Container(),

                                ///설명의 바디 (확장되었을 때)
                                expanded: ItemCheck(widget.modelCheckList!.listModelCheck[value]),
                                theme: const ExpandableThemeData(
                                  hasIcon: true,
                                  iconSize: 36,
                                ),
                              ),
                            )),
                      ),*/

                      /*

                    ValueListenableBuilder(
                          valueListenable: valueNotifierIndexCheckShowResult,
                          builder: (context, value, child) =>

                              ///현재 사진 촬영 결과를 보여주고 있다면?
                              value != null
                                  ? Image.file(File(valueNotifierMapCheckHistoryLocal
                                          .value[widget.modelCheckList.listModelCheck[valueNotifierIndexCheck.value]]
                                          ?.xFile
                                          .path ??
                                      ''))
                                  :

                                  ///일반적인 촬영 중이라면?
                                  CameraPreview(cameraController),
                        )
                     */

                      /// 재활영 , 인증 버튼
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: ValueListenableBuilder(
                              valueListenable: valueNotifierIndexCheckShowResult,
                              builder: (context, value, child) {
                                ///현재 사진 촬영 결과를 보여주고 있다면?
                                return value != null
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                                        height: Get.height / 6,
                                        width: Get.width,
                                        color: const Color(0x55000000),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: InkWell(
                                                onTap: () {
                                                  removePhoto();
                                                },
                                                child: Container(
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(20),
                                                        color: const Color(0x55000000)),
                                                    child: const Text(
                                                      '다시 촬영',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 18,
                                                          color: Colors.white),
                                                    )),
                                              ),
                                            ),

                                            const SizedBox(
                                              width: 20,
                                            ),

                                            ///인증 완료 버튼
                                            ///모든 촬영이 완료되었을 때는 초록색으로 강조
                                            Expanded(
                                              flex: 1,
                                              child: CustomValueListenableBuilder2(
                                                a: valueNotifierIsUploadingToServer,
                                                b: valueNotifierMapCheckImageLocal,
                                                builder: (context, a, b, child) => InkWell(
                                                  onTap: completeCheck,
                                                  child: a
                                                      ? LoadingAnimationWidget.inkDrop(
                                                          color: Colors.white,
                                                          size: 20,
                                                        )
                                                      : Container(
                                                          alignment: Alignment.center,
                                                          decoration: BoxDecoration(
                                                            color: b.values.length ==
                                                                    widget
                                                                        .modelCheckList.listModelCheck.length

                                                                ///모든 인증이 완료되었을 때
                                                                ? Colors.greenAccent
                                                                : const Color(0x33ffffff),
                                                            borderRadius: BorderRadius.circular(20),
                                                          ),
                                                          child: const Text(
                                                            '인증 완료',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.bold),
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    : SizedBox();
                              })),

                      ///로딩 애니메
                      Align(
                          alignment: Alignment.center,
                          child: ValueListenableBuilder(
                              valueListenable: valueNotifierIndexCheckShowResult,
                              builder: (context, value, child) {
                                ///현재 사진 촬영 결과를 보여주고 있다면?
                                return value != null
                                    ? const SizedBox()
                                    :

                                    ///일반적인 촬영 중이라면?
                                    ValueListenableBuilder(
                                        valueListenable: valueNotifierIsProcessingTakePhoto,
                                        builder: (context, value, child) => value

                                            ///촬영 처리 중 아이콘
                                            ? LoadingAnimationWidget.inkDrop(
                                                color: Colors.white,
                                                size: 20,
                                              )

                                            ///촬영 하기 전
                                            : SizedBox(),
                                      );
                              })),

                      ///촬영버튼
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: ValueListenableBuilder(
                              valueListenable: valueNotifierIndexCheckShowResult,
                              builder: (context, value, child) {
                                ///현재 사진 촬영 결과를 보여주고 있다면?
                                return value != null
                                    ? const SizedBox()
                                    :

                                    ///일반적인 촬영 중이라면?
                                    ValueListenableBuilder(
                                        valueListenable: valueNotifierIsProcessingTakePhoto,
                                        builder: (context, value, child) => value

                                            ///촬영 처리 중 아이콘
                                            ? SizedBox()

                                            ///촬영 하기 전
                                            : Container(
                                                padding: const EdgeInsets.symmetric(vertical: 35),
                                                height: Get.height / 6,
                                                width: Get.width,
                                                color: const Color(0x55000000),
                                                child: Row(
                                                  children: [
                                                    const Expanded(flex: 1, child: SizedBox()),

                                                    ///촬영 버튼
                                                    Expanded(
                                                      flex: 1,
                                                      child: InkWell(
                                                        onTap: () {
                                                          takePhoto();
                                                        },
                                                        child: Container(
                                                          width: 80,
                                                          decoration: const BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            color: Colors.white,
                                                          ),
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(5),
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  shape: BoxShape.circle,
                                                                  color: Colors.white,
                                                                  border: Border.all(
                                                                      width: 0.5, color: Colors.black45)),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    ///카메라 전환
                                                    Expanded(
                                                      flex: 1,
                                                      child: InkWell(
                                                        onTap: () {
                                                          changeCameraDirection();
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Container(
                                                              alignment: Alignment.center,
                                                              padding: const EdgeInsets.all(10),
                                                              decoration: const BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                color: Color(0x55000000),
                                                              ),
                                                              child: const FaIcon(
                                                                FontAwesomeIcons.arrowRotateRight,
                                                                color: Colors.white,
                                                              )),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                      );
                              })),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  changeCameraDirection() {
    if (isInitSuccess == false) {
      return;
    }

    switch (cameraController.description.lensDirection) {
      case CameraLensDirection.front:
        for (var element in listCameraDescription) {
          if (element.lensDirection == CameraLensDirection.back) {
            cameraController.setDescription(element);
            break;
          }
        }

        break;
      case CameraLensDirection.back:
        for (var element in listCameraDescription) {
          if (element.lensDirection == CameraLensDirection.front) {
            cameraController.setDescription(element);
            break;
          }
        }
        break;
      case CameraLensDirection.external:
        break;
    }
  }

  takePhoto() async {
    if (valueNotifierIsProcessingTakePhoto.value) {
      return;
    }
    valueNotifierIsProcessingTakePhoto.value = true;

    //cameraController.pausePreview();
    XFile xFile = await cameraController.takePicture();
    MyApp.logger.d('촬영된 사진 주소 : ${xFile.path}');

    //
    ModelCheckImageLocal modelCheckHistoryLocal = ModelCheckImageLocal(
      modelCheck: widget.modelCheckList.listModelCheck[valueNotifierIndexCheck.value],
      date: Timestamp.now(),
      xFile: xFile,
      cameraLensDirection: cameraController.description.lensDirection,
    );

    Map<ModelCheck, ModelCheckImageLocal> mapNew = {...valueNotifierMapCheckImageLocal.value};
    mapNew[widget.modelCheckList.listModelCheck[valueNotifierIndexCheck.value]] = modelCheckHistoryLocal;
    valueNotifierMapCheckImageLocal.value = mapNew;

    //다음 페이지로
    moveNextIndexChange();

    valueNotifierIsProcessingTakePhoto.value = false;

    //valueNotifierIndexCheckShowResult.value = valueNotifierIndexCheck.value;

    //Get.back(result: xFile);
  }

  changeIndexCheck(int index) {
    if (valueNotifierMapCheckImageLocal.value[widget.modelCheckList.listModelCheck[index]] == null) {
      //해당 index가 아직 촬영 전이라면
      valueNotifierIndexCheck.value = index;
      valueNotifierIndexCheckShowResult.value = null;
      //cameraController.resumePreview();
    } else {
      //이미 촬영 했다면
      valueNotifierIndexCheck.value = index;
      valueNotifierIndexCheckShowResult.value = index;
    }
  }

  moveNextIndexChange() {
    bool isAllCheck = true;
    for (var element in widget.modelCheckList.listModelCheck) {
      if (valueNotifierMapCheckImageLocal.value[element] == null) {
        //MyApp.logger.d("촬영 안 한 인증이 있음");
        isAllCheck = false;
        break;
      }
    }

    if (isAllCheck) {
      //모든 인증이 완료되었다면? 즉 다음이 없다면?
      //현재 페이지를 기준으로 멈춤(결과를 보여줌)
      valueNotifierIndexCheckShowResult.value = valueNotifierIndexCheck.value;
    } else {
      //다음이 있다면
      //사진 촬영 안한 인덱스로 이동
      for (int i = 0; i < widget.modelCheckList.listModelCheck.length; i++) {
        if (valueNotifierMapCheckImageLocal.value[widget.modelCheckList.listModelCheck[i]] == null) {
          changeIndexCheck(i);
          break;
        }
      }
    }
  }

  removePhoto() {
    Map<ModelCheck, ModelCheckImageLocal> mapNew = {...valueNotifierMapCheckImageLocal.value};
    mapNew.remove(widget.modelCheckList.listModelCheck[valueNotifierIndexCheck.value]);
    valueNotifierMapCheckImageLocal.value = mapNew;
    valueNotifierIndexCheckShowResult.value = null;
  }

  completeCheck() async {
    if (valueNotifierIsUploadingToServer.value) {
      return;
    }

    if (valueNotifierMapCheckImageLocal.value.values.length != widget.modelCheckList.listModelCheck.length) {
      showSnackBarOnRoute('아직 인증하지 않은 항목이 있어요.');
      return;
    }

    if (MyApp.providerUser.modelUser == null) {
      showSnackBarOnRoute(messageNeedLogin);
      return;
    }
    valueNotifierIsUploadingToServer.value = true;

    //현재 날짜
    final Timestamp timestampNow = Timestamp.now();
    final String displayDateToday = DateFormat('yyyy-MM-dd').format(timestampNow.toDate());

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    ModelDevice modelDevice;

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      modelDevice = ModelDevice(
        model: androidInfo.model,
        os: keyAndroid,
        osVersion: androidInfo.version.sdkInt.toString(),
      );
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      modelDevice = ModelDevice(
        model: iosInfo.utsname.machine,
        os: keyIos,
        osVersion: iosInfo.systemVersion,
      );
    } else {
      modelDevice = ModelDevice.fromJson({});
    }

    MyApp.logger.d('디바이스 모델 : ${modelDevice.toJson().toString()}');

    ModelUserCheckHistory modelUserCheckHistory = ModelUserCheckHistory(
      modelCheckList: widget.modelCheckList,
      //modelSite: widget.modelCheckList.modelSite,
      modelUser: MyApp.providerUser.modelUser!,
      date: timestampNow,
      dateDisplay: displayDateToday,
      dateWeek: timestampNow.toDate().weekday,
      modelLocation: modelLocation!,
      modelDevice: modelDevice,
      listModelCheckImage: [],
      //비어있는 전송 상태로 시작
      state: keyPend,
    );

    ///user_check_history 문서 생성
    DocumentReference documentReference = await FirebaseFirestore.instance
        .collection(keyUserCheckHistories)
        .add(modelUserCheckHistory.toJson());
    modelUserCheckHistory.docId = documentReference.id;

    ///이미지 전송
    List<Completer> listCompleterUploadImageToServer = [];
    List<ModelCheckImage> listModelCheckImage = [];
    for (var element in valueNotifierMapCheckImageLocal.value.values) {
      Completer completerUploadImageToServer = Completer();
      listCompleterUploadImageToServer.add(completerUploadImageToServer);

      String cameraDirection;
      if (element.cameraLensDirection == CameraLensDirection.front) {
        cameraDirection = keyFront;
      } else if (element.cameraLensDirection == CameraLensDirection.back) {
        cameraDirection = keyBack;
      } else {
        cameraDirection = '';
      }

      ModelCheckImage modelCheckImage = ModelCheckImage(
        name: element.modelCheck.name,
        date: element.date,
        fac: element.modelCheck.fac,
        urlImage: '',
        cameraDirection: cameraDirection,
      );

      FirebaseStorage.instance
          .ref(
              "$keyImages/$keyUserCheckHistories/${documentReference.id}/${pt.basename(File(element.xFile.path).path)}")
          .putFile(File(element.xFile.path))
          .then((uploadTask) {
        MyApp.logger.d('서버로 사진 전송 성공 : ${uploadTask.ref.toString()}');
        return uploadTask.ref.getDownloadURL();
      }).then((urlDownload) {
        MyApp.logger.d('다운로드 url 조회 성공 : $urlDownload');
        modelCheckImage.urlImage = urlDownload;
        listModelCheckImage.add(modelCheckImage);
        completerUploadImageToServer.complete();
      });
    }

    ///모든 이미지 전송될때까지 기다림
    await Future.wait([...listCompleterUploadImageToServer.map((e) => e.future).toList()]);

    ///전송된 이미지들 정렬
    List<String> listName = [
      ...valueNotifierMapCheckImageLocal.value.values.map((e) => e.modelCheck.name).toList()
    ];
    listModelCheckImage.sort(
      (a, b) {
        return listName.indexOf(a.name).compareTo(listName.indexOf(b.name));
      },
    );

    ///user_check_history 문서 수정
    await documentReference.update({
      keyImage: getListModelCheckImageFromLocal(listModelCheckImage),
    });

    ///chek_lists의 daily_check_histories 문서 수정
    ///추후에 할 예정
    //먼저 문서가 있나 조회

    FirebaseFirestore.instance
        .collection(keyCheckListS)
        .doc(widget.modelCheckList.docId)
        .collection(keyDailyCheckHistories)
        .where(keyDateDisplay, isEqualTo: displayDateToday)
        .limit(1)
        .get()
        .then((querySnapshot) {
      Map<String, dynamic> data = modelUserCheckHistory.toJson();

      //문서가 있음
      if (querySnapshot.docs.isNotEmpty) {
        querySnapshot.docs.first.reference.update({
          keyUserCheckHistoryCount: FieldValue.increment(1),
          keyUserCheckHistory: FieldValue.arrayUnion([
            modelUserCheckHistory.toJson(),
          ])
        });
      } else {
        //문서가 없음

        FirebaseFirestore.instance
            .collection(keyCheckListS)
            .doc(widget.modelCheckList.docId)
            .collection(keyDailyCheckHistories)
            .add({
          keyDate: timestampNow,
          keyDateDisplay: displayDateToday,
          keyDateWeek: timestampNow.toDate().weekday,
          keyUserCheckHistoryCount: 1,
          keyUserCheckHistory: [
            modelUserCheckHistory.toJson(),
          ],
        });
      }
    });

    valueNotifierIsUploadingToServer.value = false;

    //이 site에 대한 리스너 등록
    MyApp.providerUser.getModelNotice(siteDocIdNew: widget.modelCheckList.modelSite.docId);

    //관리자에게 fcm 전송
    sendFcm(modelUserCheckHistory, documentReference.id);

    //user check history detail 페이지로 이동

    //Get.offNamed('$keyRouteUserCheckHistoryDetail/${documentReference.id}');
    Get.offNamedUntil('$keyRouteUserCheckHistoryDetail/${documentReference.id}',
        (route) => route.settings.name == keyRouteMain);

    showSnackBarOnRoute('인증을 완료했어요.');
    //await FirebaseFirestore.instance.collection(keyUserChecks).add({});
  }

  sendFcm(ModelUserCheckHistory modelUserCheckHistory, String docId) async {
    //유저 정보 조회
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(keyUserS)
          .where(keyId, isEqualTo: modelUserCheckHistory.modelCheckList.modelSite.master)
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
          keyName: modelUserCheckHistory.modelCheckList.modelSite.name,
        },
        keyCheckList: {
          keyName: modelUserCheckHistory.modelCheckList.name,
        },
        keyUser: {
          keyName: modelUserCheckHistory.modelUser.name,
          keyId: modelUserCheckHistory.modelUser.id,
        }
      };

      dataUserCheckHistory[keyDocId] = docId;
      MyApp.logger.d("요청 데이터 : ${dataUserCheckHistory.toString()}");

      //전송 시작
      HttpsCallableResult<dynamic> result = await FirebaseFunctions.instanceFor(region: "asia-northeast3")
          .httpsCallable('sendFcmCheckNew')
          .call(<String, dynamic>{
        'tokens': modelUser.listToken,
        'check': dataUserCheckHistory,
      });

      MyApp.logger.d("응답 결과 : ${result.data}");

      //if (result.data[keyAuthenticated] == true) {}
    } catch (e) {
      MyApp.logger.wtf("sendFcm 실패 : ${e.toString()}");
    }
  }

  Future<bool> onWillPop() async {
    var result = await Get.dialog(const DialogCloseRoute(
      content: '저장하지 않고 나갈까요?',
      labelButton: '나가기',
    ));
    if (result == true) {
      return true;
    } else {
      return false;
    }
  }
}
