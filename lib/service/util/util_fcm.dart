import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../const/value/fcm.dart';
import '../../my_app.dart';

///fcm를 클릭해서 앱이 실행됐을 때
void handlerOnMessageOpenedApp(RemoteMessage message)async{
  print("handlerOnMessageOpenedApp");

}

///앱이 포그라운드일 때 실행
Future<void> handlerFirebaseMessagingForeground(RemoteMessage message) async {
  print("handlerFirebaseMessagingForeground");

  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  MyApp.logger.d("""
handlerFirebaseMessagingForeground
notification : ${notification.toString()}
android : ${android.toString()}
message.data : ${message.data}
""");

  // If `onMessage` is triggered with a notification, construct our own
  // local notification to show to users using the created channel.
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
        ));
  }
}

///앱이 백그라운드일 때 실행됨
Future<void> handlerFirebaseMessagingBackground(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

///앱이 포그라운드일 때 들어온 노티를 클릭했을 때
void handlerOnDidReceiveNotificationResponse(NotificationResponse notificationResponse) {
  print("onDidReceiveNotificationResponse, details: ${notificationResponse.toString()}");
}



///앱이 백그라운드일 때 들어온 노티를 클릭했을 때 ?
void handlerOnDidReceiveBackgroundNotificationResponse(NotificationResponse? notificationResponse) {
  print("onDidReceiveBackgroundNotificationResponse");
}
