import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:today_safety/const/model/model_check_list.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/service/util/util_check_list.dart';
import 'package:today_safety/ui/widget/icon_error.dart';

import '../../const/model/model_user_check_history.dart';
import '../../const/value/router.dart';
import '../../my_app.dart';
import '../../service/provider/provider_user_check_history_on_check_list.dart';
import '../item/item_user_check_history_small.dart';

class RouteCheckListRecent extends StatefulWidget {
  const RouteCheckListRecent({Key? key}) : super(key: key);

  @override
  State<RouteCheckListRecent> createState() => _RouteCheckListRecentState();
}

class _RouteCheckListRecentState extends State<RouteCheckListRecent> {
  late Completer<bool> completerGetModelCheckList;
  late ModelCheckList modelCheckList;

  late ProviderUserCheckHistoryOnCheckList providerUserCheckHistoryOnCheckList;

  @override
  void initState() {
    super.initState();

    MyApp.logger.d("keyCheckListId : ${Get.parameters[keyCheckListId]}");

    completerGetModelCheckList = Completer();

    if (Get.parameters[keyCheckListId] == null) {
      completerGetModelCheckList.complete(false);
    } else {
      getModelCheckListFromServerByDocId(Get.parameters[keyCheckListId]!).then((value) {
        if (value != null) {
          modelCheckList = value;
          completerGetModelCheckList.complete(true);
        } else {
          completerGetModelCheckList.complete(false);
        }
      });
    }

    providerUserCheckHistoryOnCheckList = ProviderUserCheckHistoryOnCheckList(
      checkListId: Get.parameters[keyCheckListId]!,
      limit: 100,
      isIncludeDailyReport: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: providerUserCheckHistoryOnCheckList),
          ],
          child: SingleChildScrollView(
            child: Column(
              children: [
                FutureBuilder(
                  future: completerGetModelCheckList.future,
                  builder: (context, snapshot) {
                    if (snapshot.hasData == false) {
                      return Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: Center(
                          child: LoadingAnimationWidget.inkDrop(color: Colors.green, size: 32),
                        ),
                      );
                    } else {
                      if (snapshot.data == true) {
                        return Consumer<ProviderUserCheckHistoryOnCheckList>(
                          builder: (context, value, child) => ListView.builder(
                            itemCount: value.listModelUserCheckHistory.length,
                            itemBuilder: (context, index) => ItemUserCheckHistorySmall(
                              value.listModelUserCheckHistory[index],
                              modelCheckList: modelCheckList,
                            ),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                          ),
                        );
                      } else {
                        return const Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Center(
                            child: IconError(),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
