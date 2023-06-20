import 'package:flutter/material.dart';
import 'package:today_safety/const/model/model_location_weather.dart';
import 'package:weather_icons/weather_icons.dart';

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

  final ModelLocationWeather modelLocationWeather;

  int pty;
  int reh;
  int rn1;
  int t1h;
  double uuu;
  int vec;
  double vvv;
  double wsd;

  ModelWeather({
    required this.baseDate,
    required this.baseTime,
    required this.modelLocationWeather,
    this.pty = 0,
    this.reh = 0,
    this.rn1 = 0,
    this.t1h = 0,
    this.uuu = 0,
    this.vec = 0,
    this.vvv = 0,
    this.wsd = 0,
  });

  IconData getIcon() {
    //PTY : 강수 형태 (안 옴(0), 비(1), 비/눈(2), 눈(3), 소나기(4), 빗방울(5), 빗방울/눈날림(6), 눈날림(7))
    switch (pty) {
      case 0:
        return WeatherIcons.day_sunny;

      case 1:
        return WeatherIcons.rain;

      case 2:
        return WeatherIcons.rain_mix;

      case 3:
        return WeatherIcons.snow;

      case 4:
        return WeatherIcons.raindrops;

      case 5:
        return WeatherIcons.rain;

      case 6:
        return WeatherIcons.rain_mix;

      case 7:
        return WeatherIcons.snow;

      default:
        return WeatherIcons.day_sunny;
    }
  }

  String getTime(){
    int hour;
    if(baseTime[0] =='0'){
      hour = int.parse(baseTime.substring(1,2));
    }else{
      hour = int.parse(baseTime.substring(0,2));
    }

    String result;
    if(hour<12){
      result  = '오전 $hour시 기준';
    }else{
      result  = '오후 $hour시 기준';
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
