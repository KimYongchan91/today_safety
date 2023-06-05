import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:today_safety/const/value/router.dart';

import '../../const/value/key.dart';
import '../../my_app.dart';

class RouteMain extends StatelessWidget {
  const RouteMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('메인 페이지입니다.'),
            ElevatedButton(
              onPressed: () {
                Get.toNamed(keyRouteVerify, arguments: {keyUrl: 'test'});
              },
              child: Text('인증 페이지로'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.toNamed(keyRouteLogin);
              },
              child: Text('로그인 페이지로'),
            ),
            ElevatedButton(
              onPressed: () async {
                AlgoliaQuery algoliaQuery = MyApp.algolia.instance.index('fts_site').query("현대 건설");
                AlgoliaQuerySnapshot snap = await algoliaQuery.getObjects();
                MyApp.logger.d("알고리아 결과 hit 갯수 : ${snap.hits.length}");

                for (var element in snap.hits) {
                  print("문서 id : ${element.objectID}");
                }
              },
              child: Text('풀텍스트 검색 테스트'),
            ),
          ],
        ),
      ),
    );
  }
}
