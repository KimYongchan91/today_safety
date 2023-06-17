import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:today_safety/const/model/model_check_list.dart';
import 'package:today_safety/const/value/color.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/service/provider/provider_user_check_history.dart';
import 'package:today_safety/ui/item/item_check.dart';
import 'package:today_safety/ui/item/item_user_check_history.dart';
import 'package:today_safety/ui/widget/icon_error.dart';

import '../../const/value/router.dart';
import '../../my_app.dart';
import '../../service/util/util_app_link.dart';
import '../../service/util/util_chart.dart';
import '../../service/util/util_check_list.dart';

class RouteCheckListDetail extends StatefulWidget {
  const RouteCheckListDetail({Key? key}) : super(key: key);

  @override
  State<RouteCheckListDetail> createState() => _RouteCheckListDetailState();
}

class _RouteCheckListDetailState extends State<RouteCheckListDetail> {
  late Completer<bool> completerModelCheckList;
  ModelCheckList? modelCheckList;
  late ProviderUserCheckHistory providerUserCheckHistory;

  @override
  void initState() {
    MyApp.logger.d("keyCheckListId : ${Get.parameters[keyCheckListId]}");

    completerModelCheckList = Completer();

    if (Get.parameters[keyCheckListId] == null) {
      completerModelCheckList.complete(false);
      return;
    }

    if (Get.arguments?[keyModelCheckList] != null) {
      modelCheckList = Get.arguments[keyModelCheckList];
      completerModelCheckList.complete(true);
    } else {
      getModelCheckListFromServerByDocId(Get.parameters[keyCheckListId]!).then((value) {
        if (value != null) {
          modelCheckList = value;
          completerModelCheckList.complete(true);
        } else {
          modelCheckList = null;
          completerModelCheckList.complete(false);
        }
      });
    }

    completerModelCheckList.future.then((value) {
      if (value) {
        initByCheckList();
      }
    });

    super.initState();
  }

  initByCheckList() {
    providerUserCheckHistory = ProviderUserCheckHistory(checkListId: modelCheckList!.docId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackground,
      body: SafeArea(
        child: FutureBuilder<bool>(
          future: completerModelCheckList.future,
          builder: (context, snapshot) {
            if (snapshot.hasData == false) {
              ///로딩 중
              return Center(
                child: LoadingAnimationWidget.inkDrop(
                  color: Colors.greenAccent,
                  size: 48,
                ),
              );
            } else if (snapshot.data == true) {
              return MultiProvider(
                providers: [
                  ChangeNotifierProvider.value(value: providerUserCheckHistory),
                ],
                builder: (context, child) => SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        width: Get.width,
                        height: 70,
                        color: Colors.white,
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Get.back();
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: FaIcon(
                                  FontAwesomeIcons.angleLeft,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              modelCheckList!.name,
                              style: const CustomTextStyle.bigBlackBold(),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        width: Get.width,
                        height: 1,
                        color: Colors.black45,
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      ///체크 리스트 이름, QR 코드
                      Row(
                        children: [
                          ///QR 코드
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: SfBarcodeGenerator(
                              value: '$urlAppLink/${modelCheckList!.docId}',
                              symbology: QRCode(),
                              showValue: false,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      const Text(
                        '최근 인증 추세',
                        style: CustomTextStyle.bigBlackBold(),
                      ),
                      const SizedBox(
                        height: 20,
                      ),

                      Consumer<ProviderUserCheckHistory>(
                        builder: (context, value, child) => AspectRatio(
                          aspectRatio: 3 / 2,
                          child: BarChart(
                            getLineChartData(value.listModelDailyCheckHistory),
                          ),
                        ),
                        /*ListView.builder(
                          itemCount: value.listModelDailyCheckHistory.length,
                          itemBuilder: (context, index) => Text(value.listModelDailyCheckHistory[index].dateDisplay +
                              value.listModelDailyCheckHistory[index].userCheckHistoryCount.toString()),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                        )*/
                      ),
                      const SizedBox(
                        height: 20,
                      ),

                      ///최근 인증한 유저
                      ///3개 정도?
                      Consumer<ProviderUserCheckHistory>(
                        builder: (context, value, child) => Container(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '최근 인증 근무자',
                                      style: CustomTextStyle.bigBlackBold(),
                                    ),
                                    Text(
                                      '더보기',
                                      style: CustomTextStyle.normalGreyBold(),
                                    )
                                  ],
                                ),
                              ),
                              ListView.builder(
                                itemCount: value.listModelUserCheckHistory.length,
                                itemBuilder: (context, index) => ItemUserCheckHistory(
                                  value.listModelUserCheckHistory[index],
                                ),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                              )
                            ],
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '인증 항목',
                              style: CustomTextStyle.bigBlackBold(),
                            ),
                            SizedBox(
                              height: 20,
                            ),

                            ///체크 항목 리스트 뷰
                            ListView.builder(
                              itemCount: modelCheckList!.listModelCheck.length,
                              itemBuilder: (context, index) => ItemCheck(
                                modelCheckList!.listModelCheck[index],
                              ),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const Center(
                child: IconError(),
              );
            }
          },
        ),
      ),
    );
  }
}
