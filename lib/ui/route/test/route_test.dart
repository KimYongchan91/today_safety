import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:today_safety/const/model/model_user_check_history.dart';
import 'package:today_safety/const/value/key.dart';

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
                onPressed: () async {
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
                  const int millisecondDay = 24 * 60 * 60 * 1000;
                  Random random = Random();

                  //총 몇일?
                  int countTargetDay = 30;

                  for (int i = 1; i < countTargetDay; i++) {
                    Map<String, dynamic> json = {...jsonOld};
                    DateTime datetimeNew = DateTime.fromMillisecondsSinceEpoch(
                        jsonOld[keyDate].toDate().millisecondsSinceEpoch + i * millisecondDay);
                    final String displayDateToday = DateFormat('yyyy-MM-dd').format(datetimeNew);

                    json[keyDate] = Timestamp.fromDate(datetimeNew);
                    json[keyDateDisplay] = displayDateToday;
                    json[keyDateWeek] = datetimeNew.weekday;
                    if (datetimeNew.weekday == 6 || datetimeNew.weekday == 7) {
                      json[keyUserCheckHistoryCount] = 0;
                    } else {
                      json[keyUserCheckHistoryCount] = random.nextInt(7) + 3; //최소3, 최대 9
                    }



                    FirebaseFirestore.instance
                        .collection(keyCheckListS)
                        .doc(checkListId)
                        .collection(keyDailyCheckHistories).add(json);
                  }


                },
                child: const Text('user_check_history_count 더미 데이터 추가'))
          ],
        ),
      ),
    );
  }
}
