import 'dart:io';

import 'package:flutter/material.dart';
import 'package:today_safety/const/model/model_fuc_preset.dart';
import 'package:today_safety/const/value/fuc_preset.dart';
import 'package:today_safety/custom/custom_text_style.dart';

class ItemFucPreset extends StatelessWidget {
  final ModelFucPreset modelFucPreset;

  const ItemFucPreset(this.modelFucPreset, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
        color: Colors.grey,
      )),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Image.asset(getPathFucPresetImage(modelFucPreset)),
          ),
          Text(
            modelFucPreset.name,
            style: const CustomTextStyle.bigBlackBold(),
          )
        ],
      ),
    );
  }
}
