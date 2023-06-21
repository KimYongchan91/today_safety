import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chaleno/chaleno.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:today_safety/const/model/model_location_weather.dart';
import 'package:today_safety/const/model/model_weather.dart';
import 'package:today_safety/const/value/router.dart';
import 'package:today_safety/const/value/value.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/service/provider/provider_user.dart';
import 'package:today_safety/ui/dialog/dialog_open_external_web_browser.dart';
import 'package:today_safety/ui/item/item_article.dart';
import 'package:today_safety/ui/route/route_scan_qr.dart';
import 'package:today_safety/ui/route/route_weather_detail.dart';
import 'package:today_safety/ui/route/route_webview.dart';
import 'package:today_safety/ui/route/test/route_test.dart';
import 'package:today_safety/ui/item/item_banner.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

import '../../const/model/model_article.dart';
import '../../const/value/color.dart';
import '../../const/value/key.dart';
import '../../my_app.dart';
import '../../service/util/util_location.dart';
import '../../service/util/util_permission.dart';

class RouteMain extends StatefulWidget {
  const RouteMain({Key? key}) : super(key: key);

  @override
  State<RouteMain> createState() => _RouteMainState();
}

class _RouteMainState extends State<RouteMain> with SingleTickerProviderStateMixin {
  ValueNotifier<ModelWeather?> valueNotifierWeather = ValueNotifier(null);
  late AnimationController controllerRefreshWeather;

  //사건 사고 기사
  ValueNotifier<List<ModelArticle>?> valueNotifierListModelArticle = ValueNotifier(null);

