import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:today_safety/custom/custom_text_style.dart';

import '../../const/model/model_check_image_local.dart';
import '../widget/icon_error.dart';

///사진 촬영 결과
class ItemCheckImageLocal extends StatelessWidget {
  final ModelCheckImageLocal? modelCheckHistoryLocal;

  const ItemCheckImageLocal(this.modelCheckHistoryLocal, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (modelCheckHistoryLocal == null) {
      return const IconError();
    }

    return Stack(
      children: [
        ///이미지 뷰
        Positioned.fill(
          child: Image.file(
            File(modelCheckHistoryLocal!.xFile.path ?? ''),
            width: Get.width,
            height: Get.height,
            fit: BoxFit.cover,
          ),
        ),

        ///촬영 정보 보여주는 부분
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: Get.height / 6 - 30,
            ),
            child: Text(
              '${modelCheckHistoryLocal!.modelCheck.name}  '
              '${DateFormat('yyyy-MM-dd HH:mm:ss').format(modelCheckHistoryLocal!.date.toDate())}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
