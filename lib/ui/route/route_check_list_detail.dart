import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:today_safety/service/provider/provider_notice.dart';
import 'package:today_safety/service/provider/provider_user_check_history_on_check_list.dart';
import 'package:today_safety/ui/item/item_check.dart';
import 'package:today_safety/ui/item/item_notice_small.dart';
import 'package:today_safety/ui/item/item_user_check_history_small.dart';
import 'package:today_safety/ui/route/route_notice_new.dart';
import 'package:today_safety/ui/route/route_qr_code_detail.dart';
import 'package:today_safety/ui/widget/icon_error.dart';
import '../../const/value/key.dart';
import '../../const/value/router.dart';
import '../../my_app.dart';
import '../../service/util/util_app_link.dart';
import '../../service/util/util_chart.dart';
import '../../service/util/util_check_list.dart';
import '../../service/util/util_snackbar.dart';
import '../dialog/dialog_delete_site_or_team.dart';
import '../item/item_calendar.dart';
import '../item/item_notice_big.dart';

enum ViewAnalyticsType {
  calendar,
  chart,
}

class RouteCheckListDetail extends StatefulWidget {
  const RouteCheckListDetail({Key? key}) : super(key: key);

  @override
  State<RouteCheckListDetail> createState() => _RouteCheckListDetailState();
}

class _RouteCheckListDetailState extends State<RouteCheckListDetail> {
  late Completer<bool> completerModelCheckList;
  ModelCheckList? modelCheckList;
  late ProviderUserCheckHistoryOnCheckList providerUserCheckHistory;

  ValueNotifier<ViewAnalyticsType> valueNotifierViewAnalyticsType = ValueNotifier(ViewAnalyticsType.calendar);
  final ScrollController scrollControllerChart = ScrollController();

