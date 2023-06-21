import 'dart:math';

import 'package:chaleno/chaleno.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:today_safety/const/model/model_user_check_history.dart';
import 'package:today_safety/const/value/key.dart';

import '../../../const/value/value.dart';
import '../../../my_app.dart';

class RouteTest extends StatefulWidget {
  const RouteTest({Key? key}) : super(key: key);

  @override
  State<RouteTest> createState() => _RouteTestState();
}

class _RouteTestState extends State<RouteTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: addDummyDataUserCheckHistory,
              child: const Text('user_check_history_count 더미 데이터 추가'),
            ),
            ElevatedButton(
              onPressed: crawl,
              child: const Text('산업안전보건공단 사건사고 크롤'),
            ),
          ],
        ),
      ),
    );
  }

  addDummyDataUserCheckHistory() async {
    //기준 체크 리스트 문서 id
    String checkListId = 'Y7eoaYJLn5v1YvolI0xW';
    //그중 특정 날짜 문서 id
    String dailyCheckHistoryId = 'EK3vXwcArBVwuc28RmTL';

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection(keyCheckListS)
        .doc(checkListId)
        .collection(keyDailyCheckHistories)
        .doc(dailyCheckHistoryId)
        .get();

    Map<String, dynamic> jsonOld = documentSnapshot.data() as Map<String, dynamic>;

    //하루 기준 밀리초
    Random random = Random();

    //총 몇일?
    int countTargetDay = 15;

    for (int i = 1; i < countTargetDay; i++) {
      Map<String, dynamic> json = {...jsonOld};
      DateTime datetimeNew =
          DateTime.fromMillisecondsSinceEpoch(jsonOld[keyDate].toDate().millisecondsSinceEpoch - i * millisecondDay);
      final String displayDateToday = DateFormat('yyyy-MM-dd').format(datetimeNew);

      json[keyDate] = Timestamp.fromDate(datetimeNew);
      json[keyDateDisplay] = displayDateToday;
      json[keyDateWeek] = datetimeNew.weekday;
      if (datetimeNew.weekday == 6 || datetimeNew.weekday == 7) {
        json[keyUserCheckHistoryCount] = 0;
      } else {
        json[keyUserCheckHistoryCount] = random.nextInt(27) + 3; //최소3, 최대 29
      }

      FirebaseFirestore.instance
          .collection(keyCheckListS)
          .doc(checkListId)
          .collection(keyDailyCheckHistories)
          .add(json);
    }
  }

  crawl() async {
    final chaleno = await Chaleno().load('https://www.kosha.or.kr/kosha/index.do');

    List<Result> results = chaleno?.querySelectorAll('.articleTitle') ?? [];
    //print('크롤 결과');
    RegExp regExpDate = RegExp(r'^\[[0-9]\/[0-9]*\,');
    RegExp regExpRegion = RegExp(r',[ 가-힣]*\]');

    for (var element in results) {
      String innerHtmlFormatted = element.innerHTML?.trim() ?? '';
      if (innerHtmlFormatted.contains('[') == true) {
        innerHtmlFormatted = innerHtmlFormatted.substring(innerHtmlFormatted.indexOf('['));
      } else {
        continue;
      }

      //print('###${element.href} $innerHtmlFormatted###');

      if (element.href == null || innerHtmlFormatted.isEmpty) {
        continue;
      }

      //정규표현식 적용
      try {
        String? href = element.href;
        String? date = regExpDate.stringMatch(innerHtmlFormatted)?.replaceAll('[', '').replaceAll(',', '');
        String? region = regExpRegion.stringMatch(innerHtmlFormatted)?.replaceAll(']', '').replaceAll(',', '').trim();
        String? title = innerHtmlFormatted.substring(innerHtmlFormatted.indexOf(']') + 1).trim();

        if (href == null || date == null || region == null) {
          throw Exception('href == null || date == null || region == null');
        }

        MyApp.logger.d("정규 표현식 결과\n"
            "href : $href\n"
            "date : $date\n"
            "region : $region\n"
            "title : $title\n");
      } catch (e) {
        MyApp.logger.wtf('정규 표현식 에러 : ${e.toString()}');
      }
    }
  }
}
