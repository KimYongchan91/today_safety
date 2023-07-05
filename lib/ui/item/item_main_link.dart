import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:today_safety/ui/screen/screen_web_view.dart';

class ItemMainLink extends StatefulWidget {
  const ItemMainLink({Key? key}) : super(key: key);

  @override
  State<ItemMainLink> createState() => _ItemMainLinkState();
}

class _ItemMainLinkState extends State<ItemMainLink> {
  final List<String> name = ['고용노동부', '산업안전보건공단', '근로복지공단', '한국산업인력공단'];

  final List<String> logoName = ['korea.png', 'kosha.gif', 'comwel.jpg', 'hrdk.jpeg'];
  final List<String> url = [
    'https://www.moel.go.kr/index.do',
    'https://www.kosha.or.kr/kosha/index.do',
    'https://www.comwel.or.kr/comwel/main.jsp',
    'https://www.hrdkorea.or.kr/'
  ];

  TextStyle listTxtStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 13);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: Get.width,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '관련링크',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: name.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: InkWell(
                        onTap: () {
                          Get.to(ScreenWebView(url: url[index]));
                        },
                        child: Column(
                          children: [
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: Image.asset('assets/images/logo/${logoName[index]}'),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              name[index],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            )
          ],
        ));
  }
}
