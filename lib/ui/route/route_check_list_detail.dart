import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:today_safety/const/model/model_check_list.dart';
import 'package:today_safety/const/value/key.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/ui/item/item_check.dart';

import '../../const/value/router.dart';
import '../../my_app.dart';
import '../../service/util/util_app_link.dart';
import '../../service/util/util_check_list.dart';

class RouteCheckListDetail extends StatefulWidget {
  const RouteCheckListDetail({Key? key}) : super(key: key);

  @override
  State<RouteCheckListDetail> createState() => _RouteCheckListDetailState();
}

class _RouteCheckListDetailState extends State<RouteCheckListDetail> {
  late Completer<ModelCheckList?> completerModelCheckList;

  @override
  void initState() {
    MyApp.logger.d("keyCheckListId : ${Get.parameters[keyCheckListId]}");

    completerModelCheckList = Completer();

    if (Get.parameters[keyCheckListId] == null) {
      completerModelCheckList.complete(null);
      return;
    }

    if (Get.arguments?[keyModelCheckList] != null) {
      completerModelCheckList.complete(Get.arguments[keyModelCheckList]);
    } else {
      getModelCheckListFromServerByDocId(Get.parameters[keyCheckListId]!).then((value) {
        completerModelCheckList.complete(value);
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<ModelCheckList?>(
          future: completerModelCheckList.future,
          builder: (context, snapshot) {
            if (snapshot.hasData == false) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.data != null) {
              return Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text(
                        snapshot.data!.name,
                        style: CustomTextStyle.bigBlackBold(),
                      ),
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: SfBarcodeGenerator(
                          value: '$urlAppLink/${snapshot.data!.docId}',
                          symbology: QRCode(),
                          showValue: false,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ListView.builder(
                    itemCount: snapshot.data!.listModelCheck.length,
                    itemBuilder: (context, index) => ItemCheck(
                      snapshot.data!.listModelCheck[index],
                    ),
                    shrinkWrap: true,
                  )
                ],
              );
            } else {
              return const Center(
                child: Icon(
                  Icons.error,
                  color: Colors.red,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
