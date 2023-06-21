import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:today_safety/const/model/model_weather.dart';

import '../../custom/custom_text_style.dart';
import '../route/route_webview.dart';

const double _sizeWeatherIcon = 60;

class WidgetWeather extends StatelessWidget {
  final ValueNotifier<ModelWeather?> valueNotifierModelWeather;
  final void Function() onRefreshWeather;
  final AnimationController controllerRefreshWeather;

  const WidgetWeather({
    required this.valueNotifierModelWeather,
    required this.onRefreshWeather,
    required this.controllerRefreshWeather,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: valueNotifierModelWeather,
      builder: (context, value, child) => InkWell(
        onTap: () async {
          if (value != null) {
            String urlBase = 'https://m.search.naver.com/search.naver?sm=mtp_hty.top&where=m&query=';
            String query =
                '${value.modelLocationWeather.si} ${value.modelLocationWeather.gu} ${value.modelLocationWeather.dong} 날씨';

            Get.to(() => RouteWebView(urlBase + query));
          }
        },
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                /*  Text(
                  '날씨',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),*/
                /*Row(
                  mainAxisSize: MainAxisSize.min,
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
                        ///날씨 새로고침 아이콘
                        InkWell(
                          onTap: onRefreshWeather,
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: RotationTransition(
                              turns: Tween(begin: 0.0, end: 1.0).animate(controllerRefreshWeather),
                              child: const Icon(Icons.refresh),
                            ),
                          ),
                        ),

*/ /*                      Row(
                          children: [
                            ///날씨 정보 받아온 시간
                            */ /* */ /*value != null
                                ? Text(
                                    value.getTime(),
                                    style: const TextStyle(color: Colors.black45, fontWeight: FontWeight.w700),
                                  )
                                : Container(),*/ /* */ /*
                          ],
                        ),*/ /*



                        const SizedBox(
                          height: 5,
                        ),

                        ///날씨 강수량
                        */ /* value != null
                            ? Text(
                                '강수량 ${value.rn1.toString()}mm/h',
                                style: const CustomTextStyle.normalBlackBold(),
                              )
                            : Container(),*/ /*
                      ],
                    ),
                  ],
                ),*/

                ///날씨 온도
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ///날씨 아이콘
                    value != null
                        ? SizedBox(
                            ///todo ldj, Icon 데이터가 이상함
                            ///겉 박스에 1.5배 준 거임

                            width: _sizeWeatherIcon * 1.5,
                            height: _sizeWeatherIcon * 1.5,
                            child: Icon(
                              value.getIcon(),
                              size: _sizeWeatherIcon,
                            ),
                          )
                        : Container(),

                    //SizedBox(width: 10,),

                    ///날씨 온도
                    value != null
                        ? Text(
                            '${value.t1h.toString()}°',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
                          )
                        : Container(),
                  ],
                ),
                /*SizedBox(
                  height: 20,
                ),*/
                value != null
                    ? Text(
                        '${value.modelLocationWeather.gu} ${value.modelLocationWeather.dong}',
                        style: const TextStyle(color: Colors.black45, fontWeight: FontWeight.w700),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
