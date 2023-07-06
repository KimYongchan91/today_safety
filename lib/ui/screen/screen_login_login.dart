import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:today_safety/service/util/util_snackbar.dart';

import '../../my_app.dart';
import '../../service/provider/provider_user.dart';

class ScreenLoginLogin extends StatefulWidget {
  const ScreenLoginLogin({Key? key}) : super(key: key);

  @override
  State<ScreenLoginLogin> createState() => _ScreenLoginLoginState();
}

class _ScreenLoginLoginState extends State<ScreenLoginLogin> {
  ValueNotifier<bool> valueNotifierIsProcessingLoginWithKakao = ValueNotifier(false);
  ValueNotifier<bool> valueNotifierIsProcessingLoginWithNaver = ValueNotifier(false);
  ValueNotifier<bool> valueNotifierIsProcessingLoginWithGoogle = ValueNotifier(false);
  ValueNotifier<bool> valueNotifierIsProcessingLoginWithApple = ValueNotifier(false);

  late List<ValueNotifier<bool>> listValueNotifierIsProcessingLogin;

  BoxDecoration boxDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(10),
  );

  BoxDecoration mainButton = BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    color: Colors.white,
    border: Border.all(width: 2, color: Colors.black45),
  );

  @override
  void initState() {
    listValueNotifierIsProcessingLogin = [
      valueNotifierIsProcessingLoginWithKakao,
      valueNotifierIsProcessingLoginWithNaver,
      valueNotifierIsProcessingLoginWithGoogle,
      valueNotifierIsProcessingLoginWithApple,
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ///아이콘
        Expanded(
          flex: 1,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/logo/app_logo_big_720.png',
                  width: 150,
                  height: 150,
                )),
            const SizedBox(
              height: 20,
            ),
            const Text(
              '오늘안전',
              style: TextStyle(
                fontFamily: "SANGJU",
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 30,
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
                  if (listValueNotifierIsProcessingLogin
                      .where((element) => element.value == true)
                      .isNotEmpty) {
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
                              '카카오 로그인',
                              style: TextStyle(fontWeight: FontWeight.w800, color: Colors.brown),
                            ),
                          ),
                        ),
                      ],
                    )),
              ),

              ///네이버 로그인
              InkWell(
                onTap: () async {
                  if (listValueNotifierIsProcessingLogin
                      .where((element) => element.value == true)
                      .isNotEmpty) {
                    return;
                  }

                  valueNotifierIsProcessingLoginWithNaver.value = true;
                  await MyApp.providerUser.loginEasy(LoginType.naver);
                  valueNotifierIsProcessingLoginWithNaver.value = false;
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: boxDecoration.copyWith(color:const Color(0xff00C73C)),
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  width: double.infinity,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: valueNotifierIsProcessingLoginWithNaver,
                        builder: (context, value, child) => value

                            ///로딩 중 아이콘
                            ? LoadingAnimationWidget.inkDrop(color: Colors.white, size: 24)

                            ///로딩 중 아님
                            :  SizedBox(
                            width: 20,
                            child: Image.asset('assets/images/logo/naver.png')),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            '네이버 로그인',
                            style: TextStyle(color: Colors.white,fontWeight: FontWeight.w800),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              ///구글 로그인
              InkWell(
                onTap: () async {
                  showSnackBarOnRoute('현재 구글 로그인을 사용할 수 없어요.');
                  //print("요청 보냄");
                  //MyApp.providerUser.loginEasy(LoginType.google);
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
                          '구글 로그인',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    )
                  ]),
                ),
              ),

              ///애플 로그인
              InkWell(
                onTap: () async {
                  if (listValueNotifierIsProcessingLogin
                      .where((element) => element.value == true)
                      .isNotEmpty) {
                    return;
                  }

                  valueNotifierIsProcessingLoginWithApple.value = true;
                  await MyApp.providerUser.loginEasy(LoginType.apple);
                  valueNotifierIsProcessingLoginWithApple.value = false;
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: boxDecoration.copyWith(color: Colors.black),
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  width: double.infinity,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: valueNotifierIsProcessingLoginWithApple,
                        builder: (context, value, child) => value

                            ///로딩 중 아이콘
                            ? LoadingAnimationWidget.inkDrop(color: Colors.white, size: 24)

                            ///로딩 중 아님
                            : const FaIcon(FontAwesomeIcons.apple, color: Colors.white),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            '애플 로그인',
                            style: TextStyle(fontWeight: FontWeight.w800,color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
