import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:today_safety/const/model/model_check_list.dart';
import 'package:today_safety/const/value/color.dart';
import 'package:today_safety/const/value/value.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/service/provider/provider_user_check_history_on_check_list.dart';
import 'package:today_safety/ui/item/item_check.dart';
import 'package:today_safety/ui/item/item_user_check_history_small.dart';
import 'package:today_safety/ui/route/route_notice_new.dart';
import 'package:today_safety/ui/route/route_qr_code_detail.dart';
import 'package:today_safety/ui/widget/icon_error.dart';
import '../../const/value/router.dart';
import '../../my_app.dart';
import '../../service/util/util_app_link.dart';
import '../../service/util/util_chart.dart';
import '../../service/util/util_check_list.dart';
import '../item/item_calendar.dart';

class RouteCheckListDetail extends StatefulWidget {
  const RouteCheckListDetail({Key? key}) : super(key: key);

  @override
  State<RouteCheckListDetail> createState() => _RouteCheckListDetailState();
}

class _RouteCheckListDetailState extends State<RouteCheckListDetail> {
  late Completer<bool> completerModelCheckList;
  ModelCheckList? modelCheckList;
  late ProviderUserCheckHistoryOnCheckList providerUserCheckHistory;
  bool isViewCalendar = true;
  bool isViewChart = false;

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
    providerUserCheckHistory = ProviderUserCheckHistoryOnCheckList(checkListId: modelCheckList!.docId);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle btnTxtStyle = const TextStyle(color: Colors.black45, fontWeight: FontWeight.bold, fontSize: 16);
    BoxDecoration btnDecoration = BoxDecoration(
      border: Border.all(
        width: 0.5,
      ),
    );

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
                      ///앱바
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                              width: 20,
                            ),
                            Expanded(
                              child: Text(
                                modelCheckList!.name,
                                style: const CustomTextStyle.bigBlackBold(),
                              ),
                            ),

                            ///qr 코드
                            InkWell(
                              onTap: () {
                                Get.to(() => RouteQrCodeDetail(modelCheckList!));
                              },
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: SfBarcodeGenerator(
                                  value: '$urlBaseAppLink$keyRouteCheckListDetail/${modelCheckList!.docId}/$keyRouteCheckListCheckWithOutSlash',
                                  symbology: QRCode(),
                                  showValue: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        width: Get.width,
                        height: 1,
                        color: Colors.black45,
                      ),

                      Container(
                        padding: const EdgeInsets.all(20),
                        color: Colors.white,
                        width: Get.width,
                        child: Column(
                          children: [
                            const Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                '인증 현황',
                                style:
                                    TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),

                            const SizedBox(
                              height: 20,
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                    onTap: () {
                                      isViewCalendar = true;
                                      if (isViewCalendar == true) {
                                        isViewChart = false;
                                      }
                                      setState(() {});
                                    },
                                    child: Text(
                                      '달력',
                                      style: btnTxtStyle.copyWith(
                                          fontSize: isViewCalendar == true ? 17 : 15,
                                          color: isViewCalendar == true ? Colors.black : Colors.black45),
                                    )),
                                const SizedBox(
                                  width: 20,
                                ),
                                InkWell(
                                  onTap: () {
                                    isViewChart = true;
                                    if (isViewChart == true) {
                                      isViewCalendar = false;
                                    }
                                    setState(() {});
                                  },
                                  child: Text(
                                    '그래프',
                                    style: btnTxtStyle.copyWith(
                                        fontSize: isViewChart == true ? 17 : 15,
                                        color: isViewChart == true ? Colors.black : Colors.black45),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 20,
                            ),

                            ///달력
                            isViewCalendar == true
                                ? Consumer<ProviderUserCheckHistoryOnCheckList>(
                                    builder: (context, value, child) => TableCalendar(
                                      firstDay: DateTime.fromMillisecondsSinceEpoch(
                                          DateTime.now().millisecondsSinceEpoch -
                                              millisecondDay * dayGetDailyUserCheckHistory),
                                      lastDay: DateTime.now(),
                                      focusedDay: DateTime.now(),
                                      locale: keyKoreanKorea,
                                      //달력 형식 바꾸는 버튼
                                      availableCalendarFormats: const {
                                        CalendarFormat.month: 'Month',
                                        // CalendarFormat.twoWeeks: '2 weeks',
                                        // CalendarFormat.week: 'Week'
                                      },

                                      //제스처 인식 방향
                                      availableGestures: AvailableGestures.horizontalSwipe,
                                      //월 보여주는 부분
                                      headerVisible: true,
                                      //요일 보여주는 부분
                                      daysOfWeekVisible: true,
                                      //페이지 점프를 사용할지
                                      pageJumpingEnabled: false,
                                      //페이지 점프 에니메이션을 사용할지
                                      pageAnimationEnabled: true,
                                      //이번 주가 올해의 몇 주차인지 보여주는 부분
                                      weekNumbersVisible: false,
                                      headerStyle: HeaderStyle(
                                        titleCentered: true,
                                        formatButtonVisible: false,
                                        formatButtonShowsNext: false,
                                        titleTextFormatter: (date, locale) {
                                          return DateFormat('yyyy년 M월').format(date);
                                        },
                                        //rightChevronIcon: const Icon(Icons.chevron_right,color: Colors.transparent,),
                                        //leftChevronIcon: false,
                                      ),

                                      onPageChanged: (focusedDay) {
                                        print("페이지 바뀜");
                                      },

                                      calendarBuilders: CalendarBuilders(
                                        //맨위 요일 빌더
                                        dowBuilder: (context, day) {
                                          final text = DateFormat('EEE', keyKoreanKorea).format(day);
                                          Color color = Colors.black;
                                          if (day.weekday == DateTime.saturday) {
                                            color = Colors.blue;
                                          } else if (day.weekday == DateTime.sunday) {
                                            color = Colors.red;
                                          }
                                          return Center(
                                            child: Text(
                                              text,
                                              style: TextStyle(color: color),
                                            ),
                                          );
                                        },

                                        //기본 빌더
                                        defaultBuilder: (context, day, focusedDay) {
                                          return ItemCalendar(
                                            dateTime: day,
                                            listModelUserCheckHistory:
                                                value.getDailyUserCheckHistoryCount(day),
                                          );
                                        },

                                        //마커 빌더
                                        /*markerBuilder: (context, day, focusedDay) {
                              return Text(
                                '${value.getDailyUserCheckHistoryCount(day).length}건',
                                style: CustomTextStyle.normalGrey(),
                              );
                            },*/

                                        //오늘 날짜 빌더
                                        todayBuilder: (context, day, focusedDay) {
                                          return ItemCalendar(
                                            dateTime: day,
                                            isToday: true,
                                            listModelUserCheckHistory:
                                                value.getDailyUserCheckHistoryCount(day),
                                          );
                                        },

                                        //조회 날짜 범위 밖 빌더
                                        disabledBuilder: (context, day, focusedDay) {
                                          return Container();
                                        },
                                      ),
                                    ),
                                  )
                                : const SizedBox(),

                            isViewChart == true
                                ?

                                ///차트
                                Consumer<ProviderUserCheckHistoryOnCheckList>(
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
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      ///최근 인증한 유저
                      ///3개 정도?
                      Consumer<ProviderUserCheckHistoryOnCheckList>(
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
                                itemBuilder: (context, index) => ItemUserCheckHistorySmall(
                                  value.listModelUserCheckHistory[index],
                                  modelCheckList: modelCheckList,
                                ),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                              )
                            ],
                          ),
                        ),
                      ),

                      ///공지 사항
                      const Text(
                        '공지 사항',
                        style: CustomTextStyle.bigBlackBold(),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Get.to(()=>RouteNoticeNew(modelSite: modelCheckList!.modelSite, modelCheckList: modelCheckList));
                        },
                        child: Text('새 공지사항 만들기'),
                      ),

                      ///체크 리스트
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '인증 항목',
                              style: CustomTextStyle.bigBlackBold(),
                            ),
                            const SizedBox(
                              height: 20,
                            ),

                            ///체크 리스트 뷰
                            ListView.builder(
                              itemCount: modelCheckList!.listModelCheck.length,
                              itemBuilder: (context, index) => ItemCheck(
                                modelCheck :  modelCheckList!.listModelCheck[index],
                                itemCheckType: ItemCheckType.none,
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
