import 'dart:math';

import 'package:chaleno/chaleno.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:today_safety/const/model/model_user.dart';
import 'package:today_safety/const/value/key.dart';

import '../../../const/value/router.dart';
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
              onPressed: goToRouteCamera,
              child: const Text('안전한 공장, 원료 배합팀 인증하러'),
            ),
            ElevatedButton(
              onPressed: addDummyDataUserCheckHistory,
              child: const Text('user_check_history_count 더미 데이터 추가'),
            ),
            ElevatedButton(
              onPressed: crawl,
              child: const Text('산업안전보건공단 사건사고 크롤'),
            ),
            ElevatedButton(
              onPressed: changeDataUserCheckHistoryStatePend,
              child: const Text('모든 인증 이력 state = pend로 변경'),
            ),
            ElevatedButton(
              onPressed: goToRouteUnknown,
              child: const Text('Unknown 페이지로!'),
            ),
            ElevatedButton(
              onPressed: sendTestFcm,
              child: const Text('test fcm 발송'),
            ),
          ],
        ),
      ),
    );
  }

  goToRouteCamera() async {
    Get.toNamed(
      '$keyRouteCheckListDetail/JzLPqlJc0DfWQvkwV1iS/$keyRouteCheckListCheckWithOutSlash',
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

  changeDataUserCheckHistoryStatePend() async {
    FirebaseFirestore.instance.collection(keyUserCheckHistories).get().then((value) {
      for (var element in value.docs) {
        element.reference.update({keyState: keyPend});
      }
    });
  }

  sendTestFcm() async {
    List<String> listUserIdTarget = [
      'yczine@naver.com&lt=kakao',
      'yczinetest@naver.com&lt=naver',
      'yczine2@gmail.com&lt=kakao',
      'yczine@gmail.com&lt=apple'
    ];

    Set<String> setToken = {};

    await FirebaseFirestore.instance.collection(keyUserS).where(keyId, whereIn: listUserIdTarget).get().then((value) {
      value.docs.forEach((element) {
        ModelUser modelUser = ModelUser.fromJson(element.data(), element.id);
        setToken.addAll([...modelUser.listToken]);
      });
    });
    //전송 시작
    FirebaseFunctions.instanceFor(region: "asia-northeast3").httpsCallable('sendFcmTest').call(<String, dynamic>{
      'tokens': setToken.toList(),
      'test': {
        keyTitle: '오늘안전 날씨 알림',
//        keyBody: DateFormat('HH:mm:ss 발송함').format(DateTime.now()),
        keyBody: '오늘 비 소식이 있어요. 안전에 유의해 주세요.',

      },
    }).then((result) {
      MyApp.logger.d("전송 결과 ${result.data}");
    });

/*    setToken.toList().forEach((element) {
      //전송 시작
      FirebaseFunctions.instanceFor(region: "asia-northeast3").httpsCallable('sendFcmTest').call(<String, dynamic>{
        'token': element,
        'test': {
        keyTitle: '',
        keyBody: DateFormat('HH:mm:ss 발송함').format(DateTime.now()),
      },
      }).then((result) {
        MyApp.logger.d("전송 결과 ${result.data}");
      });
    });*/
  }

  goToRouteUnknown() {
    Get.toNamed('sfdfds');
  }
}
