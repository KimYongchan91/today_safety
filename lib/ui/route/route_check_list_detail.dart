import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../const/value/router.dart';
import '../../my_app.dart';

class RouteCheckListDetail extends StatefulWidget {
  const RouteCheckListDetail({Key? key}) : super(key: key);

  @override
  State<RouteCheckListDetail> createState() => _RouteCheckListDetailState();
}

class _RouteCheckListDetailState extends State<RouteCheckListDetail> {
  @override
  void initState() {
    MyApp.logger.d("keyCheckListId : ${Get.parameters[keyCheckListId]}");
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
}
