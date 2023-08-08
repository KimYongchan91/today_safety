import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:today_safety/const/value/value.dart';
import 'package:today_safety/service/provider/provider_user.dart';
import 'package:today_safety/ui/item/item_user_check_history_big.dart';
import 'package:today_safety/ui/item/item_user_check_history_big_empty.dart';
import 'package:today_safety/ui/widget/widget_app_bar.dart';

import '../../const/model/model_user_check_history.dart';
import '../../const/value/layout_main.dart';
import '../../service/provider/provider_user_check_history_on_me.dart';

class ScreenMainCheck extends StatefulWidget {
  const ScreenMainCheck({Key? key}) : super(key: key);

  @override
  State<ScreenMainCheck> createState() => _ScreenMainCheckState();
}

class _ScreenMainCheckState extends State<ScreenMainCheck> {
  final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProviderUser, ProviderUserCheckHistoryOnMe>(
      builder: (context, providerUser, providerUserCheckHistoryOnMe, child) {
        List<ModelUserCheckHistory> listModelUserCheckHistoryRecent = [
          ...providerUserCheckHistoryOnMe.listModelUserCheckHistory
              .where((element) =>
                  (DateTime.now().millisecondsSinceEpoch - element.date.millisecondsSinceEpoch) <
                  millisecondDay)
              .toList()
        ];

        return Column(
          children: [
            ///앱 로고
            const WidgetAppBar(),

            ///인증서 목록
            //3가지 상황이 있음.
            //1. 로그인 안함
            //2. 로그인 했는데 인증서가 없음
            //3. 로그인 했고 인증서가 있음.
            Expanded(
              child: Builder(builder: (context) {
                int itemCount;
                Widget? Function(BuildContext, int) itemBuilder;

                if (providerUser.modelUser == null) {
                  itemCount = 1;
                  itemBuilder = (context, index) => ItemUserCheckHistoryBigEmpty(
                        ItemUserCheckHistoryBigEmptyType.notLogin,
                        onTap: () {},
                        padding: paddingMainItemUserCheckHistoryBig, //20
                      );
                } else {
                  itemCount = max(listModelUserCheckHistoryRecent.length, 1);
                  if (listModelUserCheckHistoryRecent.isNotEmpty) {
                    itemBuilder = (context, index) => ItemUserCheckHistoryBig(
                          listModelUserCheckHistoryRecent[index],
                          padding: paddingMainItemUserCheckHistoryBig, //20
                          key: ValueKey(listModelUserCheckHistoryRecent[index]),
                        );
                  } else {
                    itemBuilder = (context, index) => ItemUserCheckHistoryBigEmpty(
                          ItemUserCheckHistoryBigEmptyType.empty,
                          onTap: () {},
                          padding: paddingMainItemUserCheckHistoryBig, //20
                        );
                  }
                }

                return PageView.builder(
                  itemCount: itemCount,
                  itemBuilder: itemBuilder,
                  /*onPageChanged: (value) {
                          pageController.jumpToPage(value);
                        },*/
                  controller: pageController,
                );
              }),
            ),

            ///인증서 페이지 인디케이터
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: listModelUserCheckHistoryRecent.isNotEmpty
                  ? SmoothPageIndicator(
                      controller: pageController,
                      count: listModelUserCheckHistoryRecent.length,
                      effect: const ExpandingDotsEffect(
                        dotWidth: 8,
                        dotHeight: 8,
                        dotColor: Colors.grey,
                        activeDotColor: Colors.black,
                      ),
                    )
                  //보이지 않음
                  : SmoothPageIndicator(
                      controller: PageController(),
                      count: 1,
                      effect: const ExpandingDotsEffect(
                        dotWidth: 8,
                        dotHeight: 8,
                        dotColor: Colors.transparent,
                        activeDotColor: Colors.transparent,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
