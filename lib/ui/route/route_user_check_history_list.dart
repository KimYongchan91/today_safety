import 'package:flutter/material.dart';
import 'package:today_safety/ui/item/item_user_check_history_big.dart';

import '../../const/model/model_user_check_history.dart';
import '../../const/value/layout_main.dart';

class RouteUserCheckHistoryList extends StatefulWidget {
  final List<ModelUserCheckHistory> listModelUserCheckHistory;

  const RouteUserCheckHistoryList(this.listModelUserCheckHistory, {Key? key}) : super(key: key);

  @override
  State<RouteUserCheckHistoryList> createState() => _RouteUserCheckHistoryListState();
}

class _RouteUserCheckHistoryListState extends State<RouteUserCheckHistoryList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                '${widget.listModelUserCheckHistory.length}개',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              ListView.builder(
                itemCount: widget.listModelUserCheckHistory.length,
                itemBuilder: (context, index) => ItemUserCheckHistoryBig(widget.listModelUserCheckHistory[index]),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
