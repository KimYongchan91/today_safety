import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../route/test/route_test.dart';

class WidgetAppBar extends StatelessWidget {
  final Color colorBackground;
  const WidgetAppBar({this.colorBackground = Colors.white, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: MediaQuery.of(context).size.width,
      height: 65,
      color: colorBackground,
      child: Row(
        children: [
          ///아이콘
          InkWell(
            onTap: () {
              Get.to(() => const RouteTest());
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                alignment: Alignment.center,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.yellow.shade700,
                  borderRadius: BorderRadius.circular(5),
                ),
                child:Image.asset('assets/images/logo/app_logo_720.png',width: 40,height: 40,),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          const Text(
            '오늘안전',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
