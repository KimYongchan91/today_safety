import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const AndroidNotificationChannel channelNoticeNew = AndroidNotificationChannel(
  'NEW_NOTICE', // id
  '새 공지사항', // title
  description: '근무지에서 게시한 새 공지사항을 알려줘요.', // description
  importance: Importance.max,
);

const AndroidNotificationChannel channelCheckNew = AndroidNotificationChannel(
  'NEW_CHECK', // id
  '새 인증 확인 요청', // title
  description: '팀원이 제출한 새 인증 확인 요청을 알려줘요.', // description
  importance: Importance.max,
);

const AndroidNotificationChannel channelCheckResult = AndroidNotificationChannel(
  'CHECK_RESULT', // id
  '인증 확인 결과', // title
  description: '제출한 인증에 대한 확인 결과를 알려줘요.', // description
  importance: Importance.max,
);

//로컬 노티 세팅값
const InitializationSettings initializationSettings = InitializationSettings(
  android: AndroidInitializationSettings("app_logo_transparent_big_128"),
);
