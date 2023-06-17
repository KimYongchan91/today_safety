import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:today_safety/const/model/model_check.dart';

import 'model_location.dart';

///카메라로 찍어 인증을 만든 순간 생성됨
class ModelCheckImageLocal {
  final ModelCheck modelCheck;
  final Timestamp date;
  final XFile xFile;
  final CameraLensDirection cameraLensDirection;

  ModelCheckImageLocal({
    required this.modelCheck,
    required this.date,
    required this.xFile,
    required this.cameraLensDirection,
  });
}
