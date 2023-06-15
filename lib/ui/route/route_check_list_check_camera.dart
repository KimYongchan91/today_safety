import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:today_safety/const/model/model_check.dart';
import 'package:today_safety/const/model/model_check_list.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/custom/custom_value_listenable_builder2.dart';

import '../../const/model/model_check_history_local.dart';
import '../../const/value/fuc.dart';
import '../../my_app.dart';

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
  ValueNotifier<Map<ModelCheck, ModelCheckHistoryLocal>> valueNotifierMapCheckHistoryLocal = ValueNotifier({});

  //현재 사진 촬영 결과를 보여준다면 해당 index를, 아니면 null을 저장하는 벨류 노티파이어
  //위의 valueNotifierIndexCheck null이 아닐 경우의 값이 같아야 함.
  ValueNotifier<int?> valueNotifierIndexCheckShowResult = ValueNotifier(null);

  @override
  void initState() {
    super.initState();

    //카메라 초기화
    initCamera();

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
    return Scaffold(
      body: SizedBox(
        width: Get.width,
        height: Get.height,
        child: FutureBuilder<bool>(
          future: completerInit.future,
          builder: (context, snapshot) {
            if (snapshot.hasData == false) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.data == false) {
              return const Center(
                child: Icon(Icons.error),
              );
            } else {
              return Stack(
                children: [
                  ///카메라 뷰(전체화면)
                  Positioned.fill(
                    child: ValueListenableBuilder(
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
                    ),
                  ),

                  ///인증 진행도 부분
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: SizedBox(
                        height: _sizeImageCheckSequence + 10,
                        child: CustomValueListenableBuilder2(
                          a: valueNotifierMapCheckHistoryLocal,
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
                                        width: 5,
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
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: ValueListenableBuilder(
                          valueListenable: valueNotifierIndexCheckShowResult,
                          builder: (context, value, child) {
                            ///현재 사진 촬영 결과를 보여주고 있다면?
                            return value != null
                                ? Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {},
                                        child: Text('다시 촬영'),
                                      ),
                                    ],
                                  )
                                :

                                ///일반적인 촬영 중이라면?
                                Row(
                                    children: [
                                      ///촬영 버튼
                                      ElevatedButton(
                                        onPressed: takePhoto,
                                        child: const Text('적용'),
                                      ),

                                      ///카메라 방향 전환 버튼
                                      ElevatedButton(
                                        onPressed: changeCameraDirection,
                                        child: const Text('카메라 전환'),
                                      ),
                                    ],
                                  );
                          })),
                ],
              );
            }
          },
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
        // TODO: Handle this case.
        break;
    }
  }

  takePhoto() async {
    //cameraController.pausePreview();
    XFile xFile = await cameraController.takePicture();
    MyApp.logger.d('촬영된 사진 주소 : ${xFile.path}');

    //
    ModelCheckHistoryLocal modelCheckHistoryLocal = ModelCheckHistoryLocal(
      modelCheck: widget.modelCheckList.listModelCheck[valueNotifierIndexCheck.value],
      date: Timestamp.now(),
      xFile: xFile,
      cameraLensDirection: cameraController.description.lensDirection,
    );

    Map<ModelCheck, ModelCheckHistoryLocal> mapNew = {...valueNotifierMapCheckHistoryLocal.value};
    mapNew[widget.modelCheckList.listModelCheck[valueNotifierIndexCheck.value]] = modelCheckHistoryLocal;
    valueNotifierMapCheckHistoryLocal.value = mapNew;

    //다음 페이지로
    moveNextIndexChange();

    //valueNotifierIndexCheckShowResult.value = valueNotifierIndexCheck.value;

    //Get.back(result: xFile);
  }

  changeIndexCheck(int index) {
    if (valueNotifierMapCheckHistoryLocal.value[widget.modelCheckList.listModelCheck[index]] == null) {
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
    //다음이 없다면?
    if (valueNotifierIndexCheck.value >= widget.modelCheckList.listModelCheck.length - 1) {
      return;
    } else {
      //다음이 있다면
      //사진 촬영 안한 인덱스로 이동
      for (int i = valueNotifierIndexCheck.value + 1; i < widget.modelCheckList.listModelCheck.length; i++) {
        if (valueNotifierMapCheckHistoryLocal.value[widget.modelCheckList.listModelCheck[i]] == null) {
          changeIndexCheck(i);
          break;
        }
      }
    }
  }
}
