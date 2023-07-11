import 'dart:async';
import 'dart:convert';

import 'package:chaleno/chaleno.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:today_safety/const/value/color.dart';
import 'package:today_safety/service/provider/provider_user.dart';
import 'package:today_safety/service/util/util_campaign_list.dart';
import 'package:today_safety/ui/item/item_notice_big.dart';

import '../../const/model/model_article.dart';
import '../../const/model/model_emergency_sms.dart';
import '../../const/model/model_weather.dart';
import '../../const/value/value.dart';
import '../../custom/custom_text_style.dart';
import '../../custom/custom_value_listenable_builder2.dart';
import '../../my_app.dart';
import '../../service/util/util_address.dart';
import '../../service/util/util_permission.dart';
import '../../service/util/util_weather.dart';
import '../item/item_article.dart';
import '../item/item_banner.dart';
import '../item/item_emergency_sms.dart';
import '../item/item_main_link.dart';
import '../widget/widget_app_bar.dart';
import '../widget/widget_weather.dart';

class ScreenMainInfo extends StatefulWidget {
  const ScreenMainInfo({Key? key}) : super(key: key);

  @override
  State<ScreenMainInfo> createState() => _ScreenMainInfoState();
}

class _ScreenMainInfoState extends State<ScreenMainInfo> with SingleTickerProviderStateMixin {
  //날씨
  ValueNotifier<ModelWeather?> valueNotifierWeather = ValueNotifier(null);
  late AnimationController controllerRefreshWeather;
  late Completer completerRefreshWeather;

  //사건 사고 기사
  ValueNotifier<List<ModelArticle>?> valueNotifierListModelArticle = ValueNotifier(null);

  //재난 문자
  ValueNotifier<List<ModelEmergencySms>?> valueNotifierListModelEmergencySmsDisaster = ValueNotifier(null); //재난
  ValueNotifier<List<ModelEmergencySms>?> valueNotifierListModelEmergencySmsMissing = ValueNotifier(null); //실종

  //기사, 재난문자 page 관련
  Timer? timer;
  final PageController controllerArticle = PageController(initialPage: 0);
  final PageController controllerEmergencySmsDisaster = PageController(initialPage: 0);
  final PageController controllerEmergencySmsMissing = PageController(initialPage: 0);
  final ValueNotifier<int> valueNotifierPageArticle = ValueNotifier(0);
  final ValueNotifier<int> valueNotifierPageEmergencySmsDisaster = ValueNotifier(0);
  final ValueNotifier<int> valueNotifierPageEmergencySmsMissing = ValueNotifier(0);

