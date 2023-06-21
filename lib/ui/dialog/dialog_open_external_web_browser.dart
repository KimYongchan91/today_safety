import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../custom/custom_text_style.dart';

class DialogOpenExternalWebBrowser extends StatefulWidget {
  final String url;

  const DialogOpenExternalWebBrowser(this.url, {Key? key}) : super(key: key);

  @override
  State<DialogOpenExternalWebBrowser> createState() => _DialogOpenExternalWebBrowserState();
}

class _DialogOpenExternalWebBrowserState extends State<DialogOpenExternalWebBrowser> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xffffffff),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      contentPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.zero,
      content: Container(
        width: Get.width * 0.8,
        constraints: BoxConstraints(
          maxHeight: Get.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ///타이틀
            SizedBox(
              width: Get.width,
              height: 48,
              child: Stack(
                children: [
                  const Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        '날씨',
                        style: CustomTextStyle.bigBlackBold(),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        Get.back(result: false);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.close,
                          size: 32,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text('외부 인터넷 브라우저로 연결돼요.', textAlign: TextAlign.center, style: CustomTextStyle.normalBlack()),
            const SizedBox(
              height: 32,
            ),
            InkWell(
              onTap: () async {
                Get.back(result: true);

                String urlEncoded = Uri.encodeFull(widget.url);
                print("urlEncoded : ${urlEncoded}");
                final Uri uri = Uri.parse(urlEncoded);
                if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                  throw Exception('Could not launch $uri');
                }
              },
              child: Container(
                width: 147,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xfff84343),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      '확인',
                      style: CustomTextStyle.normalWhiteBold(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}