  //공지사항 관련
  late ProviderNotice providerNotice;

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
    providerNotice = ProviderNotice(modelCheckList!.modelSite, modelCheckListTarget: modelCheckList!);
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
                  ChangeNotifierProvider.value(value: providerNotice),
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
                              child: const Icon(
                                Icons.qr_code,
                                size: 36,
                              )
                              /*SizedBox(
                                width: 50,
                                height: 50,
                                child: SfBarcodeGenerator(
                                  value:
                                      '$urlBaseAppLink$keyRouteCheckListDetail/${modelCheckList!.docId}/$keyRouteCheckListCheckWithOutSlash',
                                  symbology: QRCode(),
                                  showValue: false,
                                ),
                              )*/
                              ,
                            ),
                            const SizedBox(
                              width: 10,
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
                                style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),

                            ///달력, 그래프 선택하는 영역
                            ValueListenableBuilder(
                              valueListenable: valueNotifierViewAnalyticsType,
                              builder: (context, value, child) => Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                      onTap: () {
                                        valueNotifierViewAnalyticsType.value = ViewAnalyticsType.calendar;
                                      },
                                      child: Text(
                                        '달력',
                                        style: btnTxtStyle.copyWith(
                                            fontSize: value == ViewAnalyticsType.calendar ? 17 : 15,
                                            color: value == ViewAnalyticsType.calendar ? Colors.black : Colors.black45),
                                      )),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      valueNotifierViewAnalyticsType.value = ViewAnalyticsType.chart;

                                      Future.delayed(const Duration(milliseconds: 100)).then((value) {
                                        scrollControllerChart.animateTo(scrollControllerChart.position.maxScrollExtent,
                                            duration: const Duration(milliseconds: 200), curve: Curves.linear);
                                      });
                                    },
                                    child: Text(
                                      '그래프',
                                      style: btnTxtStyle.copyWith(
                                          fontSize: value == ViewAnalyticsType.chart ? 17 : 15,
                                          color: value == ViewAnalyticsType.chart ? Colors.black : Colors.black45),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),

                            ///달력, 그래프 표시 영역
                            ValueListenableBuilder(
                              valueListenable: valueNotifierViewAnalyticsType,
                              builder: (context, value, child) => Builder(
                                builder: (context) => value == ViewAnalyticsType.calendar
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
                                                checkListId: modelCheckList!.docId,
                                                dateTime: day,
                                                modelDailyCheckHistory: value.getModelDailyCheckHistory(day),
                                                //listModelUserCheckHistory: value.getDailyUserCheckHistoryCount(day),
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
                                                checkListId: modelCheckList!.docId,
                                                dateTime: day,
                                                isToday: true,
                                                modelDailyCheckHistory: value.getModelDailyCheckHistory(day),
                                                //listModelUserCheckHistory: value.getDailyUserCheckHistoryCount(day),
                                              );
                                            },

                                            //조회 날짜 범위 밖 빌더
                                            disabledBuilder: (context, day, focusedDay) {
                                              return Container();
                                            },
                                          ),
                                        ),
                                      )
                                    : Consumer<ProviderUserCheckHistoryOnCheckList>(
                                        builder: (context, value, child) => SizedBox(
                                          height: 240,
                                          child: SingleChildScrollView(
                                            controller: scrollControllerChart,
                                            scrollDirection: Axis.horizontal,
                                            child: AspectRatio(
                                              aspectRatio: 10 / 2,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 10),
                                                child: BarChart(
                                                  getLineChartData(value.listModelDailyCheckHistory),
                                                ),
                                              ),
                                            ),
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
                              ),
                            ),
                          ],
                        ),
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
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      '최근 인증 근무자',
                                      style: CustomTextStyle.bigBlackBold(),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.orange, // Background color
                                      ),
                                      onPressed: () {
                                        Get.toNamed('$keyRouteCheckListDetail'
                                            '/${modelCheckList!.docId}'
                                            '/$keyRouteCheckListRecentWithOutSlash');
                                      },
                                      child: const Text(
                                        '더보기',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ListView.builder(
                                itemCount: value.listModelUserCheckHistory.length,
                                itemBuilder: (context, index) => ItemUserCheckHistorySmall(
                                  value.listModelUserCheckHistory[index],
                                  modelCheckList: modelCheckList,
                                  //key: ValueKey('${value.listModelUserCheckHistory[index].docId}${DateTime.now().millisecondsSinceEpoch}'),
                                ),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                              )
                            ],
                          ),
                        ),
                      ),

                      ///공지사항 영역
                      Container(
                        width: Get.width,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        color: Colors.white,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ///공지 사항
                                const Text(
                                  '공지사항',
                                  style: CustomTextStyle.bigBlackBold(),
                                ),

                                Visibility(
                                  visible: MyApp.providerUser.modelUser?.id == modelCheckList!.modelSite.master,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.orange, // Background color
                                    ),
                                    onPressed: () {
                                      Get.to(() => RouteNoticeNew(
                                          modelSite: modelCheckList!.modelSite, modelCheckList: modelCheckList));
                                    },
                                    child: const Text(
                                      '작성하기',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      ///공지사항 리스트
                      Consumer<ProviderNotice>(
                        builder: (context, value, child) => ListView.builder(
                          itemCount: value.listModelNotice.length,
                          itemBuilder: (context, index) => ItemNoticeSmall(value.listModelNotice[index]),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                        ),
                      ),

                      ///인증 세부 항목
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
                                modelCheck: modelCheckList!.listModelCheck[index],
                                itemCheckType: ItemCheckType.none,
                              ),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                            )
                          ],
                        ),
                      ),

                      ///근무지 삭제
                      InkWell(
                        onTap: () async {
                          var result = await Get.dialog(const DialogDeleteSiteOrTeam(DialogDeleteSiteOrTeamType.team));
                          if (result == true) {
                            await FirebaseFirestore.instance
                                .collection(keyCheckListS)
                                .doc(modelCheckList!.docId)
                                .delete();
                            Get.back();
                            showSnackBarOnRoute('팀을 삭제했어요.');
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                          width: double.infinity,
                          height: 50,
                          child: const Text(
                            '팀 삭제',
                            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
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
