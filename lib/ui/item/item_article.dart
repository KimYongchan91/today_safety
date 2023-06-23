import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Container(
          decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(20)),

          width: Get.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [


              Row(
                children: [
                  ///제목
                  Expanded(
                    child: Center(
                      child: Text(
                        modelArticle.title,
                        style: const CustomTextStyle.normalBlackBold(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),


                ],
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ///날짜
                  Text(DateFormat('MM-dd').format(modelArticle.dateTime),style: const TextStyle(fontWeight: FontWeight.w600),),
                  const SizedBox(
                    width: 5,
                  ),

                  ///지역
                  Text(modelArticle.region,style: const TextStyle(fontWeight: FontWeight.w600),),
                ],
              ),
            ],
          ),
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
