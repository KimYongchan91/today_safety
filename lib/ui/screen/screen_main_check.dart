import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:today_safety/ui/item/item_user_check_history_big.dart';

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
    return Consumer<ProviderUserCheckHistoryOnMe>(
      builder: (context, value, child) => value.modelUser != null

          ///로그인 함
          ? Stack(
              children: [
                ///인증서 목록
                Positioned.fill(
                  child: PageView.builder(
                    itemCount: value.listModelUserCheckHistory.length,
                    itemBuilder: (context, index) => ItemUserCheckHistoryBig(
                      value.listModelUserCheckHistory[index],
                      padding: paddingMainItemUserCheckHistoryBig, //20
                      key: ValueKey(value.listModelUserCheckHistory[index]),
                    ),
                    /*onPageChanged: (value) {
                      pageController.jumpToPage(value);
                    },*/
                    controller: pageController,
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: SmoothPageIndicator(
                      controller: pageController,
                      count: value.listModelUserCheckHistory.length,
                      effect: ExpandingDotsEffect(
                        dotWidth: 8,
                        dotHeight: 8,
                        dotColor: Colors.grey,
                        activeDotColor: Colors.black,
                      ),
                    ),
                  ),
                )
              ],
            )

          ///로그인 하기 전
          : Center(
              child: Text('로그인을 해주세요.'),
            ),
    );
  }
}
