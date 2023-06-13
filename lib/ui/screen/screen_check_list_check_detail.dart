import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:today_safety/const/model/model_check.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/ui/item/item_check.dart';
import 'package:today_safety/ui/route/route_camera.dart';

import '../../service/util/util_permission.dart';

class ScreenCheckListCheckDetail extends StatefulWidget {
  final ModelCheck modelCheck;

  const ScreenCheckListCheckDetail(this.modelCheck, {Key? key}) : super(key: key);

  @override
  State<ScreenCheckListCheckDetail> createState() => _ScreenCheckListCheckDetailState();
}

class _ScreenCheckListCheckDetailState extends State<ScreenCheckListCheckDetail> {
  XFile? xFile;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ItemCheck(widget.modelCheck),
          SizedBox(
            height: 40,
          ),
          Container(
            width: Get.width * 0.6,
            height: Get.width * 0.6,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
              ),
            ),
            child: xFile == null
                ? Center(
                    child: InkWell(
                      onTap: () async {
                        bool isPermissionGranted = await requestPermission(Permission.camera);
                        if (isPermissionGranted == false) {
                          return;
                        }

                        var result = await Get.to(RouteCamera(
                          modelCheck: widget.modelCheck,
                        ));

                        if (result != null && result is XFile) {
                          setState(() {
                            xFile = result;
                          });
                        }
                      },
                      child: Icon(
                        Icons.camera,
                        size: 48,
                      ),
                    ),
                  )
                : Image.file(File(xFile!.path)),
          )
        ],
      ),
    );
  }
}
