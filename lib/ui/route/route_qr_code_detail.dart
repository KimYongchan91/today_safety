import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:today_safety/const/model/model_check_list.dart';

import '../../const/value/router.dart';

class RouteQrCodeDetail extends StatefulWidget {
  final ModelCheckList modelCheckList;

  const RouteQrCodeDetail(this.modelCheckList, {Key? key}) : super(key: key);

  @override
  State<RouteQrCodeDetail> createState() => _RouteQrCodeDetailState();
}

class _RouteQrCodeDetailState extends State<RouteQrCodeDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: Get.width * 0.8,
            height: Get.width * 0.8,
            child: SfBarcodeGenerator(
              value:
                  '$urlBaseAppLink$keyRouteCheckListDetail/${widget.modelCheckList.docId}/$keyRouteCheckListCheckWithOutSlash',
              symbology: QRCode(),
              showValue: false,
            ),
          ),
        ),
      ),
    );
  }
}
