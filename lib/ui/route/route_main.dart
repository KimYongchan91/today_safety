import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

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
import 'package:provider/provider.dart';
import 'package:today_safety/const/model/model_emergency_sms.dart';
import 'package:today_safety/const/model/model_weather.dart';
import 'package:today_safety/const/value/router.dart';
import 'package:today_safety/const/value/value.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/custom/custom_value_listenable_builder2.dart';
import 'package:today_safety/service/util/util_address.dart';
import 'package:today_safety/service/util/util_weather.dart';
import 'package:today_safety/ui/item/item_article.dart';
import 'package:today_safety/ui/item/item_banner.dart';
import 'package:today_safety/ui/item/item_emergency_sms.dart';
import 'package:today_safety/ui/item/item_main_link.dart';
import 'package:today_safety/ui/route/route_qr_code_scan.dart';
import 'package:today_safety/ui/route/test/route_test.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show SystemNavigator, rootBundle;

import '../../const/model/model_article.dart';
import '../../const/value/color.dart';
import '../../const/value/key.dart';
import '../../my_app.dart';
import '../../service/provider/provider_user_check_history_on_me.dart';
import '../../service/util/util_permission.dart';
import '../item/item_user_check_history_big.dart';
import '../widget/widget_weather.dart';

const int _intervalTimeToNextArticle = 2;

class RouteMain extends StatefulWidget {
  const RouteMain({Key? key}) : super(key: key);

  @override
  State<RouteMain> createState() => _RouteMainState();
}

class _RouteMainState extends State<RouteMain> with SingleTickerProviderStateMixin {
  //날씨
  ValueNotifier<ModelWeather?> valueNotifierWeather = ValueNotifier(null);
  late AnimationController controllerRefreshWeather;
  late Completer completerRefreshWeather;

  //사건 사고 기사
  ValueNotifier<List<ModelArticle>?> valueNotifierListModelArticle = ValueNotifier(null);

  //재난 문자
  ValueNotifier<List<ModelEmergencySms>?> valueNotifierListModelEmergencySmsDisaster =
      ValueNotifier(null); //재난
  ValueNotifier<List<ModelEmergencySms>?> valueNotifierListModelEmergencySmsMissing =
      ValueNotifier(null); //실종

  //앱 종료 방지용
  int timeBackButtonPressed = 0;
  FToast fToast = FToast();

  //기사, 재난문자 page 관련
  Timer? timer;
  final PageController controllerArticle = PageController(initialPage: 0);
  final PageController controllerEmergencySmsDisaster = PageController(initialPage: 0);
  final PageController controllerEmergencySmsMissing = PageController(initialPage: 0);
  final ValueNotifier<int> valueNotifierPageArticle = ValueNotifier(0);
  final ValueNotifier<int> valueNotifierPageEmergencySmsDisaster = ValueNotifier(0);
  final ValueNotifier<int> valueNotifierPageEmergencySmsMissing = ValueNotifier(0);

  int weatherInt = 0;
  final List<String> weather = ['rain', 'heat', 'clean', 'thunder'];

  @override
  void initState() {
    controllerRefreshWeather = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    fToast.init(context);

    completerRefreshWeather = Completer();

    ///날씨 자동 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshWeather();
      getArticle();
      getEmergencySMS();
    });

    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      //기사
      if (valueNotifierListModelArticle.value != null && controllerArticle.page != null) {
        int currentPage = controllerArticle.page!.toInt();
        int nextPage = currentPage + 1;
        if (nextPage <= valueNotifierListModelArticle.value!.length - 1) {
          controllerArticle.animateToPage(nextPage,
              duration: const Duration(seconds: 2), curve: Curves.decelerate);
        } else {
          controllerArticle.animateToPage(0, duration: const Duration(seconds: 2), curve: Curves.decelerate);
        }
      }

      //재난 문자(재난)
      if (valueNotifierListModelEmergencySmsDisaster.value != null &&
          controllerEmergencySmsDisaster.page != null) {
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
      if (valueNotifierListModelEmergencySmsMissing.value != null &&
          controllerEmergencySmsMissing.page != null) {
        int currentPage = controllerEmergencySmsMissing.page!.toInt();
        int nextPage = currentPage + 1;
        if (nextPage <= valueNotifierListModelEmergencySmsMissing.value!.length - 1) {
          controllerEmergencySmsMissing.animateToPage(nextPage,
              duration: const Duration(seconds: 2), curve: Curves.decelerate);
        } else {
          controllerEmergencySmsMissing.animateToPage(0,
              duration: const Duration(seconds: 2), curve: Curves.decelerate);
        }
      }
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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: colorBackground,
        body: SafeArea(
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: MyApp.providerUser),
              ChangeNotifierProvider.value(value: MyApp.providerUserCheckHistoryOnMe)
            ],
            builder: (context, child) => SingleChildScrollView(
              child: Column(
                children: [
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

                              Get.to(() => const RouteQrCodeScan());
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
                  const SizedBox(
                    height: 10,
                  ),

                  const Text(
                    '내 안전 인증서',
                    style: CustomTextStyle.bigBlackBold(),
                  ),

                  ///내 인증서 영역
                  Container(
                    width: Get.width,
                    height: Get.height * 0.5,
                    decoration: BoxDecoration(color: Colors.grey),
                    child: Consumer<ProviderUserCheckHistoryOnMe>(
                      builder: (context, value, child) => value.modelUser != null

                          ///로그인 함
                          ? PageView.builder(
                              itemCount: value.listModelUserCheckHistory.length,
                              itemBuilder: (context, index) =>
                                  ItemUserCheckHistoryBig(value.listModelUserCheckHistory[index]),
                            )

                          ///로그인 하기 전
                          : Center(
                              child: Text('로그인을 해주세요.'),
                            ),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

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

                  Container(
                    color: Colors.white,
                    width: Get.width,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '최근 사망 사고 기사',
                              style: CustomTextStyle.bigBlackBold(),
                            ),
                            const Spacer(),

                            ///페이지 번호 표시 부분
                            CustomValueListenableBuilder2(
                              a: valueNotifierListModelArticle,
                              b: valueNotifierPageArticle,
                              builder: (context, a, b, child) =>
                                  a != null ? Text('${b + 1}/${a.length}') : Container(),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 10,
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
                                      const SizedBox(
                                        width: 20,
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

                        const Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            '한국산업안전보건공단 제공',
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    width: Get.width,
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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

                  const SizedBox(
                    height: 10,
                  ),

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

                  const SizedBox(
                    height: 10,
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                  const ItemMainLink(),

                  const ItemMainBanner()

                  //const Spacer(),
                  //const ItemMainBanner(),
                ],
              ),
            ),
          ),
        ),
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
    //MyApp.logger.d('조회된 날씨 정보 : ${modelWeather.toString()}');

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

  getEmergencySMS() async {
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
        MyApp.logger.d(response.body.toString());

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

  Future<bool> _onWillPop() async {
    if (Platform.isIOS) {
      return true;
    }

    int timeNow = DateTime.now().millisecondsSinceEpoch;

    if (timeNow - timeBackButtonPressed > 2000) {
      ///기존 토스트 날리기
      fToast.removeCustomToast();

      ///토스트 띄우기
      _showToast();

      timeBackButtonPressed = timeNow;

      return false;
    } else {
      SystemNavigator.pop();
      return false;
    }
  }

  _showToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.close),
          SizedBox(
            width: 12.0,
          ),
          Text("한 번 더 누르면 종료돼요."),
        ],
      ),
    );

    // Custom Toast Position
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }
}

///로그인 안됐을때
/*
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
*/
