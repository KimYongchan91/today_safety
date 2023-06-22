import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:today_safety/const/model/model_article.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/ui/route/route_webview.dart';

import '../dialog/dialog_open_external_web_browser.dart';

class ItemArticle extends StatelessWidget {
  final ModelArticle modelArticle;

  const ItemArticle(this.modelArticle, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: Get.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ///날짜
                Text(DateFormat('MM-dd').format(modelArticle.dateTime)),
                SizedBox(
                  width: 10,
                ),

                ///지역
                Text(modelArticle.region),
              ],
            ),
            Row(
              children: [
                ///제목
                Expanded(
                  child: Text(
                    modelArticle.title,
                    style: CustomTextStyle.normalBlackBold(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  onTap() {
    print(modelArticle.href);
    //https://www.kosha.or.kr/kosha/report/kosha_news.do?mode=view&articleNo=442620
    //Get.dialog(DialogOpenExternalWebBrowser(modelArticle.href));
    Get.to(() => RouteWebView(modelArticle.href));
  }
}
