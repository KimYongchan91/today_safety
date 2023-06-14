import 'dart:async';

import 'package:camera/camera.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiver/time.dart';
import 'package:today_safety/const/model/model_check.dart';
import 'package:today_safety/const/model/model_check_list.dart';
import 'package:today_safety/ui/item/item_check.dart';

import '../../my_app.dart';

class RouteCamera extends StatefulWidget {
  final ModelCheckList? modelCheckList;

  const RouteCamera({this.modelCheckList, Key? key}) : super(key: key);

  @override
  State<RouteCamera> createState() => _RouteCameraState();
}

class _RouteCameraState extends State<RouteCamera> {
  late Completer<bool> completerInit;
  late CameraController controller;
  late List<CameraDescription> _cameras;

  ValueNotifier<int> valueNotifierIndexCheck = ValueNotifier(0);

  @override
  void initState() {
    super.initState();

    initCamera();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  initCamera() async {
    completerInit = Completer();
    try {
      _cameras = await availableCameras();
    } on Exception catch (e) {
      MyApp.logger.wtf('카메라 정보 불러오는 데 실패 : ${e.toString()}');
      completerInit.complete(false);
      return;
    }
    CameraDescription? cameraDescriptionFront;

    for (var element in _cameras) {
      if (element.lensDirection == CameraLensDirection.back) {
        cameraDescriptionFront = element;
      }
    }

    if (cameraDescriptionFront == null) {
      MyApp.logger.wtf('후면 카메라 없음');
      completerInit.complete(false);
      return;
    }

    controller = CameraController(cameraDescriptionFront, ResolutionPreset.medium);

    try {
      await controller.initialize();
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
                    child: CameraPreview(controller),
                  ),

                  ///인증 방법 설명 부분
                  Positioned(
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
                  ),

                  ///촬영 버튼
                  Positioned(
                    bottom: 10,
                    child: ElevatedButton(
                      onPressed: () async {
                        XFile xFile = await controller.takePicture();
                        MyApp.logger.d('촬영된 사진 주소 : ${xFile.path}');
                        Get.back(result: xFile);
                      },
                      child: const Text('적용'),
                    ),
                  )
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
