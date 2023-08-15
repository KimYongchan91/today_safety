import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:today_safety/service/provider/provider_user.dart';
import 'package:today_safety/service/provider/provider_user_check_history_on_me.dart';

class MyApp {
  static Logger logger = Logger();

  static ProviderUser providerUser = ProviderUser();
  static const Algolia algolia = Algolia.init(
    applicationId: 'MTRJRT9R1H',
    apiKey: 'dac0a057b6d123949b76313b80fa6d48',
  );

  //fcm  관련
  static late Completer completerInitFcm;
  static String? tokenFcm;

  //내 인증서
  static ProviderUserCheckHistoryOnMe providerUserCheckHistoryOnMe = ProviderUserCheckHistoryOnMe();

  //내 인증서를 관리자가 승인해줬는지 여부
  static Map<String, ValueNotifier<bool?>> mapValueNotifierIsCheckGrant = {};

}
