import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:today_safety/const/model/model_check_list.dart';

import '../../const/value/router.dart';
import '../../service/util/util_app_link.dart';

class ItemCheckList extends StatelessWidget {
  final ModelCheckList modelCheckList;

  const ItemCheckList(this.modelCheckList, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('https://kayple.com/today_safety/check_list/${modelCheckList.docId}');
    return InkWell(
      onTap: () {
        // test
        //Get.toNamed('$keyRouteCheckListDetail/${modelCheckList.docId}');
        Get.toNamed('$keyRouteCheckListDetail/${modelCheckList.docId}', arguments: {keyModelCheckList: modelCheckList});
      },
      child: Container(
        width: Get.width,
        height: 150,
        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: SfBarcodeGenerator(
                value: '$urlAppLink/${modelCheckList.docId}',
                symbology: QRCode(),
                showValue: false,
              ),
            ),
            Text(modelCheckList.name),
          ],
        ),
      ),
    );
  }
}
