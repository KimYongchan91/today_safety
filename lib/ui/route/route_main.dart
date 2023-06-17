import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:today_safety/const/value/router.dart';
import 'package:today_safety/service/provider/provider_user.dart';
import 'package:today_safety/ui/route/test/route_test.dart';

import '../../const/value/color.dart';
import '../../const/value/key.dart';
import '../../my_app.dart';

//동준과의 test
class RouteMain extends StatelessWidget {
  const RouteMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BoxDecoration mainButton = BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Colors.white,
      border: Border.all(width: 2, color: Colors.black45),
    );

    return Scaffold(
      backgroundColor: colorBackground,
      body: SafeArea(
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: MyApp.providerUser),
          ],
          builder: (context, child) => Center(
            child: Column(
                //mainAxisSize: MainAxisSize.min,

                children: [
                  ///앱바
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    width: MediaQuery.of(context).size.width,
                    height: 65,
                    color: Colors.white,
                    child: Row(
                      children: [
                        ///아이콘
                        InkWell(
                          onTap: () {
                            Get.to(() => const RouteTest());
                          },
                          child: FaIcon(
                            FontAwesomeIcons.helmetSafety,
                            color: Colors.yellow.shade700,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          '오늘안전',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),

                        const Spacer(),

                        ///인증페이지
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: InkWell(
                            onTap: () {
                              Get.toNamed(
                                  '$keyRouteCheckListDetail/Y7eoaYJLn5v1YvolI0xW/$keyRouteCheckListCheckWithOutSlash',
                                  arguments: {keyUrl: 'test'});
                            },
                            child: const FaIcon(
                              FontAwesomeIcons.camera,
                              size: 18,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 5,
                        ),

                        ///로그인페이지
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: InkWell(
                            onTap: () {
                              Get.toNamed(keyRouteLogin);
                            },
                            child: const FaIcon(
                              FontAwesomeIcons.user,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  ///앱바 구분선
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 0.5,
                    color: Colors.black45,
                  ),

                  ///로그인 정보 영역
                  Consumer<ProviderUser>(
                    builder: (context, value, child) => value.modelUser == null

                        ///로그인 정보 없을때
                        ? const SizedBox()

                        ///로그인 중일때
                        : Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            color: Colors.white,
                            width: MediaQuery.of(context).size.width,
                            child: Row(children: [
                              const FaIcon(
                                FontAwesomeIcons.solidUserCircle,
                                color: Colors.grey,
                                size: 40,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Consumer<ProviderUser>(
                                builder: (context, value, child) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ///이름
                                    const Text(
                                      '이근영',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),

                                    ///ㅇㅏㅇㅣㄷㅣ
                                    Text(
                                      value.modelUser?.id ?? '로그인을 해주세요.',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          ),
                  ),

                  Consumer<ProviderUser>(
                    builder: (context, value, child) => value.modelUser == null

                        ///로그인 안됐을때
                        ? const UnLoginUserArea()

                        ///로그인 상태일때
                        : Container(
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(20),
                            width: MediaQuery.of(context).size.width,
                            child:

                                ///로그인이 된 후 근무지 작성 안했을때
                                value.modelSiteMy == null
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Expanded(
                                                child: Text(
                                                  '나의 근무지를 등록하세요.',
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  Get.toNamed(
                                                    keyRouteSiteSearch,
                                                    arguments: {
                                                      //'keyword': 'sex',
                                                    },
                                                  );
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.all(5),
                                                  child: FaIcon(FontAwesomeIcons.search),
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(
                                            height: 40,
                                          ),

                                          ///근무지 만들기 버튼
                                          InkWell(
                                            onTap: () {
                                              Get.toNamed(
                                                keyRouteSiteNew,
                                                arguments: {
                                                  //'keyword': 'sex',
                                                },
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              height: MediaQuery.of(context).size.height / 5,
                                              decoration: mainButton,
                                              child: const Expanded(
                                                  child: Center(
                                                      child: FaIcon(
                                                FontAwesomeIcons.add,
                                                size: 35,
                                                color: Colors.black45,
                                              ))),
                                            ),
                                          ),

                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                '근무지 만들기',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold, color: Colors.black45, fontSize: 16),
                                              ))
                                        ],
                                      )

                                    ///로그인 되어있고, 내가 관리하는 근무지가 있을 때
                                    : InkWell(
                                        onTap: goRouteSiteDetail,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              '내가 관리하는 근무지',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                            ),

                                            const SizedBox(
                                              height: 30,
                                            ),

                                            ///이미지 영역
                                            Container(
                                              width: Get.width,
                                              height: Get.height / 4,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(20), color: Colors.redAccent),
                                              child:
                                                  //todo ldj 근무지 로고 이미지 부분 수정
                                                  ///근무지 로고 이미지
                                                  CachedNetworkImage(
                                                imageUrl: value.modelSiteMy!.urlLogoImage,
                                              ),
                                            ),

                                            const SizedBox(
                                              height: 20,
                                            ),

                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      ///근무지 이름
                                                      Text(
                                                        value.modelSiteMy!.name,
                                                        style:
                                                            const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                                                      ),

                                                      const SizedBox(
                                                        height: 10,
                                                      ),

                                                      ///주소
                                                      const Row(
                                                        children: [
                                                          FaIcon(
                                                            FontAwesomeIcons.locationDot,
                                                            size: 16,
                                                          ),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text('서울시 은평구 불광동 32번 가길'),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: FaIcon(FontAwesomeIcons.angleRight),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      )),
                  ),

                  /*
                  ElevatedButton(
                    onPressed: () {
                      //'$keyRouteCheckListDetail/:$keyCheckListId/$keyRouteCheckListCheck',
                      Get.toNamed('$keyRouteCheckListDetail/Y7eoaYJLn5v1YvolI0xW/$keyRouteCheckListCheckWithOutSlash',
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


                  */
                ]),
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

///로그인 안됐을때
class UnLoginUserArea extends StatefulWidget {
  const UnLoginUserArea({Key? key}) : super(key: key);

  @override
  State<UnLoginUserArea> createState() => _UnLoginUserAreaState();
}

class _UnLoginUserAreaState extends State<UnLoginUserArea> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.lock,
              size: 50,
              color: Colors.grey,
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              '로그인 후 이용가능한 서비스입니다.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '로그인을 해주세요.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
