import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:weather_icons/weather_icons.dart';

import 'model_location.dart';

enum _WeatherType {
  sunny,
  rainy,
  thunder,
  hot,
}

class ModelWeather {
  //{baseDate: 20230620, baseTime: 0800, category: PTY, nx: 59, ny: 128, obsrValue: 0}
  //{baseDate: 20230620, baseTime: 0800, category: REH, nx: 59, ny: 128, obsrValue: 76}
  //{baseDate: 20230620, baseTime: 0800, category: RN1, nx: 59, ny: 128, obsrValue: 0}
  //{baseDate: 20230620, baseTime: 0800, category: T1H, nx: 59, ny: 128, obsrValue: 24}
  //{baseDate: 20230620, baseTime: 0800, category: UUU, nx: 59, ny: 128, obsrValue: 0.4}
  //{baseDate: 20230620, baseTime: 0800, category: VEC, nx: 59, ny: 128, obsrValue: 315}
  //{baseDate: 20230620, baseTime: 0800, category: VVV, nx: 59, ny: 128, obsrValue: -0.3}
  //{baseDate: 20230620, baseTime: 0800, category: WSD, nx: 59, ny: 128, obsrValue: 0.6}

  //T1H : 기온(c)
  //RN1 : 강수량(mm/1h)
  //REH : 습도 (%)
  //VEC : 풍향 (deg)
  //WSD : 풍속 (m/s)
  //PTY : 강수 형태 (안 옴(0), 비(1), 비/눈(2), 눈(3), 소나기(4), 빗방울(5), 빗방울/눈날림(6), 눈날림(7))
  //UUU : 동서 바람 성분 (m/s)
  //VVV : 남북 바람 성분 (m/s)

  final String baseDate;
  final String baseTime;

  final ModelLocation modelLocation;

  int pty;
  int reh;
  int rn1;
  int t1h;
  double uuu;
  int vec;
  double vvv;
  double wsd;

  late _WeatherType _weatherType;

  ModelWeather({
    required this.baseDate,
    required this.baseTime,
    required this.modelLocation,
    this.pty = 0,
    this.reh = 0,
    this.rn1 = 0,
    this.t1h = 0,
    this.uuu = 0,
    this.vec = 0,
    this.vvv = 0,
    this.wsd = 0,
  }) {
    //pty = 2; //test
    _weatherType = getWeatherType();

  }

  _WeatherType getWeatherType() {
    //PTY : 강수 형태 (안 옴(0), 비(1), 비/눈(2), 눈(3), 소나기(4), 빗방울(5), 빗방울/눈날림(6), 눈날림(7))

    if (pty == 0) {
      if (t1h > 35) {
        return _WeatherType.hot;
      } else {
        return _WeatherType.sunny;
      }
    } else if (pty == 1 || pty == 2 || pty == 4 || pty == 5 || pty == 6) {
      return _WeatherType.rainy;
    } else if (pty == 3 || pty == 7) {
      //원래 눈 오는 건데, 임시로 비오는 걸로 함
      return _WeatherType.rainy;
    } else {
      return _WeatherType.sunny;
    }
  }

  IconData getIcon() {
    switch (_weatherType) {
      case _WeatherType.sunny:
        return FontAwesomeIcons.sun;
      case _WeatherType.rainy:
        return FontAwesomeIcons.umbrella;
      case _WeatherType.thunder:
        return WeatherIcons.rain;
      case _WeatherType.hot:
        return WeatherIcons.hot;
    }
  }

  String getPathVideo() {
    //PTY : 강수 형태 (안 옴(0), 비(1), 비/눈(2), 눈(3), 소나기(4), 빗방울(5), 빗방울/눈날림(6), 눈날림(7))
    String pathItemWeather;

    switch (_weatherType) {
      case _WeatherType.sunny:
        pathItemWeather = 'sunny';
        break;
      case _WeatherType.rainy:
        pathItemWeather = 'rainy';
        break;
      case _WeatherType.thunder:
        pathItemWeather = 'thunder';
        break;
      case _WeatherType.hot:
        pathItemWeather = 'hot';
        break;
    }

    return 'assets/images/weather/$pathItemWeather.mp4';
  }

  String getInfoLabel() {
    switch (_weatherType) {
      case _WeatherType.sunny:
        return '좋은 날씨예요.\n오늘도 안전한 하루 보내세요.';
      case _WeatherType.rainy:
        return '비올 가능성이 있어요. \n작업시 주의하세요.';
      case _WeatherType.thunder:
        return '천둥, 번개가 칠 가능성이 있어요. \n작업시 주의하세요.';
      case _WeatherType.hot:
        return '폭염이 예상돼요.\n작업에 주의가 필요해요.';
    }
  }

  String getTime() {
    int hour;
    if (baseTime[0] == '0') {
      hour = int.parse(baseTime.substring(1, 2));
    } else {
      hour = int.parse(baseTime.substring(0, 2));
    }

    String result;
    if (hour < 12) {
      result = '오전 $hour시 기준';
    } else {
      result = '오후 $hour시 기준';
    }

    return result;
  }

  @override
  String toString() {
    return '''
pty : $pty,
reh : $reh,
rn1 : $rn1,
t1h : $t1h,
uuu : $uuu,
vec : $vec,
vvv : $vvv,
wsd : $wsd
''';
  }
}
