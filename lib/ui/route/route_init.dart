import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:today_safety/const/value/router.dart';
import 'package:today_safety/service/util/util_snackbar.dart';
import 'package:uni_links/uni_links.dart';

import '../../const/value/fcm.dart';
import '../../firebase_options.dart';
import '../../my_app.dart';
import '../../service/util/util_fcm.dart';

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
    //FirebaseMessaging.onBackgroundMessage(handlerFirebaseMessagingBackground);

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

      //앱이 종료되었 때 노티를 클릭하고 들어왔을 때
      RemoteMessage? remoteMessageInitial = await FirebaseMessaging.instance.getInitialMessage();
      if (remoteMessageInitial != null) {
        MyApp.logger.d('remoteMessage 존재함! ');
        await Future.delayed(const Duration(microseconds: 500));
        handlerRemoteMessage(remoteMessageInitial.data);
      }

      FirebaseMessaging.onMessage.listen(handlerFirebaseMessagingForeground);
      FirebaseMessaging.onMessageOpenedApp.listen(handlerOnMessageOpenedApp);


      MyApp.completerInitFcm.complete();
    } on Exception catch (e) {
      MyApp.logger.wtf("FCM 초기화 실패 : ${e.toString()}");
      MyApp.completerInitFcm.completeError(e);
    }

    //로컬 노티 플러그인
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


    //로컬 노티 초기화
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: handlerOnDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: handlerOnDidReceiveBackgroundNotificationResponse,
    );

    //안드로이드 채널 추가
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channelNoticeNew);

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channelCheckNew);

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channelCheckResult);

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channelWeather);
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('로딩 중'),
            const SizedBox(
              height: 20,
            ),
            LoadingAnimationWidget.inkDrop(color: Colors.green, size: 32),
          ],
        ),
      ),
    );
  }
}
