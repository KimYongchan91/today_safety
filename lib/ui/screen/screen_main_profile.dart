import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:today_safety/ui/screen/screen_login_login.dart';
import 'package:today_safety/ui/screen/screen_login_profile.dart';

import '../../service/provider/provider_user.dart';

class ScreenMainProfile extends StatefulWidget {
  const ScreenMainProfile({Key? key}) : super(key: key);

  @override
  State<ScreenMainProfile> createState() => _ScreenMainProfileState();
}

class _ScreenMainProfileState extends State<ScreenMainProfile> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderUser>(
      builder: (context, value, child) =>

      ///로그인 안됨
      value.modelUser == null
          ? const ScreenLoginLogin()

      ///로그인 됨
          : ScreenLoginProfile(value),
    );
  }
}
