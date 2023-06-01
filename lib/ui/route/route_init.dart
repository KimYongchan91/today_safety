import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:today_safety/const/value/router.dart';

import '../../firebase_options.dart';
import '../../my_app.dart';


class RouteInit extends StatefulWidget {
  const RouteInit({Key? key}) : super(key: key);

  @override
  State<RouteInit> createState() => _RouteInitState();
}

class _RouteInitState extends State<RouteInit> {
  @override
  void initState() {
    initApp();
    super.initState();
  }

  initApp() async {
    //초기화 코드

    //앱 특성상 로딩 시간 매우 짧아야 함

    //기존 로그인 정보 활용

    //딥 링크로 들어 왔다면
    //먼저 딥링크 URI를 로컬 캐쉬 히트 여부 검사
    //없으면 api에서

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    initLogin();

    await Future.delayed(const Duration(seconds: 1));
    Get.offAllNamed(keyRouteMain);
  }

  initLogin(){
    MyApp.providerUser.loginAuto();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('로딩 중'),
            SizedBox(
              height: 20,
            ),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
