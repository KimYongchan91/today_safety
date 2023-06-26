import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../my_app.dart';
import '../../service/provider/provider_user.dart';

class ScreenLoginLogin extends StatefulWidget {
  const ScreenLoginLogin({Key? key}) : super(key: key);

  @override
  State<ScreenLoginLogin> createState() => _ScreenLoginLoginState();
}

class _ScreenLoginLoginState extends State<ScreenLoginLogin> {
  ValueNotifier<bool> valueNotifierIsProcessingLoginWithKakao = ValueNotifier(false);
  ValueNotifier<bool> valueNotifierIsProcessingLoginWithGoogle = ValueNotifier(false);

  BoxDecoration boxDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(10),
  );

  BoxDecoration mainButton = BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    color: Colors.white,
    border: Border.all(width: 2, color: Colors.black45),
  );

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
                  'assets/images/logo/app_logo_720.png',
                  width: 150,
                  height: 150,
                )),
            const SizedBox(
              height: 20,
            ),
            const Text(
              '오늘 안전',
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
                  if (valueNotifierIsProcessingLoginWithKakao.value || valueNotifierIsProcessingLoginWithGoogle.value) {
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
    );
  }
}
