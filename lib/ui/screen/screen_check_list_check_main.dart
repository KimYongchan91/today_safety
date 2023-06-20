import 'package:flutter/material.dart';
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
          const SizedBox(
            height: 20,
          ),
          Text(
            '${widget.modelCheckList.modelSite.name}',
            style: const CustomTextStyle.bigBlackBold(),
          ),

          ///체크 리스트 관련
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Text(
                '${widget.modelCheckList.name} 체크리스트',
                style: const CustomTextStyle.bigBlackBold(),
              ),
            ],
          ),

          const SizedBox(
            height: 20,
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
