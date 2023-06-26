import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:today_safety/const/model/model_check.dart';
import 'package:today_safety/const/value/fuc.dart';
import 'package:today_safety/const/value/fuc_preset.dart';
import 'package:today_safety/custom/custom_text_style.dart';

enum ItemCheckType { add, delete,none }

class ItemCheck extends StatelessWidget {
  final ModelCheck modelCheck;
  final ItemCheckType itemCheckType;

  final void Function()? onTap;

  const ItemCheck({required this.modelCheck, required this.itemCheckType, this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(vertical: 2),
        height: Get.height / 12,
        child: Row(
          children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xffbbd6fd)),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset(getPathCheckImage(modelCheck)),
                )),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  modelCheck.name,
                  style: const TextStyle(color: Colors.black54, fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            Visibility(
              visible: onTap != null,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    itemCheckType == ItemCheckType.add ? Icons.add : Icons.close,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
