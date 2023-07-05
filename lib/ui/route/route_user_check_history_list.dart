import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
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
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    InkWell(
                      onTap: (){
                        Get.back();
                      },
                      child: Padding(
                          padding: EdgeInsets.all(10),
                          child: const FaIcon(FontAwesomeIcons.angleLeft,)),
                    ),
                    const Text('받은 인증서',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,),),
                    const Spacer(),

                    Text(
                      '${widget.listModelUserCheckHistory.length}개',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: Colors.orange),
                    ),
                  ],
                ),
              ),
              Container(width: Get.width,
              height: 1,
              color: Colors.black45,),

              const SizedBox(height: 20,),

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
