import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:today_safety/const/value/color.dart';
import 'package:today_safety/service/provider/provider_user.dart';

import '../../const/value/router.dart';
import '../../my_app.dart';

class RouteLogin extends StatefulWidget {
  const RouteLogin({Key? key}) : super(key: key);

  @override
  State<RouteLogin> createState() => _RouteLoginState();
}

class _RouteLoginState extends State<RouteLogin> {
  late Color customColor;
  BoxDecoration boxDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(10),
  );
  BoxDecoration mainButton = BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    color: Colors.white,
    border: Border.all(width: 2, color: Colors.black45),
  );

  ValueNotifier<bool> valueNotifierIsProcessingLoginWithKakao = ValueNotifier(false);
  ValueNotifier<bool> valueNotifierIsProcessingLoginWithGoogle = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackground,
      body: SafeArea(
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: MyApp.providerUser),
          ],
          builder: (context, child) => Consumer<ProviderUser>(
            builder: (context, value, child) =>

                ///로그인 안됨
                value.modelUser == null
                    ? Column(
                        children: [
                          ///아이콘
                          Expanded(
                            flex: 1,
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Container(
                                alignment: Alignment.center,
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20), color: Colors.yellow.shade700),
                                padding: EdgeInsets.all(30),
                                child: const FaIcon(
                                  FontAwesomeIcons.helmetSafety,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Text(
                                ('오늘안전'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 25,
                                ),
                              )
                            ]),
                          ),

                          ///버튼 영역
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ///카카오 로그인
                                InkWell(
                                  onTap: () async {
                                    print("요청 보냄");
                                    if (valueNotifierIsProcessingLoginWithKakao.value ||
                                        valueNotifierIsProcessingLoginWithGoogle.value) {
                                      return;
                                    }

                                    valueNotifierIsProcessingLoginWithKakao.value = true;
                                    await MyApp.providerUser.loginEasy(LoginType.kakao);
                                    valueNotifierIsProcessingLoginWithKakao.value = false;
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 30),
                                      decoration: boxDecoration.copyWith(
                                        color: Colors.yellow.shade400,
                                      ),
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                                      width: double.infinity,
                                      height: 50,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          //todo ldj, 로딩 중 아이콘 수정
                                          ValueListenableBuilder(
                                            valueListenable: valueNotifierIsProcessingLoginWithKakao,
                                            builder: (context, value, child) => value

                                                ///로딩 중 아이콘
                                                ? LoadingAnimationWidget.inkDrop(color: Colors.brown, size: 24)

                                                ///로딩 중 아님
                                                : const FaIcon(FontAwesomeIcons.solidComment, color: Colors.brown),
                                          ),
                                          const Expanded(
                                            child: Center(
                                              child: Text(
                                                '카카오로 로그인',
                                                style: TextStyle(fontWeight: FontWeight.w800, color: Colors.brown),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                ),

                                ///구글 로그인
                                InkWell(
                                  onTap: () async {
                                    print("요청 보냄");

                                    MyApp.providerUser.loginEasy(LoginType.google);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 30),
                                    decoration: boxDecoration.copyWith(color: Colors.white),
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                                    width: double.infinity,
                                    height: 50,
                                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      FaIcon(FontAwesomeIcons.google),
                                      Expanded(
                                          child: Center(
                                              child: Text(
                                        '구글로 로그인',
                                        style: TextStyle(fontWeight: FontWeight.w800),
                                      )))
                                    ]),
                                  ),
                                ),

                                const SizedBox(
                                  height: 30,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )

                    ///로그인 됨
                    : Column(
                        children: [
                          Text('로그인되어 있는 계정 : ${value.modelUser!.id}'),

                          ///로그아웃
                          InkWell(
                            onTap: () async {
                              MyApp.providerUser.clearProvider();
                            },
                            child: Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                              width: double.infinity,
                              height: 50,
                              child: const Text(
                                '로그아웃',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                          ///관리하는 근무지 정보 영역
                          ///로그인이 된 후 근무지 작성 안했을때
                          value.modelSiteMy == null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
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
                                        height: MediaQuery.of(context).size.height / 4,
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
                                    mainAxisSize: MainAxisSize.min,
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

                                            ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: CachedNetworkImage(
                                            imageUrl: value.modelSiteMy!.urlLogoImage,
                                            fit: BoxFit.cover,
                                          ),
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
                                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
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
                                ),
                        ],
                      ),
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
