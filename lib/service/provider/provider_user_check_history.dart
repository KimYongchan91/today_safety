import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:today_safety/const/model/model_user_check_history.dart';
import 'package:today_safety/const/value/key.dart';
import 'package:today_safety/const/value/router.dart';

class ProviderUserCheckHistory extends ChangeNotifier {
  final String checkListId;
  final int limit;
  final String? userId;
  final String? dateDisplay;
  final bool isOrderByDateDescending;

  List<ModelUserCheckHistory> listModelUserCheckHistory = [];
  StreamSubscription? streamSubscription;

  ProviderUserCheckHistory({
    required this.checkListId,
    this.limit = 3,
    this.userId,
    this.dateDisplay,
    this.isOrderByDateDescending = true,
  }) {
    init();
  }

  init() {
    Query query =
        FirebaseFirestore.instance.collection(keyUserCheckHistories).where(keyCheckListId, isEqualTo: checkListId);

    if (userId != null) {
      query = query.where('$keyUser.$keyId', isEqualTo: userId);
    }

    if (dateDisplay != null) {
      query = query.where(keyDateDisplay, isEqualTo: dateDisplay);
    }

    query = query.orderBy(keyDate, descending: true);
    query = query.limit(limit);

    ///첫 수신
    query.get().then((value) {
      for (var element in value.docs) {
        ModelUserCheckHistory modelUserCheckHistory = ModelUserCheckHistory.fromJson(element.data() as Map, element.id);
        listModelUserCheckHistory.add(modelUserCheckHistory);
      }

      notifyListeners();
    });

    ///변경점 수신
    ///변경점 수신까지는 하지 않는 걸로 함
    /*query = query.where(keyDate,isGreaterThan: )
    streamSubscription = query.snapshots().listen((event) {
      for (var element in event.docChanges) {
        ModelUserCheckHistory modelUserCheckHistory = ModelUserCheckHistory.fromJson(element.doc.data() as Map, element.doc.id);

        switch (element.type) {
          case DocumentChangeType.added:
            listModelUserCheckHistory.add(modelUserCheckHistory);
            break;
          case DocumentChangeType.modified:
            listModelUserCheckHistory.removeWhere((element) => element == modelUserCheckHistory);
            listModelUserCheckHistory.add(modelUserCheckHistory);
            break;
          case DocumentChangeType.removed:
            listModelUserCheckHistory.removeWhere((element) => element == modelUserCheckHistory);
            break;
        }

        //정렬

        //sort
      }
    });*/
  }

  void clearProvider({bool isNotify = true}) {
    listModelUserCheckHistory.clear();
    if (isNotify) notifyListeners();
  }
}
