import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiver/time.dart';
import 'package:today_safety/const/model/model_check.dart';
import 'package:today_safety/const/model/model_check_list.dart';
import 'package:today_safety/ui/item/item_check.dart';

import '../../my_app.dart';

class RouteCamera extends StatefulWidget {
  final ModelCheck? modelCheck;

  const RouteCamera({this.modelCheck, Key? key}) : super(key: key);

  @override
  State<RouteCamera> createState() => _RouteCameraState();
}

class _RouteCameraState extends State<RouteCamera> {
  late Completer<bool> completerInit;
  late CameraController controller;
  late List<CameraDescription> _cameras;

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
                  Positioned.fill(
                    child: CameraPreview(controller),
                  ),
                  Visibility(
                    visible: widget.modelCheck != null,
                    child: ItemCheck(widget.modelCheck!),
                  ),
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