  @override
  void initState() {
    controllerRefreshWeather = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    ///날씨 자동 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshWeather();
      getArticle();
    });

    super.initState();
  }

  @override
  void dispose() {
    controllerRefreshWeather.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackground,
      body: SafeArea(
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: MyApp.providerUser),
          ],
          builder: (context, child) => SingleChildScrollView(
            child: Column(children: [
              ///앱바
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width,
                height: 65,
                color: Colors.white,
                child: Row(
                  children: [
                    ///아이콘
                    InkWell(
                      onTap: () {
                        Get.to(() => const RouteTest());
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade700,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.helmetSafety,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      '오늘안전',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),

                    const Spacer(),

                    ///qr 코드 인식 페이지
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: InkWell(
                        onTap: () async {
                          bool isPermissionGranted = await requestPermission(Permission.camera);
                          if (isPermissionGranted == false) {
                            return;
                          }

                          Get.to(() => const RouteScanQr());
                        },
                        child: const FaIcon(
                          FontAwesomeIcons.qrcode,
                          size: 18,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 5,
                    ),

                    ///테스트 인증 페이지
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: InkWell(
                        onTap: () {
                          Get.toNamed(
                              '$keyRouteCheckListDetail/Y7eoaYJLn5v1YvolI0xW/$keyRouteCheckListCheckWithOutSlash',
                              arguments: {keyUrl: 'test'});
                        },
                        child: const FaIcon(
                          FontAwesomeIcons.camera,
                          size: 18,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 5,
                    ),

                    ///로그인페이지
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: InkWell(
                        onTap: () {
                          Get.toNamed(keyRouteLogin);
                        },
                        child: const FaIcon(
                          FontAwesomeIcons.user,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              ///앱바 구분선
              Container(
                width: MediaQuery.of(context).size.width,
                height: 0.5,
                color: Colors.black45,
              ),

              const Text(
                '최근 사망 사고 기사',
                style: CustomTextStyle.bigBlackBold(),
              ),
              const Text(
                '한국산업안전보건공단 제공',
                style: CustomTextStyle.normalGrey(),
              ),

              ///사건 사고 기사
              ValueListenableBuilder(
                valueListenable: valueNotifierListModelArticle,
                builder: (context, value, child) => value != null

                    ///기사가 로딩되었을 때
                    ? ListView.builder(
                        itemCount: min(value.length, 100), //최대 5개
                        itemBuilder: (context, index) => ItemArticle(value[index]),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                      )

                    ///기사 로딩 중
                    : LoadingAnimationWidget.inkDrop(color: Colors.green, size: 32),
              ),

              ///로그인 정보 영역
              /* Consumer<ProviderUser>(
                builder: (context, value, child) => value.modelUser == null

                    ///로그인 정보 없을때
                    ? const SizedBox()

                    ///로그인 중일때
                    : Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width,
                        child: Row(children: [
                          const FaIcon(
                            FontAwesomeIcons.solidUserCircle,
                            color: Colors.grey,
                            size: 40,
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Consumer<ProviderUser>(
                            builder: (context, value, child) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ///이름
                                Text(
                                  value.modelUser?.name ?? "이름",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),

                                ///아이디
                                Text(
                                  value.modelUser?.idExceptLT ?? '로그인을 해주세요.',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),
              ),*/

              ///날씨 정보 영역
              ValueListenableBuilder(
                valueListenable: valueNotifierWeather,
                builder: (context, value, child) => InkWell(
                  onTap: () async {
                    if (value != null) {
                      String urlBase =
                          'https://m.search.naver.com/search.naver?sm=mtp_hty.top&where=m&query=';
                      String query =
                          '${value.modelLocationWeather.si} ${value.modelLocationWeather.gu} ${value.modelLocationWeather.dong} 날씨';

                      Get.to(() => RouteWebView(urlBase + query));

                      //Get.to(() => RouteWeatherDetail(value));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.white,
                    width: Get.width,
                    height: 240,
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            '날씨',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        Row(
                          children: [
                            ///날씨 아이콘
                            value != null
                                ? Icon(
                                    value.getIcon(),
                                    size: 60,
                                  )
                                : Container(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    ///날씨 정보 받아온 시간
                                    value != null
                                        ? Text(
                                            value.getTime(),
                                            style: const TextStyle(
                                                color: Colors.black45, fontWeight: FontWeight.w700),
                                          )
                                        : Container(),

                                    ///날씨 새로고침 아이콘
                                    InkWell(
                                      onTap: () {
                                        refreshWeather(refreshForce: true);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: RotationTransition(
                                          turns:
                                              Tween(begin: 0.0, end: 1.0).animate(controllerRefreshWeather),
                                          child: const Icon(Icons.refresh),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                ///날씨 온도
                                value != null
                                    ? Text(
                                        '${value.t1h.toString()}°',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
                                      )
                                    : Container(),

                                const SizedBox(
                                  height: 5,
                                ),

                                ///날씨 온도
                                value != null
                                    ? Text(
                                        '강수량 ${value.rn1.toString()}mm/h',
                                        style: const CustomTextStyle.normalBlackBold(),
                                      )
                                    : Container(),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        value != null
                            ? Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  '${value.modelLocationWeather.gu} ${value.modelLocationWeather.dong}',
                                  style: const TextStyle(color: Colors.black45, fontWeight: FontWeight.w700),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ),

              //const Spacer(),
              //const ItemMainBanner(),
            ]),
          ),
        ),
      ),
    );
  }

  refreshWeather({bool refreshForce = false}) async {
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
        MyApp.logger.d("위치 조회 성공 : ${position.latitude}, ${position.longitude}");
        latLng = LatLng(position.latitude, position.longitude);
      } on Exception catch (e) {
        MyApp.logger.wtf("위치 조회 실패 : ${e.toString()}");
      }
    }

    MyApp.logger.d("주소 받아오는 데 걸린 시간 : ${DateTime.now().millisecondsSinceEpoch - time}ms");
    time = dateTimeNow.millisecondsSinceEpoch;

    //행정 구역 코드 받아오기
    ModelLocationWeather? modelLocationWeather;
    try {
      modelLocationWeather = await getModelLocationWeatherFromLatLng(latLng.latitude, latLng.longitude);
    } on Exception catch (e) {
      MyApp.logger.wtf("행정 구역 코드 조회 실패 : ${e.toString()}");
    }

    if (modelLocationWeather == null) {
      controllerRefreshWeather.reset();
      return;
    }
    //MyApp.logger.d("카카오에서 행정구역 코드 받아옴 : ${modelLocationWeather.code}");

    //MyApp.logger.d("행정 구역 코드 받아오는 데 걸린 시간 : ${DateTime.now().millisecondsSinceEpoch-time}ms");
    time = dateTimeNow.millisecondsSinceEpoch;

    //행정 구역 코드를 이용해 CSV 파일에서 x, y좌표 구해오기.
    int? codeX;
    int? codeY;

    try {
      final rawData = await rootBundle.loadString("assets/datas/address_code_simple.csv");
      //MyApp.logger.d("rawData : ${rawData}");
      List<String> listDataPerLine = rawData.split('\n');

      //List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);

      //MyApp.logger.d("파일 읽은 결과 : ${listDataPerLine[0].toString()}");
      //MyApp.logger.d('data 타입 : ${listData[0].runtimeType.toString()}');
      //MyApp.logger.d('0 타입 : ${listData[0][0].runtimeType.toString()}');

      int codeH = int.parse(modelLocationWeather.code);
      for (String data in listDataPerLine) {
        if (data.substring(0, 10) == '$codeH') {
          codeX = int.parse(data.split(',')[1]);
          codeY = int.parse(data.split(',')[2]);
          listDataPerLine.clear();
          break;
        }
      }
    } catch (e) {
      MyApp.logger.wtf("CSV 파일에서 행정 구역 코드 조회 실패 : ${e.toString()}");
      controllerRefreshWeather.reset();
    }

    if (codeX == null || codeY == null) {
      MyApp.logger.wtf("CSV 파일에서 행정 구역 코드 찾을 수 없음");
      controllerRefreshWeather.reset();
      return;
    }

    //MyApp.logger.d("CSV에서 x, y값 받아오는 데 걸린 시간 : ${DateTime.now().millisecondsSinceEpoch-time}ms");
    time = dateTimeNow.millisecondsSinceEpoch;

    //MyApp.logger.d("찾은 결과 $codeX, $codeY");

    String urlBase = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst';
    String keyService =
        '%2B%2BaANJW%2BGmM22jn4uU%2FTCiFfH58TiKg9euCqOwFAm%2FHNtf4K%2FlQ6zPxgMmXiuj7pPzt2LMOhS5yQBBFhm5IUrA%3D%3D';

    String baseTimeFormatted;
    //1시간 전
    int hourCurrent = DateTime.fromMillisecondsSinceEpoch(
            dateTimeNow.millisecondsSinceEpoch - millisecondHour * (dateTimeNow.minute < 15 ? 1 : 0))
        .hour;
    baseTimeFormatted = '$hourCurrent'.padLeft(2, '0');
/*    if (hourCurrent < 3) {
      baseTimeFormatted = "00";
    } else if (hourCurrent < 6) {
      baseTimeFormatted = "03";
    } else if (hourCurrent < 9) {
      baseTimeFormatted = "06";
    } else if (hourCurrent < 12) {
      baseTimeFormatted = "09";
    } else if (hourCurrent < 15) {
      baseTimeFormatted = "12";
    } else if (hourCurrent < 18) {
      baseTimeFormatted = "15";
    } else if (hourCurrent < 21) {
      baseTimeFormatted = "18";
    } else {
      baseTimeFormatted = "21";
    }*/

    baseTimeFormatted += "00";

    String baseDateFormatted = DateFormat('yyyyMMdd').format(dateTimeNow);
    String url = "$urlBase?serviceKey=$keyService"
        "&pageNo=1"
        "&numOfRows=10&dataType=JSON"
        "&base_date=$baseDateFormatted"
        "&base_time=$baseTimeFormatted"
        "&nx=$codeX"
        "&ny=$codeY";

    MyApp.logger.d('url : $url ');

    try {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };
      var response =
          await http.get(Uri.parse(url), headers: requestHeaders).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        throw Exception("Request to $url failed with status ${response.statusCode}: ${response.body}");
      } else {
        //성공
        //MyApp.logger.d(response.body.toString());
        List<dynamic> listMapAddressData =
            jsonDecode(response.body)['response']?['body']?['items']?['item'] ?? [];

        //T1H : 기온(c)
        //RN1 : 강수량(mm/1h)
        //REH : 습도 (%)
        //VEC : 풍향 (deg)
        //WSD : 풍속 (m/s)
        //PTY : 강수 형태 (안 옴(0), 비(1), 비/눈(2), 눈(3), 소나기(4), 빗방울(5), 빗방울/눈날림(6), 눈날림(7))
        //UUU : 동서 바람 성분 (m/s)
        //VVV : 남북 바람 성분 (m/s)

        if (listMapAddressData.isEmpty) {
          throw Exception('list weather is empty');
        }

        ModelWeather modelWeather = ModelWeather(
          baseDate: baseDateFormatted,
          baseTime: baseTimeFormatted,
          modelLocationWeather: modelLocationWeather,
        );
        for (dynamic weather in listMapAddressData) {
          if (weather is Map && weather['category'] != null && weather['obsrValue'] != null) {
            var value = weather['obsrValue'];
            num valueParsed = 0;
            try {
              valueParsed = num.parse(value);
            } catch (e) {
              MyApp.logger.wtf('num.parse 실패 : ${e.toString()}');
            }

            switch (weather['category']) {
              case 'PTY':
                modelWeather.pty = valueParsed.toInt();
                break;
              case 'REH':
                modelWeather.reh = valueParsed.toInt();
                break;
              case 'RN1':
                modelWeather.rn1 = valueParsed.toInt();
                break;
              case 'T1H':
                modelWeather.t1h = valueParsed.toInt();
                break;
              case 'UUU':
                modelWeather.uuu = valueParsed.toDouble();
                break;
              case 'VEC':
                modelWeather.vec = valueParsed.toInt();
                break;
              case 'VVV':
                modelWeather.vvv = valueParsed.toDouble();
                break;
              case 'WSD':
                modelWeather.wsd = valueParsed.toDouble();
                break;
              default:
                break;
            }
          }
        }
        //MyApp.logger.d('조회된 날씨 정보 : ${modelWeather.toString()}');
        valueNotifierWeather.value = modelWeather;

        //MyApp.logger.d("기상청에서 날씨 정보 받아오는 데 걸린 시간 : ${DateTime.now().millisecondsSinceEpoch-time}ms");
        time = DateTime.now().millisecondsSinceEpoch;

        controllerRefreshWeather.reset();
      }
    } on Exception catch (e) {
      controllerRefreshWeather.reset();
      MyApp.logger.wtf("날씨 api 요청 실패 : ${e.toString()}");
      return null;
    }
  }

  getArticle() async {
    print('getArticle() 시작');
    List<ModelArticle> listModelArticleNew = [];

    final chaleno = await Chaleno().load('https://www.kosha.or.kr/kosha/index.do');

    List<Result> results = chaleno?.querySelectorAll('.example1 ul li .articleTitle') ?? [];
    print('크롤 결과 : ${results.length}');
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
        String? region =
            regExpRegion.stringMatch(innerHtmlFormatted)?.replaceAll(']', '').replaceAll(',', '').trim();
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
}

///로그인 안됐을때
class UnLoginUserArea extends StatefulWidget {
  const UnLoginUserArea({Key? key}) : super(key: key);

  @override
  State<UnLoginUserArea> createState() => _UnLoginUserAreaState();
}

class _UnLoginUserAreaState extends State<UnLoginUserArea> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.lock,
              size: 50,
              color: Colors.grey,
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              '로그인 후 이용가능한 서비스입니다.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '로그인을 해주세요.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
