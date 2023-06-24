import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const AndroidNotificationChannel channelNoticeNew = AndroidNotificationChannel(
  'NEW_NOTICE', // id
  '새 공지사항 알림', // title
  description: '근무지에서 게시한 새 공지사항을 알려줘요.', // description
  importance: Importance.max,
);
