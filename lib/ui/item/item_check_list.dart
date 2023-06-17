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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        width: Get.width,
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 90,
              height: 90,
              child: SfBarcodeGenerator(
                value: '$urlAppLink/${modelCheckList.docId}',
                symbology: QRCode(),
                showValue: false,
              ),
            ),
            const SizedBox(
              width: 30,
            ),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      modelCheckList.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ))),
          ],
        ),
      ),
    );
  }
}
