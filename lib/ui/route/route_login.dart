import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:today_safety/const/value/color.dart';
import 'package:today_safety/service/provider/provider_user.dart';

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
          builder: (context, child) => Column(
            children: [
              ///아이콘
              Expanded(
                flex: 1,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    alignment: Alignment.center,
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                    color: Colors.yellow.shade700
                    ),
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
                    ],
                  )),

              ///상태
              Consumer<ProviderUser>(
                builder: (context, value, child) => Row(
                  children: [
                    Text('로그인되어 있는 계정 : ${value.modelUser?.id ?? '로그인 안 되어 있음'}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
