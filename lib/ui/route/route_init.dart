import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:today_safety/const/value/router.dart';
import 'package:today_safety/service/util/util_snackbar.dart';
import 'package:uni_links/uni_links.dart';

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

    initDeepLink();
    initLogin();
    initKaKaoSdk();
    initFcm();

    await Future.delayed(const Duration(seconds: 1));
    Get.offAllNamed(keyRouteMain);
  }

  initDeepLink() async {
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        showSnackBarOnRoute("딥링크 : $initialLink");
        MyApp.logger.d("딥링크 : $initialLink");
      }
    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      // return?
    }
  }

  initLogin() {
    MyApp.providerUser.loginAuto();
  }

  initKaKaoSdk() {
    KakaoSdk.init(nativeAppKey: 'f77b6bf70c14c1698265fd3a1d965768');
    AuthRepository.initialize(appKey: '440a470432ea1e6ff3a460609d715301');
  }

  initFcm() async {
    MyApp.completerInitFcm = Completer();

    try {
      FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

      NotificationSettings notificationSettings = await firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      switch (notificationSettings.authorizationStatus) {
        case AuthorizationStatus.authorized:
          MyApp.logger.d("FCM 권한 승인됨");
          break;
        case AuthorizationStatus.denied:
          MyApp.logger.d("FCM 권한 거부됨");
          throw Exception("FCM 권한 거부됨");
        case AuthorizationStatus.notDetermined:
          MyApp.logger.d("FCM 권한 아직 결정 안 함");
          throw Exception("FCM 권한 아직 결정 안 함");
        case AuthorizationStatus.provisional:
          MyApp.logger.d("FCM 권한 provisional");
          throw Exception("FCM 권한 provisional");
      }

      String? token = await firebaseMessaging.getToken();
      if (token == null) {
        throw Exception("token==null");
      }

      MyApp.logger.d("FCM 토큰 : $token");
      MyApp.tokenFcm = token;

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        MyApp.logger.d('포그라운드 FCM data: ${message.data}');

        if (message.notification != null) {
          MyApp.logger.d('Message also contained a notification: ${message.notification}');
        }
      });

      MyApp.completerInitFcm.complete();
    } on Exception catch (e) {
      MyApp.logger.wtf("FCM 초기화 실패 : ${e.toString()}");
      MyApp.completerInitFcm.completeError(e);
    }
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
