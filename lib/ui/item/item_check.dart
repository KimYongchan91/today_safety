import 'dart:io';

import 'package:flutter/material.dart';
import 'package:today_safety/const/model/model_check.dart';
import 'package:today_safety/const/value/fuc.dart';
import 'package:today_safety/const/value/fuc_preset.dart';
import 'package:today_safety/custom/custom_text_style.dart';

class ItemCheck extends StatelessWidget {
  final ModelCheck modelCheck;
  final void Function() onDelete;

  const ItemCheck(this.modelCheck, this.onDelete, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
          border: Border.all(
        color: Colors.grey,
      )),
      child: Stack(
        children: [
          Positioned.fill(
            child: Row(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset(getPathCheckImage(modelCheck)),
                ),
                Text(
                  modelCheck.name,
                  style: const CustomTextStyle.bigBlackBold(),
                )
              ],
            ),
          ),
          Positioned(
              top: 5,
              right: 5,
              child: InkWell(
                onTap: onDelete,
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.close),
                ),
              ))
        ],
      ),
    );
  }
}
