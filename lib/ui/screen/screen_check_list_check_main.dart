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
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                InkWell(
                    onTap: (){
                      Get.back();
                    },
                    child: FaIcon(FontAwesomeIcons.angleLeft,color: Colors.black,)),




                Expanded(
                  child: Center(
                    child: Text(
                      '${widget.modelCheckList.name} 체크리스트 요약 페이지',
                      style: const CustomTextStyle.bigBlackBold(),
                    ),
                  ),
                ),

              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          ListView.builder(
            itemCount: widget.modelCheckList.listModelCheck.length,
            itemBuilder: (context, index) => ItemCheck(
              widget.modelCheckList.listModelCheck[index],
            ),
            shrinkWrap: true,
          )
        ],
      ),
    );
  }
}
