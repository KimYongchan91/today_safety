import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:today_safety/const/model/model_location_weather.dart';

import '../../const/model/model_weather.dart';
import '../../const/value/value.dart';
import '../../my_app.dart';
import 'util_location.dart';
import 'package:http/http.dart' as http;

Future<ModelWeather?> getWeatherFromLatLng(double lat, double lng) async {
  DateTime dateTimeNow = DateTime.now();

  //행정 구역 코드 받아오기
  ModelLocationWeather? modelLocationWeather;
  try {
    modelLocationWeather = await getModelLocationWeatherFromLatLng(lat, lng);
  } on Exception catch (e) {
    MyApp.logger.wtf("행정 구역 코드 조회 실패 : ${e.toString()}");
  }

  if (modelLocationWeather == null) {
    return null;
  }
  //MyApp.logger.d("카카오에서 행정구역 코드 받아옴 : ${modelLocationWeather.code}");

  //MyApp.logger.d("행정 구역 코드 받아오는 데 걸린 시간 : ${DateTime.now().millisecondsSinceEpoch-time}ms");
  //time = dateTimeNow.millisecondsSinceEpoch;

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
    return null;
  }

  if (codeX == null || codeY == null) {
    MyApp.logger.wtf("CSV 파일에서 행정 구역 코드 찾을 수 없음");
    return null;
  }

  //MyApp.logger.d("CSV에서 x, y값 받아오는 데 걸린 시간 : ${DateTime.now().millisecondsSinceEpoch-time}ms");
  //time = dateTimeNow.millisecondsSinceEpoch;

  //MyApp.logger.d("찾은 결과 $codeX, $codeY");

  String urlBase = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst';
  String keyService =
      '%2B%2BaANJW%2BGmM22jn4uU%2FTCiFfH58TiKg9euCqOwFAm%2FHNtf4K%2FlQ6zPxgMmXiuj7pPzt2LMOhS5yQBBFhm5IUrA%3D%3D';

  String baseTimeFormatted;
  //1시간 전
  int hourCurrent = DateTime.fromMillisecondsSinceEpoch(
          dateTimeNow.millisecondsSinceEpoch - millisecondHour * (dateTimeNow.minute < 30 ? 1 : 0))
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
    var response = await http.get(Uri.parse(url), headers: requestHeaders).timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception("Request to $url failed with status ${response.statusCode}: ${response.body}");
    } else {
      //성공
      //MyApp.logger.d(response.body.toString());
      List<dynamic> listMapAddressData = jsonDecode(response.body)['response']?['body']?['items']?['item'] ?? [];

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

      return modelWeather;
    }
  } on Exception catch (e) {
    MyApp.logger.wtf("날씨 api 요청 실패 : ${e.toString()}");
    return null;
  }
}
