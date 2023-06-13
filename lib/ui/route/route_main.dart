import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:today_safety/const/value/router.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/service/provider/provider_user.dart';

import '../../const/value/key.dart';
import '../../my_app.dart';

//동준과의 test
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
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Text(
                              '내가 관리하는 근무지',
                              style: CustomTextStyle.bigBlack(),
                            ),
                          ],
                        ),
                        Consumer<ProviderUser>(
                          builder: (context, value, child) => Center(
                            ///로그인 전이라면
                            child: value.modelUser == null
                                ? const Text(
                                    '로그인을 해주세요.',
                                    style: CustomTextStyle.bigBlack(),
                                  )

                                ///내가 아직 근무지를 만들지 않았다면
                                : value.modelSiteMy == null
                                    ? (Column(
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
                                          ),
                                          InkWell(
                                            child: const Padding(
                                              padding: EdgeInsets.all(20),
                                              child: Icon(
                                                Icons.add,
                                                size: 48,
                                              ),
                                            ),
                                            onTap: () {
                                              Get.toNamed(
                                                keyRouteSiteNew,
                                                arguments: {
                                                  //'keyword': 'sex',
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      ))

                                    ///내가 근무지를 만들었다면
                                    : InkWell(
                                        onTap: goRouteSiteDetail,
                                        child: Column(
                                          children: [
                                            Text(
                                              value.modelSiteMy!.name,
                                              style: const CustomTextStyle.bigBlack(),
                                            ),
                                            const Text(
                                              '최근 확인 내역',
                                              style: CustomTextStyle.normalGreyBold(),
                                            )
                                          ],
                                        ),
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
                  //'$keyRouteCheckListDetail/:$keyCheckListId/$keyRouteCheckListCheck',
                  Get.toNamed('$keyRouteCheckListDetail/dsfksfjl/$keyRouteCheckListCheckWithOutSlash',
                      arguments: {keyUrl: 'test'});
                },
                child: const Text('인증 페이지로'),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.toNamed(keyRouteLogin);
                },
                child: const Text('로그인 페이지로'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  goRouteSiteDetail() {
    Get.toNamed('$keyRouteSiteDetail/${MyApp.providerUser.modelSiteMy?.docId ?? ''}',
        arguments: {keyModelSite: MyApp.providerUser.modelSiteMy});
  }
}
