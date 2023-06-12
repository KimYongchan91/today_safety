import 'dart:io';

import 'package:flutter/material.dart';
import 'package:today_safety/const/value/fuc.dart';
import 'package:today_safety/const/value/fuc_preset.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import '../../const/model/model_fuc.dart';

class ItemFuc extends StatelessWidget {
  final ModelFuc modelFuc;

  const ItemFuc(this.modelFuc, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
          border: Border.all(
        color: Colors.grey,
      )),
      child: Row(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Image.asset(getPathFucImage(modelFuc)),
          ),
          Text(
            modelFuc.name,
            style: const CustomTextStyle.bigBlackBold(),
          )
        ],
      ),
    );
  }
}
