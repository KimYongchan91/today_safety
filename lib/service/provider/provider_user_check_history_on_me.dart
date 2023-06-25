import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:today_safety/const/model/model_user.dart';
import 'package:today_safety/const/model/model_user_check_history.dart';
import 'package:today_safety/const/value/key.dart';
import 'package:today_safety/const/value/router.dart';
import 'package:today_safety/const/value/value.dart';

import '../../const/model/model_daily_check_history.dart';
import '../../my_app.dart';

class ProviderUserCheckHistoryOnMe extends ChangeNotifier {
  //내 모델 유저
  ModelUser? modelUser;

  ProviderUserCheckHistoryOnMe({
    this.modelUser,
  });

  //최근 내 인증 (24시간 이내)
  List<ModelUserCheckHistory> listModelUserCheckHistory = [];

  //최근 내 인증 스트림
  StreamSubscription? streamSubscription;

  DateFormat dateFormatYyyyMMDd = DateFormat('yyyy-MM-dd');

  init() {
    if(modelUser ==null){
      MyApp.logger.wtf("modelUser ==null");
      return;
    }

    Timestamp timestampBeforeOneDay =
        Timestamp.fromMillisecondsSinceEpoch(Timestamp.now().millisecondsSinceEpoch - millisecondDay * 1);

    Query query = FirebaseFirestore.instance
        .collection(keyUserCheckHistories)
        .where('$keyUser.$keyId', isEqualTo: modelUser!.id)
        .where(keyDate, isGreaterThanOrEqualTo: timestampBeforeOneDay);

    streamSubscription = query.snapshots().listen((event) {
      for (var element in event.docChanges) {
        ModelUserCheckHistory modelUserCheckHistory =
            ModelUserCheckHistory.fromJson(element.doc.data() as Map, docId: element.doc.id);
        //MyApp.logger.d("ProviderUserCheckHistoryOnMe 데이처 추가 ${modelUserCheckHistory.toJson().toString()}");

        switch (element.type) {
          case DocumentChangeType.added:
            listModelUserCheckHistory.add(modelUserCheckHistory);
            listModelUserCheckHistory.sort(
              (a, b) => b.date.millisecondsSinceEpoch.compareTo(a.date.millisecondsSinceEpoch),
            );
            break;
          case DocumentChangeType.modified:
            listModelUserCheckHistory.removeWhere((element) => element == modelUserCheckHistory);
            listModelUserCheckHistory.add(modelUserCheckHistory);
            break;
          case DocumentChangeType.removed:
            listModelUserCheckHistory.removeWhere((element) => element == modelUserCheckHistory);
            break;
        }
        notifyListeners();
      }
    });
  }

  void clearProvider({bool isNotify = true}) {
    listModelUserCheckHistory.clear();
    if (isNotify) notifyListeners();
  }
}
