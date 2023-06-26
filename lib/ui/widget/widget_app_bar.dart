import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../route/test/route_test.dart';

class WidgetAppBar extends StatelessWidget {
  const WidgetAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: MediaQuery.of(context).size.width,
      height: 65,
      color: Colors.white,
      child: Row(
        children: [
          ///아이콘
          InkWell(
            onTap: () {
              Get.to(() => const RouteTest());
            },
            child: Container(
              alignment: Alignment.center,
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.yellow.shade700,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const FaIcon(
                FontAwesomeIcons.helmetSafety,
                color: Colors.white,
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
