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
    return Card(
      elevation: 5,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              width: 50,
              alignment: Alignment.center,

                child: Image.asset(getPathFucPresetImage(modelFucPreset))),
            Spacer(),
            Text(
              modelFucPreset.name,
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500,fontSize: 16),
            )
          ],
        ),
      ),
    );
  }
}
