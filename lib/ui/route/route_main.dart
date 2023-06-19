import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:today_safety/const/model/model_location_weather.dart';
import 'package:today_safety/const/value/router.dart';
import 'package:today_safety/service/provider/provider_user.dart';
import 'package:today_safety/ui/route/test/route_test.dart';
import 'package:today_safety/ui/item/item_banner.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

import '../../const/value/color.dart';
import '../../const/value/key.dart';
import '../../my_app.dart';
import '../../service/util/util_location.dart';

class RouteMain extends StatefulWidget {
  const RouteMain({Key? key}) : super(key: key);

  @override
  State<RouteMain> createState() => _RouteMainState();
}

class _RouteMainState extends State<RouteMain> {
  BoxDecoration mainButton = BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    color: Colors.white,
    border: Border.all(width: 2, color: Colors.black45),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackground,
      body: SafeArea(
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: MyApp.providerUser),
          ],
          builder: (context, child) => Center(
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

                    ///인증페이지
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

              ///로그인 정보 영역
              Consumer<ProviderUser>(
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
              ),

              ///근무지 정보 영역
              Consumer<ProviderUser>(
                builder: (context, value, child) => value.modelUser == null

                    ///로그인 안됐을때
                    ? const UnLoginUserArea()

                    ///로그인 상태일때
                    : Container(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(20),
                        width: MediaQuery.of(context).size.width,
                        child:

                            ///로그인이 된 후 근무지 작성 안했을때
                            value.modelSiteMy == null
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Expanded(
                                            child: Text(
                                              '나의 근무지를 등록하세요.',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Get.toNamed(
                                                keyRouteSiteSearch,
                                                arguments: {
                                                  //'keyword': 'sex',
                                                },
                                              );
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(5),
                                              child: FaIcon(FontAwesomeIcons.search),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(
                                        height: 40,
                                      ),

                                      ///근무지 만들기 버튼
                                      InkWell(
                                        onTap: () {
                                          Get.toNamed(
                                            keyRouteSiteNew,
                                            arguments: {
                                              //'keyword': 'sex',
                                            },
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          height: MediaQuery.of(context).size.height / 4,
                                          decoration: mainButton,
                                          child: const Expanded(
                                              child: Center(
                                                  child: FaIcon(
                                            FontAwesomeIcons.add,
                                            size: 35,
                                            color: Colors.black45,
                                          ))),
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            '근무지 만들기',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black45,
                                                fontSize: 16),
                                          ))
                                    ],
                                  )

                                ///로그인 되어있고, 내가 관리하는 근무지가 있을 때
                                : InkWell(
                                    onTap: goRouteSiteDetail,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '내가 관리하는 근무지',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                        ),

                                        const SizedBox(
                                          height: 30,
                                        ),

                                        ///이미지 영역
                                        Container(
                                          width: Get.width,
                                          height: Get.height / 4,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20),
                                              color: Colors.redAccent),
                                          child:
                                              //todo ldj 근무지 로고 이미지 부분 수정
                                              ///근무지 로고 이미지

                                              ClipRRect(
                                            borderRadius: BorderRadius.circular(20),
                                            child: CachedNetworkImage(
                                              imageUrl: value.modelSiteMy!.urlLogoImage,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(
                                          height: 20,
                                        ),

                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  ///근무지 이름
                                                  Text(
                                                    value.modelSiteMy!.name,
                                                    style: const TextStyle(
                                                        fontSize: 20, fontWeight: FontWeight.w800),
                                                  ),

                                                  const SizedBox(
                                                    height: 10,
                                                  ),

                                                  ///주소
                                                  const Row(
                                                    children: [
                                                      FaIcon(
                                                        FontAwesomeIcons.locationDot,
                                                        size: 16,
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text('서울시 은평구 불광동 32번 가길'),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.all(10),
                                              child: FaIcon(FontAwesomeIcons.angleRight),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                      ),
              ),

              ///날씨 정보 영역
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: refreshWeather,
                    child: Text('날씨 새로고침'),
                  ),
                ],
              ),
              const Spacer(),
              const ItemMainBanner(),
            ]),
          ),
        ),
      ),
    );
  }

  refreshWeather() async {
    int time = DateTime.now().millisecondsSinceEpoch;

    //현재 주소 받아오기
    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      MyApp.logger.d("위치 조회 성공 : ${position.latitude}, ${position.longitude}");
    } on Exception catch (e) {
      MyApp.logger.wtf("위치 조회 실패 : ${e.toString()}");
    }

    if (position == null) {
      return;
    }

    //MyApp.logger.d("주소 받아오는 데 걸린 시간 : ${DateTime.now().millisecondsSinceEpoch-time}ms");
    time = DateTime.now().millisecondsSinceEpoch;

    //행정 구역 코드 받아오기
    ModelLocationWeather? modelLocationWeather;
    try {
      modelLocationWeather = await getModelLocationWeatherFromLatLng(position.latitude, position.longitude);
    } on Exception catch (e) {
      MyApp.logger.wtf("행정 구역 코드 조회 실패 : ${e.toString()}");
    }

    if (modelLocationWeather == null) {
      return;
    }

    //MyApp.logger.d("행정 구역 코드 받아오는 데 걸린 시간 : ${DateTime.now().millisecondsSinceEpoch-time}ms");
    time = DateTime.now().millisecondsSinceEpoch;


    //행정 구역 코드를 이용해 CSV 파일에서 x, y좌표 구해오기.
    int? codeX;
    int? codeY;

    try {
      final rawData = await rootBundle.loadString("assets/datas/address_code_simple.csv");
      List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);

      //MyApp.logger.d("파일 읽은 결과 : ${listData[0].toString()}");
      //MyApp.logger.d('data 타입 : ${listData[0].runtimeType.toString()}');
      //MyApp.logger.d('0 타입 : ${listData[0][0].runtimeType.toString()}');

      int codeH = int.parse(modelLocationWeather.code);
      for (var data in listData) {
        if (data[0] == codeH) {
          codeX = data[1];
          codeY = data[2];
          listData.clear();
          break;
        }
      }
    } catch (e) {
      MyApp.logger.wtf("CSV 파일에서 행정 구역 코드 조회 실패 : ${e.toString()}");
    }

    if (codeX == null || codeY ==null) {
      return;
    }


    //MyApp.logger.d("CSV에서 x, y값 받아오는 데 걸린 시간 : ${DateTime.now().millisecondsSinceEpoch-time}ms");
    time = DateTime.now().millisecondsSinceEpoch;


    //MyApp.logger.d("찾은 결과 $codeX, $codeY");

    String urlBase = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst';
    String keyService =
        '%2B%2BaANJW%2BGmM22jn4uU%2FTCiFfH58TiKg9euCqOwFAm%2FHNtf4K%2FlQ6zPxgMmXiuj7pPzt2LMOhS5yQBBFhm5IUrA%3D%3D';

    String baseTimeFormatted;
    int hourCurrent = DateTime.now().hour;
    if (hourCurrent < 3) {
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
    }

    baseTimeFormatted += "00";

    String url = "$urlBase?serviceKey=$keyService"
        "&pageNo=1"
        "&numOfRows=10&dataType=JSON"
        "&base_date=${DateFormat('yyyyMMdd').format(DateTime.now())}"
        "&base_time=$baseTimeFormatted"
        "&nx=$codeX"
        "&ny=$codeY";

    //MyApp.logger.d('url : $url ');

    try {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };
      var response = await http.get(Uri.parse(url), headers: requestHeaders);

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

        for (dynamic weather in listMapAddressData) {
          print(weather.toString());
        }

        //MyApp.logger.d("기상청에서 날씨 정보 받아오는 데 걸린 시간 : ${DateTime.now().millisecondsSinceEpoch-time}ms");
        time = DateTime.now().millisecondsSinceEpoch;
      }
    } on Exception catch (e) {
      MyApp.logger.wtf("날씨 api 요청 실패 : ${e.toString()}");
      return null;
    }
  }

  goRouteSiteDetail() {
    Get.toNamed('$keyRouteSiteDetail/${MyApp.providerUser.modelSiteMy?.docId ?? ''}',
        arguments: {keyModelSite: MyApp.providerUser.modelSiteMy});
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
