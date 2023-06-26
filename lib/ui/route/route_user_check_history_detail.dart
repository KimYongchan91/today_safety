import 'package:flutter/material.dart';

import '../../const/model/model_user_check_history.dart';

class RouteUserCheckHistoryDetail extends StatefulWidget {
  final ModelUserCheckHistory modelUserCheckHistory;

  const RouteUserCheckHistoryDetail(this.modelUserCheckHistory, {Key? key}) : super(key: key);

  @override
  State<RouteUserCheckHistoryDetail> createState() => _RouteUserCheckHistoryDetailState();
}

class _RouteUserCheckHistoryDetailState extends State<RouteUserCheckHistoryDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(),
      ),
    );
  }
}
