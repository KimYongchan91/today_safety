import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:today_safety/const/value/router.dart';

import '../../const/value/key.dart';


class RouteMain extends StatelessWidget {
  const RouteMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('메인 페이지입니다.'),
            ElevatedButton(
              onPressed: () {
                Get.toNamed(keyRouteVerify, arguments: {keyUrl: 'test'});
              },
              child: Text('인증 페이지로'),
            ),

            ElevatedButton(
              onPressed: () {
                Get.toNamed(keyRouteLogin);
              },
              child: Text('로그인 페이지로'),
            ),
          ],
        ),
      ),
    );
  }
}
