import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RouteVerify extends StatefulWidget {
  const RouteVerify({Key? key}) : super(key: key);

  @override
  State<RouteVerify> createState() => _RouteVerifyState();
}

class _RouteVerifyState extends State<RouteVerify> {
  @override
  void initState() {
    print("args : ${Get.arguments.toString()}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(),
      ),
    );
  }

  init() {}
}
