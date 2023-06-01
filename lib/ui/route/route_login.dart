import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:today_safety/service/provider/provider_user.dart';

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
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: MyApp.providerUser),
          ],
          builder: (context, child) =>
              Column(
                children: [
                  Consumer<ProviderUser>(builder: (context, value, child) =>
                    Row(
                      children: [
                        Text('로그인되어 있는 계정 : ${value.modelUser?.id ?? '로그인 안 되어 있음'}'),
                      ],
                    )
                    ,)
                  ,
                  ElevatedButton(
                    onPressed: () async {
                      print("요청 보냄");

                      MyApp.providerUser.loginEasy(LoginType.kakao);
                    },
                    child: Text('카카오 로그인'),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}
