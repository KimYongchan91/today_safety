import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../const/model/model_check_list.dart';
import '../../item/item_check.dart';

class RouteTestCheckSequence extends StatefulWidget {
  final ModelCheckList? modelCheckList;

  const RouteTestCheckSequence({this.modelCheckList, Key? key}) : super(key: key);

  @override
  State<RouteTestCheckSequence> createState() => _RouteTestCheckSequenceState();
}

class _RouteTestCheckSequenceState extends State<RouteTestCheckSequence> {
  ValueNotifier<int> valueNotifierIndexCheck = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ///카메라 뷰(전체화면)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(color: Color(0x333333)),
            ),
          ),

          ///인증 방법 설명 부분
          Positioned(
            top: Get.mediaQuery.viewPadding.top,
            left: 0,
            right: 0,
            child: Visibility(
                visible: widget.modelCheckList != null,
                child: ValueListenableBuilder(
                  valueListenable: valueNotifierIndexCheck,
                  builder: (context, value, child) => ExpandablePanel(
                    ///설명의 헤더 (항상 보이는)
                    header: Text(widget.modelCheckList!.listModelCheck[value].name),

                    ///설명의 바디 (축소되었을 때)
                    collapsed: Container(),

                    ///설명의 바디 (확장되었을 때)
                    expanded: ItemCheck(widget.modelCheckList!.listModelCheck[value]),
                    theme: const ExpandableThemeData(
                      hasIcon: true,
                      iconSize: 36,
                    ),
                  ),
                )),
          ),

          ///촬영 버튼
          Positioned(
            bottom: 10,
            child: ElevatedButton(
              onPressed: () async {},
              child: const Text('적용'),
            ),
          )
        ],
      ),
    );
  }
}
