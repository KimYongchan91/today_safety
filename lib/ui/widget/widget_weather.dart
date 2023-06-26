import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:today_safety/const/model/model_weather.dart';
import 'package:today_safety/my_app.dart';
import 'package:video_player/video_player.dart';

import '../../custom/custom_text_style.dart';
import '../route/route_webview.dart';

const double _sizeWeatherIcon = 60;

class WidgetWeather extends StatefulWidget {
  final ModelWeather? modelWeather;
  final void Function() onRefreshWeather;
  final AnimationController controllerRefreshWeather;

  const WidgetWeather({
    required this.modelWeather,
    required this.onRefreshWeather,
    required this.controllerRefreshWeather,
    Key? key,
  }) : super(key: key);

  @override
  State<WidgetWeather> createState() {
    return _WidgetWeatherState();
  }
}

class _WidgetWeatherState extends State<WidgetWeather> {
   VideoPlayerController? videoPlayerController;

  final ValueNotifier<bool> valueNotifierIsInitVideoController = ValueNotifier(false);

  @override
  void initState() {
    if (widget.modelWeather != null) {
      videoPlayerController = VideoPlayerController.asset(widget.modelWeather!.getPathVideo(),
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true,
            allowBackgroundPlayback: true,
          ));
      videoPlayerController!.initialize().then((_) {
        //
        MyApp.logger.d("비디오 컨트롤러 초기화 완료");
        valueNotifierIsInitVideoController.value = true;
        videoPlayerController!.setVolume(0.0);
        videoPlayerController!.setLooping(true);
        videoPlayerController!.play();
      }).catchError((e) {
        MyApp.logger.wtf("비디오 컨트롤러 초기화 실패 : ${e.toString()}");
      });
    } else {
      MyApp.logger.d("widget.valueNotifierModelWeather.value == null");
    }

    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.modelWeather != null
        ? InkWell(
            onTap: () async {
              String urlBase = 'https://m.search.naver.com/search.naver?sm=mtp_hty.top&where=m&query=';
              String query =
                  '${widget.modelWeather!.modelLocation.si} ${widget.modelWeather!.modelLocation.gu} ${widget.modelWeather!.modelLocation.dong} 날씨';

              Get.to(() => RouteWebView(urlBase + query));
            },
            child: Stack(
              children: [
                ///배경 동영상
                SizedBox(
                  width: Get.width,
                  height: 200,
                  child: ValueListenableBuilder(
                    valueListenable: valueNotifierIsInitVideoController,
                    builder: (context, value, child) =>
                        value ? VideoPlayer(videoPlayerController!) : Container(),
                  ),
                ),
                Container(
                  width: Get.width,
                  height: 200,
                  padding: const EdgeInsets.all(20),
                  color: const Color(0x33000000),
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  child: Text(
                    widget.modelWeather!.getInfoLabel(),
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          FaIcon(
                            widget.modelWeather!.getIcon(),
                            //FontAwesomeIcons.umbrella,
                            color: Colors.white,
                            size: 50,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            '${widget.modelWeather!.t1h}°',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Text(
                        '${widget.modelWeather!.modelLocation.gu} ${widget.modelWeather!.modelLocation.dong}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),

                ///날씨 새로고침 아이콘
                Positioned(
                  top: 20,
                  right: 20,
                  child: InkWell(
                    onTap: widget.onRefreshWeather,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: RotationTransition(
                        turns: Tween(begin: 0.0, end: 1.0).animate(widget.controllerRefreshWeather),
                        child: const FaIcon(
                          FontAwesomeIcons.refresh,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container(
            width: Get.width,
            height: 200,
            padding: const EdgeInsets.all(20),
            color: const Color(0x55000000),
            child: const Text(
              '날씨 정보를 받아오고 있어요.',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          );
  }
}
