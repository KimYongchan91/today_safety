import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:today_safety/ui/route/route_check_list_check_camera.dart';

import '../../const/value/admin.dart';
import '../../my_app.dart';
import '../route/test/route_test.dart';

class WidgetAppBar extends StatelessWidget {
  final Color colorBackground;
  final double paddingHorizontal;

  const WidgetAppBar({this.colorBackground = Colors.white, this.paddingHorizontal = 10, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
      width: MediaQuery.of(context).size.width,
      height: 65,
      color: colorBackground,
      child: Row(
        children: [
          ///아이콘
          InkWell(
            onTap: () {
              if (MyApp.providerUser.modelUser != null && listAdmin.contains(MyApp.providerUser.modelUser!.id)) {
                Get.to(() => const RouteTest());
              }
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
                child: Image.asset(
                  'assets/images/logo/app_logo_big_128.png',
                  width: 40,
                  height: 40,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          const Text(
            '오늘안전',
            style: TextStyle(fontFamily: "SANGJU", fontSize: 23),
          ),


        ],
      ),
    );
  }
}
