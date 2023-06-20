import 'package:flutter/material.dart';
import 'package:today_safety/const/model/model_weather.dart';

class RouteWeatherDetail extends StatefulWidget {
  final ModelWeather modelWeather;

  const RouteWeatherDetail(this.modelWeather, {Key? key}) : super(key: key);

  @override
  State<RouteWeatherDetail> createState() => _RouteWeatherDetailState();
}

class _RouteWeatherDetailState extends State<RouteWeatherDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text('날씨 상세 페이지'),
            Text('현재 온도 : ${widget.modelWeather.t1h}°C'),
          ],
        ),
      ),
    );
  }
}
