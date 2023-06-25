import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:today_safety/const/value/router.dart';
import 'package:today_safety/service/util/util_snackbar.dart';

import '../../const/value/fcm.dart';
import '../../my_app.dart';

///fcm를 클릭해서 앱이 실행됐을 때
@pragma('vm:entry-point')
void handlerOnMessageOpenedApp(RemoteMessage message) async {
  MyApp.logger.d("handlerOnMessageOpenedApp");
  await Future.delayed(const Duration(microseconds: 500));
  //showSnackBarOnRoute(message.data.toString());
  handlerRemoteMessage(message.data);

  //루트 노티로 이동
}

///앱이 포그라운드일 때 메세지 수신
Future<void> handlerFirebaseMessagingForeground(RemoteMessage message) async {
  MyApp.logger.d("handlerFirebaseMessagingForeground");
  _showLocalNotification(message);
}

///앱이 백그라운드일 때 메세지 수신
@pragma('vm:entry-point')
Future<void> handlerFirebaseMessagingBackground(RemoteMessage message) async {
  MyApp.logger.d("Handling a background message: ${message.messageId}");

  List<Future> listFuture = [
    Firebase.initializeApp(),
    FlutterLocalNotificationsPlugin().initialize(initializationSettings),
  ];

  await Future.wait(listFuture);

  _showLocalNotification(message);
}

@pragma('vm:entry-point')
_showLocalNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  MyApp.logger.d("""
handlerFirebaseMessagingForeground
notification : ${notification.toString()}
android : ${android.toString()}
message.data : ${message.data}
""");

  if (notification != null && android != null) {
    FlutterLocalNotificationsPlugin().show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelNoticeNew.id,
          channelNoticeNew.name,
          channelDescription: channelNoticeNew.description,
          icon: android.smallIcon,
          // other properties...
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }
}

///앱이 포그라운드일 때 들어온 노티를 클릭했을 때
void handlerOnDidReceiveNotificationResponse(NotificationResponse notificationResponse) {
  MyApp.logger.d("onDidReceiveNotificationResponse, details: ${notificationResponse.toString()}");
  handlerRemoteMessage(notificationResponse.payload);
}

///앱이 백그라운드일 때 들어온 노티를 클릭했을 때 ?
@pragma('vm:entry-point')
void handlerOnDidReceiveBackgroundNotificationResponse(NotificationResponse? notificationResponse) {
  MyApp.logger.d("onDidReceiveBackgroundNotificationResponse");
  handlerRemoteMessage(notificationResponse?.payload);
}

void handlerRemoteMessage(dynamic data) {
  try {
    if (data == null) {
      throw Exception("data == null");
    }

    Map<String, dynamic> dataParsed;

    if (data is String) {
      dataParsed = jsonDecode(data);
    } else if (data is Map) {
      dataParsed = data as Map<String, dynamic>;
    } else {
      throw Exception('type error');
    }

    /*
  json >>>
    "data": {
      'fcm_type': FCM_TYPE_NOTICE_NEW,
      "notice_id": notice_id,
      "notice_title" : title,
      "notice_body" : body,
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
  },
 */

    String? noticeId = dataParsed['notice_id'];
    if (noticeId == null) {
      throw Exception();
    } else {
      Get.toNamed('$keyRouteNoticeDetail/$noticeId');
    }
  } catch (e) {
    MyApp.logger.d("_handlerRemoteMessage 에러 : ${e.toString()}");
    return;
  }
}