  @override
  void initState() {
    controllerRefreshWeather = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    completerRefreshWeather = Completer();

    ///날씨 자동 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshWeather();
      getArticle();
      getEmergencySMS();
    });

    timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      //기사
      if (valueNotifierListModelArticle.value != null && controllerArticle.page != null) {
        int currentPage = controllerArticle.page!.toInt();
        int nextPage = currentPage + 1;
        if (nextPage <= valueNotifierListModelArticle.value!.length - 1) {
          controllerArticle.animateToPage(nextPage, duration: const Duration(seconds: 2), curve: Curves.decelerate);
        } else {
          controllerArticle.animateToPage(0, duration: const Duration(seconds: 2), curve: Curves.decelerate);
        }
      }

      //재난 문자(재난)
      if (valueNotifierListModelEmergencySmsDisaster.value != null && controllerEmergencySmsDisaster.page != null) {
        int currentPage = controllerEmergencySmsDisaster.page!.toInt();
        int nextPage = currentPage + 1;
        if (nextPage <= valueNotifierListModelEmergencySmsDisaster.value!.length - 1) {
          controllerEmergencySmsDisaster.animateToPage(nextPage,
              duration: const Duration(seconds: 2), curve: Curves.decelerate);
        } else {
          controllerEmergencySmsDisaster.animateToPage(0,
              duration: const Duration(seconds: 2), curve: Curves.decelerate);
        }
      }

      //재난 문자(실종)
      /*if (valueNotifierListModelEmergencySmsMissing.value != null && controllerEmergencySmsMissing.page != null) {
        int currentPage = controllerEmergencySmsMissing.page!.toInt();
        int nextPage = currentPage + 1;
        if (nextPage <= valueNotifierListModelEmergencySmsMissing.value!.length - 1) {
          controllerEmergencySmsMissing.animateToPage(nextPage,
              duration: const Duration(seconds: 2), curve: Curves.decelerate);
        } else {
          controllerEmergencySmsMissing.animateToPage(0,
              duration: const Duration(seconds: 2), curve: Curves.decelerate);
        }
      }*/
    });

    super.initState();
  }

  @override
  void dispose() {
    controllerRefreshWeather.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ///앱바 영역
          WidgetAppBar(),

          Consumer<ProviderUser>(builder: (context, value, child) => ItemNoticeBig(value.modelNotice)),

          ///날씨 정보 영역
          ValueListenableBuilder(
            valueListenable: valueNotifierWeather,
            builder: (context, value, child) => WidgetWeather(
              modelWeather: value,
              onRefreshWeather: () {
                _refreshWeather(refreshForce: true);
              },
              controllerRefreshWeather: controllerRefreshWeather,
              key: UniqueKey(),
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          // UtilCampaignList(),

          Container(
            color: Colors.white,
            width: Get.width,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        '사망 사고 기사',
                        style: CustomTextStyle.bigBlackBold(),
                      ),

                      const SizedBox(
                        width: 20,
                      ),
                      const Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          '한국산업안전보건공단 제공',
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Spacer(),

                      ///페이지 번호 표시 부분
                      CustomValueListenableBuilder2(
                        a: valueNotifierListModelArticle,
                        b: valueNotifierPageArticle,
                        builder: (context, a, b, child) => a != null ? Text('${b + 1}/${a.length}') : Container(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                ///사건 사고 기사
                ValueListenableBuilder(
                  valueListenable: valueNotifierListModelArticle,
                  builder: (context, value, child) => value != null

                      ///기사가 로딩되었을 때
                      ? SizedBox(
                          width: Get.width,
                          height: 80,
                          child: Row(
                            children: [
                              Expanded(
                                child: PageView.builder(
                                  controller: controllerArticle,
                                  itemCount: value.length,
                                  itemBuilder: (context, index) {
                                    return ItemArticle(value[index]);
                                  },
                                  onPageChanged: (value) {
                                    valueNotifierPageArticle.value = value;
                                  },
                                ),
                              ),

                              /*  InkWell(
                                        onTap: () {},
                                        child: const FaIcon(FontAwesomeIcons.angleRight),
                                      )*/
                            ],
                          ),
                        )
                      /*
                    ListView.builder(
                            itemCount: min(value.length, 5), //최대 5개
                            itemBuilder: (context, index) => ItemArticle(value[index]),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                          )
                    */

                      ///기사 로딩 중
                      : LoadingAnimationWidget.inkDrop(color: Colors.green, size: 32),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            width: Get.width,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      const Text(
                        '긴급 재난 문자',
                        style: CustomTextStyle.bigBlackBold(),
                      ),
                      const Spacer(),

                      ///페이지 번호 표시 부분
                      CustomValueListenableBuilder2(
                        a: valueNotifierListModelEmergencySmsDisaster,
                        b: valueNotifierPageEmergencySmsDisaster,
                        builder: (context, a, b, child) =>
                            a != null && a.isNotEmpty ? Text('${b + 1}/${a.length}') : Container(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                ///재난 문자 (재난 관련)
                ValueListenableBuilder(
                  valueListenable: valueNotifierListModelEmergencySmsDisaster,
                  builder: (context, value, child) => value != null

                      ///데이터가 로딩되었을 때
                      ? SizedBox(
                          width: Get.width,
                          height: 80,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: PageView.builder(
                                  controller: controllerEmergencySmsDisaster,
                                  itemCount: value.length,
                                  itemBuilder: (context, index) {
                                    return ItemEmergencySms(value[index]);
                                  },
                                  onPageChanged: (value) {
                                    valueNotifierPageEmergencySmsDisaster.value = value;
                                  },
                                ),
                              ),

                              /*
                                      ListView.builder(
                                        itemCount: min(value.length, 5), //최대 5개
                                        itemBuilder: (context, index) => ItemEmergencySms(value[index]),
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                      ),*/
                            ],
                          ),
                        )

                      ///데이터 로딩 중
                      : LoadingAnimationWidget.inkDrop(color: Colors.green, size: 32),
                ),
              ],
            ),
          ),

          /*
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
            width: Get.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '실종자 찾기',
                      style: CustomTextStyle.bigBlackBold(),
                    ),
                    const Spacer(),

                    ///페이지 번호 표시 부분
                    CustomValueListenableBuilder2(
                      a: valueNotifierListModelEmergencySmsMissing,
                      b: valueNotifierPageEmergencySmsMissing,
                      builder: (context, a, b, child) =>
                      a != null && a.isNotEmpty ? Text('${b + 1}/${a.length}') : Container(),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 20,
                ),

                ///재난 문자 (실종 관련)
                SizedBox(
                  width: Get.width,
                  height: 80,
                  child: Row(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: valueNotifierListModelEmergencySmsMissing,
                        builder: (context, value, child) => value != null

                        ///데이터가 로딩되었을 때
                            ? Expanded(
                          child: PageView.builder(
                            itemCount: value.length,
                            controller: controllerEmergencySmsMissing,
                            itemBuilder: (context, index) {
                              return ItemEmergencySms(value[index]);
                            },
                            onPageChanged: (value) {
                              valueNotifierPageEmergencySmsMissing.value = value;
                            },
                          ),
                        )

                        /*
                                ListView.builder(
                                  itemCount: min(value.length, 5), //최대 5개
                                  itemBuilder: (context, index) => ItemEmergencySms(value[index]),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                )
*/

                        ///데이터 로딩 중
                            : LoadingAnimationWidget.inkDrop(color: Colors.green, size: 32),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

*/

          const SizedBox(
            height: 20,
          ),

          //const ItemMainBanner(),
          const ItemMainLink(),

          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  _refreshWeather({bool refreshForce = false}) async {
    if (controllerRefreshWeather.isAnimating) {
      MyApp.logger.d("이미 실행 중");
      return;
    }

    controllerRefreshWeather.repeat();
    final DateTime dateTimeNow = DateTime.now();
    int time = dateTimeNow.millisecondsSinceEpoch;

    //현재 위치 권한 있는지?
    bool isPermissionGranted;
    PermissionStatus permissionStatus = await Permission.locationWhenInUse.status;

    if (permissionStatus == PermissionStatus.granted || permissionStatus == PermissionStatus.limited) {
      isPermissionGranted = true;
    } else {
      isPermissionGranted = false;
    }

    //강제로 새로고침 하는지
    //즉 위치 권한을 요청 하는지
    if (refreshForce) {
      isPermissionGranted = await requestPermission(Permission.locationWhenInUse);
    }

    //기본 위치값 = 서울 시청
    LatLng latLng = LatLng(37.566, 126.978);

    //최종적으로 위치 권한이 있다면
    //실시간 위치 확인
    if (isPermissionGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
        //MyApp.logger.d("위치 조회 성공 : ${position.latitude}, ${position.longitude}");
        latLng = LatLng(position.latitude, position.longitude);
      } on Exception catch (e) {
        MyApp.logger.wtf("위치 조회 실패 : ${e.toString()}");
      }
    }

    MyApp.logger.d("주소 받아오는 데 걸린 시간 : ${DateTime.now().millisecondsSinceEpoch - time}ms");
    time = dateTimeNow.millisecondsSinceEpoch;

    ModelWeather? modelWeather = await getWeatherFromLatLng(latLng.latitude, latLng.longitude).then((value) {
      if (completerRefreshWeather.isCompleted == false) {
        completerRefreshWeather.complete();
      }
      return value;
    });
    MyApp.logger.d('조회된 날씨 정보 : ${modelWeather.toString()}');

    //MyApp.logger.d("기상청에서 날씨 정보 받아오는 데 걸린 시간 : ${DateTime.now().millisecondsSinceEpoch-time}ms");
    //time = DateTime.now().millisecondsSinceEpoch;

    valueNotifierWeather.value = modelWeather;

    controllerRefreshWeather.reset();
  }

  getArticle() async {
    //print('getArticle() 시작');
    List<ModelArticle> listModelArticleNew = [];

    final chaleno = await Chaleno().load('https://www.kosha.or.kr/kosha/index.do');

    List<Result> results = chaleno?.querySelectorAll('.example1 ul li .articleTitle') ?? [];
    //print('크롤 결과 : ${results.length}');
    RegExp regExpDate = RegExp(r'^\[[0-9]\/[0-9]*\,');
    RegExp regExpRegion = RegExp(r',[ 가-힣]*\]');

    for (var element in results) {
      String innerHtmlFormatted = element.innerHTML?.trim() ?? '';
      if (innerHtmlFormatted.contains('[') == true) {
        innerHtmlFormatted = innerHtmlFormatted.substring(innerHtmlFormatted.indexOf('['));
      } else {
        continue;
      }

      //print('###${element.href} $innerHtmlFormatted###');

      if (element.href == null || innerHtmlFormatted.isEmpty) {
        continue;
      }

      //정규표현식 적용
      try {
        String? href = element.href;
        String? date = regExpDate.stringMatch(innerHtmlFormatted)?.replaceAll('[', '').replaceAll(',', '');
        String? region = regExpRegion.stringMatch(innerHtmlFormatted)?.replaceAll(']', '').replaceAll(',', '').trim();
        String? title = innerHtmlFormatted.substring(innerHtmlFormatted.indexOf(']') + 1).trim();

        //https://www.kosha.or.kr/kosha/report/kosha_news.do?mode=view&articleNo=442620

        String hrefBase = 'https://www.kosha.or.kr';

        if (href == null || date == null || region == null) {
          throw Exception('href == null || date == null || region == null');
        }

        /*   MyApp.logger.d("정규 표현식 결과\n"
            "href : $href\n"
            "date : $date\n"
            "region : $region\n"
            "title : $title\n");*/

        int month = int.parse(date.split("/")[0]);
        int day = int.parse(date.split("/")[1]);

        listModelArticleNew.add(ModelArticle(
          dateTime: DateTime(DateTime.now().year, month, day),
          region: region,
          href: (hrefBase + href).replaceAll('&amp;', '&'),
          title: title,
        ));
      } catch (e) {
        MyApp.logger.wtf('정규 표현식 에러 : ${e.toString()}');
      }
    }

    listModelArticleNew.sort(
      (a, b) => b.dateTime.millisecondsSinceEpoch.compareTo(a.dateTime.millisecondsSinceEpoch),
    );

    valueNotifierListModelArticle.value = listModelArticleNew;
  }

  getEmergencySMS() async {
    final DateTime dateTimeNow = DateTime.now();

    String urlBase = 'http://apis.data.go.kr/1741000/DisasterMsg3/getDisasterMsg1List';
    String keyService =
        '%2B%2BaANJW%2BGmM22jn4uU%2FTCiFfH58TiKg9euCqOwFAm%2FHNtf4K%2FlQ6zPxgMmXiuj7pPzt2LMOhS5yQBBFhm5IUrA%3D%3D';

    String url = "$urlBase?serviceKey=$keyService"
        "&type=json"
        "&pageNo=1"
        "&numOfRows=100";

    //MyApp.logger.d('url : $url ');

    try {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };
/*      Uri uri =  Uri.http('apis.data.go.kr','/1741000/DisasterMsg3/getDisasterMsg1List',{
        'serviceKey' : keyService,
        'type' : 'json',
        'pageNo' : '1',
        'numOfRows' : '20',
      });

      MyApp.logger.d("uri : ${uri.toString()}");
*/
      var response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception("Request to $url failed with status ${response.statusCode}: ${response.body}");
      } else {
        //성공
        //MyApp.logger.d(response.body.toString());

        List<ModelEmergencySms> listModelEmergencySmsDisasterNew = [];
        List<ModelEmergencySms> listModelEmergencySmsMissingNew = [];
        List<String> listKeyWordMissing = ['실종', '찾습니다'];

        DateFormat dateFormat = DateFormat('yyyy/MM/dd hh:mm:ss');

        List<dynamic> listEmergencySmsDataContainer = jsonDecode(response.body)['DisasterMsg'] ?? [];
        if (listEmergencySmsDataContainer.isNotEmpty &&
            listEmergencySmsDataContainer.length >= 2 &&
            listEmergencySmsDataContainer[1]['row'] != null) {
          List<dynamic> listEmergencySmsData = listEmergencySmsDataContainer[1]['row'];

          for (var element in listEmergencySmsData) {
            try {
              String locationName = formatAddressSi(element['location_name'] ?? '');

              bool isNearRegion = false;
              if (completerRefreshWeather.isCompleted && valueNotifierWeather.value != null) {
                if (locationName.contains(valueNotifierWeather.value!.modelLocation.si) == true) {
                  if (valueNotifierWeather.value!.modelLocation.lat == defaultLat &&
                      valueNotifierWeather.value!.modelLocation.lng == defaultLng) {
                    //기본지역 이라면
                  } else {
                    //기본지역이 아니라면
                    isNearRegion = true;
                  }
                }
              }

              ModelEmergencySms modelEmergencySms = ModelEmergencySms(
                dateTime: dateFormat.parse(element['create_date']),
                //DateTime.parse(element['create_date']),
                id: element['md101_sn'] ?? '',
                locationId: element['location_id'] ?? '',
                locationName: locationName,
                msg: element['msg'] ?? '',
                isNearRegion: isNearRegion,
              );

              bool isContainMissingKeyword = false;
              for (var element in listKeyWordMissing) {
                if (modelEmergencySms.msg.contains(element)) {
                  isContainMissingKeyword = true;
                  break;
                }
              }

              if (isContainMissingKeyword) {
                listModelEmergencySmsMissingNew.add(modelEmergencySms);
              } else {
                if (dateTimeNow.millisecondsSinceEpoch - modelEmergencySms.dateTime.millisecondsSinceEpoch >
                    millisecondDay) {
                  continue;
                }
                listModelEmergencySmsDisasterNew.add(modelEmergencySms);
              }
            } catch (e) {
              MyApp.logger.wtf('재난문자 데이터 추가 실패 : ${e.toString()}');
            }
          }

          //MyApp.logger.d(
          //    "재난문자 응답 결과 개수. 재난 : ${listModelEmergencySmsDisasterNew.length}, 실종 : ${listModelEmergencySmsMissingNew.length}");

          valueNotifierListModelEmergencySmsDisaster.value = listModelEmergencySmsDisasterNew;
          valueNotifierListModelEmergencySmsMissing.value = listModelEmergencySmsMissingNew;

          //만약 아직 날씨를 받아오지 않았다면, 콜백 등록
          completerRefreshWeather.future.then((_) {
            if (valueNotifierWeather.value == null ||
                (valueNotifierWeather.value!.modelLocation.lat == defaultLat &&
                    valueNotifierWeather.value!.modelLocation.lng == defaultLng)) {
              return;
            }

            List<ModelEmergencySms> listModelEmergencySmsDisasterNew = [
              ...(valueNotifierListModelEmergencySmsDisaster.value ?? [])
            ];

            List<ModelEmergencySms> listModelEmergencySmsMissingNew = [
              ...(valueNotifierListModelEmergencySmsMissing.value ?? [])
            ];

            if (valueNotifierWeather.value == null) {
              return;
            }

            String si = valueNotifierWeather.value!.modelLocation.si;

            for (var element in listModelEmergencySmsDisasterNew) {
              if (element.locationName.contains(si) == true) {
                element.isNearRegion = true;
              }
            }

            for (var element in listModelEmergencySmsMissingNew) {
              if (element.locationName.contains(si) == true) {
                element.isNearRegion = true;
              }
            }

            valueNotifierListModelEmergencySmsDisaster.value = listModelEmergencySmsDisasterNew;
            valueNotifierListModelEmergencySmsMissing.value = listModelEmergencySmsMissingNew;
          });
        }
      }
    } catch (e) {
      MyApp.logger.wtf("재난 문자 api 요청 실패 : ${e.toString()}");
      valueNotifierListModelEmergencySmsDisaster.value = [];
      valueNotifierListModelEmergencySmsMissing.value = [];
    }
  }
}
