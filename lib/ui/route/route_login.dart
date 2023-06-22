import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:today_safety/const/value/color.dart';
import 'package:today_safety/service/provider/provider_user.dart';
import 'package:today_safety/ui/screen/screen_login_login.dart';
import 'package:today_safety/ui/screen/screen_login_profile.dart';

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
                    ? const ScreenLoginLogin()

                    ///로그인 됨
                    : ScreenLoginProfile(value),
          ),
        ),
      ),
    );
  }
}
