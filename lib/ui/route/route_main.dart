import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:today_safety/const/value/router.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/service/provider/provider_user.dart';

import '../../const/value/key.dart';
import '../../my_app.dart';

class RouteMain extends StatelessWidget {
  const RouteMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: MyApp.providerUser),
        ],
        builder: (context, child) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('메인 페이지입니다.'),
              Card(
                elevation: 12,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    width: Get.width * 0.9,
                    height: 300,
                    child: Stack(
                      children: [
                        const Row(
                          children: [
                            Text(
                              '현재 근무지',
                              style: CustomTextStyle.titleBlack(),
                            ),
                          ],
                        ),
                        Consumer<ProviderUser>(
                          builder: (context, value, child) => Center(
                            child: value.modelUser == null
                                ? const Text(
                                    '로그인을 해주세요.',
                                    style: CustomTextStyle.bigBlack(),
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('아직 가입하기 전'),
                                      InkWell(
                                        child: const Padding(
                                          padding: EdgeInsets.all(20),
                                          child: Icon(
                                            Icons.search,
                                            size: 48,
                                          ),
                                        ),
                                        onTap: () {
                                          Get.toNamed(
                                            keyRouteSiteSearch,
                                            arguments: {
                                              //'keyword': 'sex',
                                            },
                                          );
                                        },
                                      )
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.toNamed(keyRouteVerify, arguments: {keyUrl: 'test'});
                },
                child: const Text('인증 페이지로'),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.toNamed(keyRouteLogin);
                },
                child: const Text('로그인 페이지로'),
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
                child: const Text('풀텍스트 검색 테스트'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
