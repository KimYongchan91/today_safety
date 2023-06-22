import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:logger/logger.dart';
import 'package:today_safety/service/provider/provider_user.dart';

class MyApp {
  static Logger logger = Logger();

  static ProviderUser providerUser = ProviderUser();
  static const Algolia algolia = Algolia.init(
    applicationId: 'MTRJRT9R1H',
    apiKey: 'dac0a057b6d123949b76313b80fa6d48',
  );

  static late Completer completerInitFcm;
  static String? tokenFcm;
}
