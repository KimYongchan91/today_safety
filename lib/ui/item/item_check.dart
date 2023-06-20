import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:today_safety/const/model/model_check.dart';
import 'package:today_safety/const/value/fuc.dart';
import 'package:today_safety/const/value/fuc_preset.dart';
import 'package:today_safety/custom/custom_text_style.dart';

class ItemCheck extends StatelessWidget {
  final ModelCheck modelCheck;
  final void Function()? onDelete;

  const ItemCheck(this.modelCheck, {this.onDelete, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      height: Get.height/10,

      child: Card(
        elevation: 2,
        child: Stack(
          children: [
            Positioned.fill(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.asset(getPathCheckImage(modelCheck)),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        modelCheck.name,
                        style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.w700),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: Visibility(
                visible: onDelete != null,
                child: InkWell(
                  onTap: onDelete,
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.close),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
