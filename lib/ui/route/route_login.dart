import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../../my_app.dart';

class RouteLogin extends StatefulWidget {
  const RouteLogin({Key? key}) : super(key: key);

  @override
  State<RouteLogin> createState() => _RouteLoginState();
}

class _RouteLoginState extends State<RouteLogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ElevatedButton(
          onPressed: () async {
            print("요청 보냄");

            MyApp.providerUser.loginWithKakao();

          /*  HttpsCallableResult<dynamic> result = await FirebaseFunctions.instanceFor(region: "asia-northeast3")
                .httpsCallable('loginEasy')
                .call(<String, dynamic>{
              'email': 'yczine@gmail.com',
              'login_type': 'kakao',
            });

            print("응답 결과 : ${result.data}");*/
          },
          child: Text('카카오 로그인'),
        ),
      ),
    );
  }
}
