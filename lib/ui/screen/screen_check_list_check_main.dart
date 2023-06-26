import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:today_safety/const/model/model_check_list.dart';

import '../../custom/custom_text_style.dart';
import '../item/item_check.dart';

///인증 페이지의 첫 페이지
///예로 어떤 어떤 항목을 인증해야하는지 요약해서 보여주는 페이지
class ScreenCheckListCheckMain extends StatefulWidget {
  final ModelCheckList modelCheckList;

  const ScreenCheckListCheckMain(this.modelCheckList, {Key? key}) : super(key: key);

  @override
  State<ScreenCheckListCheckMain> createState() => _ScreenCheckListCheckMainState();
}

class _ScreenCheckListCheckMainState extends State<ScreenCheckListCheckMain> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ///근무지 관련

          ///앱바
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: Colors.white,
            width: Get.width,
            height: 60,
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: const FaIcon(
                        FontAwesomeIcons.angleLeft,
                        color: Colors.black,
                      )),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    '${widget.modelCheckList.modelSite.name}',
                    style: const CustomTextStyle.bigBlackBold(),
                  ),
                ),
              ],
            ),
          ),

          /*
          Text(
            '위치 제한 ${widget.modelCheckList.modelConstraintLocation?.range}m',
            style: const CustomTextStyle.bigBlackBold(),
          ),
          Text(
            '시간 제한 ${widget.modelCheckList.modelConstraintTime?.start} ~ ${widget.modelCheckList.modelConstraintTime?.end}, ${widget.modelCheckList.modelConstraintTime?.week.toString()}',
            style: const CustomTextStyle.bigBlackBold(),
          ), */

          Container(
            width: Get.width,
            height: Get.height,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            margin: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.modelCheckList.name}',
                      style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      '안전 점검 항목',
                      style: TextStyle(color: Colors.black54, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                ListView.builder(
                  itemCount: widget.modelCheckList.listModelCheck.length,
                  itemBuilder: (context, index) => ItemCheck(
                    modelCheck: widget.modelCheckList.listModelCheck[index],
                    itemCheckType: ItemCheckType.none,
                  ),
                  shrinkWrap: true,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
