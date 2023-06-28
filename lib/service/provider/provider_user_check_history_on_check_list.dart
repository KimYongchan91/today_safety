import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:today_safety/const/model/model_user_check_history.dart';
import 'package:today_safety/const/value/key.dart';
import 'package:today_safety/const/value/router.dart';
import 'package:today_safety/const/value/value.dart';

import '../../const/model/model_daily_check_history.dart';
import '../../my_app.dart';

class ProviderUserCheckHistoryOnCheckList extends ChangeNotifier {
  final String checkListId;
  final int limit;
  final String? userId;
  final String? dateDisplay;
  final bool isOrderByDateDescending;
  final bool isIncludeDailyReport;

  //최근 인증
  List<ModelUserCheckHistory> listModelUserCheckHistory = [];

  //최근 인증 스트림
  StreamSubscription? streamSubscription;

  //일별 인증 통계
  List<ModelDailyCheckHistory> listModelDailyCheckHistory = [];

  DateFormat dateFormatYyyyMMDd = DateFormat('yyyy-MM-dd');

  ProviderUserCheckHistoryOnCheckList({
    required this.checkListId,
    this.limit = 3,
    this.userId,
    this.dateDisplay,
    this.isOrderByDateDescending = true,
    this.isIncludeDailyReport = true,
  }) {
    init();
  }

  init() {
    MyApp.logger.d("dateDisplay : ${dateDisplay}");

    Query query = FirebaseFirestore.instance
        .collection(keyUserCheckHistories)
        .where('$keyCheckList.$keyDocId', isEqualTo: checkListId);

    if (userId != null) {
      query = query.where('$keyUser.$keyId', isEqualTo: userId);
    }

    if (dateDisplay != null) {
      query = query.where(keyDateDisplay, isEqualTo: dateDisplay);
    }

    query = query.orderBy(keyDate, descending: true);
    query = query.limit(limit);

    ///최근 인증 근무자 첫 수신
    /*query.get().then((value) {
      for (var element in value.docs) {
        ModelUserCheckHistory modelUserCheckHistory =
            ModelUserCheckHistory.fromJson(element.data() as Map, docId: element.id);
        listModelUserCheckHistory.add(modelUserCheckHistory);
      }

      notifyListeners();
    });*/

    ///최근 인증 근무자 변경점 수신
    ///변경점 수신까지는 하지 않는 걸로 함
    streamSubscription = query.snapshots().listen((event) {
      for (var element in event.docChanges) {
        ModelUserCheckHistory modelUserCheckHistory =
            ModelUserCheckHistory.fromJson(element.doc.data() as Map, docId: element.doc.id);

        switch (element.type) {
          case DocumentChangeType.added:
            //MyApp.logger.d("추가 수신");
            listModelUserCheckHistory.add(modelUserCheckHistory);
            break;
          case DocumentChangeType.modified:
            //MyApp.logger.d("수정 수신");
            int index = listModelUserCheckHistory.indexOf(modelUserCheckHistory);
            if (index != -1) {
              listModelUserCheckHistory.removeAt(index);
              listModelUserCheckHistory.insert(index, modelUserCheckHistory);
            }

            break;
          case DocumentChangeType.removed:
            listModelUserCheckHistory.removeWhere((element) => element == modelUserCheckHistory);
            break;
        }

        //정렬

        notifyListeners();
        //sort
      }
    });

    ///일별 인증 통계
    if (isIncludeDailyReport) {
      List<String> listDateDisplay = [];
      DateTime datetimeNow = DateTime.now();
      for (int i = 0; i < dayGetDailyUserCheckHistory; i++) {
        DateTime dateTimeNew =
            DateTime.fromMillisecondsSinceEpoch(datetimeNow.millisecondsSinceEpoch - i * millisecondDay);
        final String displayDateToday = DateFormat('yyyy-MM-dd').format(dateTimeNew);
        listDateDisplay.insert(0, displayDateToday);
      }

      //MyApp.logger.d("keyCheckListId : $checkListId");
      //MyApp.logger.d("listDateDisplay : ${listDateDisplay.toString()}");

      FirebaseFirestore.instance
          .collection(keyCheckListS)
          .doc(checkListId)
          .collection(keyDailyCheckHistories)
          .where(keyDateDisplay, isGreaterThanOrEqualTo: listDateDisplay.first)
          .where(keyDateDisplay, isLessThanOrEqualTo: listDateDisplay.last)
          .orderBy(keyDateDisplay)
          .get()
          .then((value) {
        //MyApp.logger.d("일별 인증 통계 조회 결과 문서 개수 : ${value.docs.length.toString()}");

        for (var element in value.docs) {
          ModelDailyCheckHistory modelDailyCheckHistory =
              ModelDailyCheckHistory.fromJson(element.data(), element.id);
          listModelDailyCheckHistory.add(modelDailyCheckHistory);
        }

        //비어있는 문서 추가
        for (int i = 0; i < listDateDisplay.length; i++) {
          if (listModelDailyCheckHistory
              .where((element) => element.dateDisplay == listDateDisplay[i])
              .isEmpty) {
            //존재하지 않는다면
            try {
              DateTime dateTimeEmpty = DateTime.parse(listDateDisplay[i]);
              ModelDailyCheckHistory modelDailyCheckHistoryEmpty = ModelDailyCheckHistory.fromJson({
                keyDate: dateTimeEmpty,
                keyDateDisplay: listDateDisplay[i],
                keyDateWeek: dateTimeEmpty.weekday,
                keyUserCheckHistoryCount: 0,
              }, '');

              listModelDailyCheckHistory.add(modelDailyCheckHistoryEmpty);
            } catch (e) {
              MyApp.logger.wtf("오류 발생 : ${e.toString()}");
            }
          }
        }

        //정렬
        listModelDailyCheckHistory.sort(
          (a, b) => a.dateDisplay.compareTo(b.dateDisplay),
        );

        MyApp.logger.d(
            'listDateDisplay 개수 : ${listDateDisplay.length}, 서버에서 받아온 일별 인증 통계 조회 결과 문서 개수 : ${value.docs.length}, 로컬 개수 : ${listModelDailyCheckHistory.length}');

        notifyListeners();
      });
    }
  }

  ModelDailyCheckHistory getModelDailyCheckHistory(DateTime dateTime) {
    String dateTimeFormatted = dateFormatYyyyMMDd.format(dateTime);

    Iterable<ModelDailyCheckHistory> iterable =
        listModelDailyCheckHistory.where((element) => element.dateDisplay == dateTimeFormatted);
    if (iterable.isEmpty) {
      return ModelDailyCheckHistory.fromJson({}, '');
    } else {
      return iterable.first;
    }
  }

/*  List<ModelUserCheckHistory> getDailyUserCheckHistoryCount(DateTime dateTime) {
    String dateTimeFormatted = dateFormatYyyyMMDd.format(dateTime);

    Iterable<ModelDailyCheckHistory> iterable =
        listModelDailyCheckHistory.where((element) => element.dateDisplay == dateTimeFormatted);

    if (iterable.isEmpty) {
      return [];
    } else {
      return iterable.first.listModelUserCheckHistory;
    }
  }*/

  void clearProvider({bool isNotify = true}) {
    listModelUserCheckHistory.clear();
    if (isNotify) notifyListeners();
  }
}
