import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:provider/provider.dart';
import 'package:today_safety/const/model/model_site.dart';
import 'package:today_safety/const/value/color.dart';
import 'package:today_safety/service/provider/provider_check_list.dart';
import 'package:today_safety/ui/route/route_notice_new.dart';
import 'package:today_safety/ui/route/route_webview.dart';
import 'package:today_safety/ui/widget/widget_weather.dart';

import '../../const/model/model_weather.dart';
import '../../const/value/label.dart';
import '../../const/value/router.dart';
import '../../custom/custom_text_style.dart';
import '../../my_app.dart';
import '../../service/provider/provider_notice.dart';
import '../../service/util/util_weather.dart';
import '../item/item_check_list.dart';
import '../item/item_notice_small.dart';

const double _sizeLogoImage = 120;

class RouteSiteDetail extends StatefulWidget {
  const RouteSiteDetail({Key? key}) : super(key: key);

  @override
  State<RouteSiteDetail> createState() => _RouteSiteDetailState();
}

class _RouteSiteDetailState extends State<RouteSiteDetail> with SingleTickerProviderStateMixin {
  late ModelSite modelSite;
  late ProviderCheckList providerCheckList;

  //날씨
  ValueNotifier<ModelWeather?> valueNotifierWeather = ValueNotifier(null);
  late AnimationController controllerRefreshWeather;

  //공지사항 관련
  late ProviderNotice providerNotice;

  BoxDecoration btnDecoration = const BoxDecoration(
    shape: BoxShape.circle,
    color: Color(0x55000000),
  );

  @override
  void initState() {
    //MyApp.logger.d("사이트 id : ${Get.parameters[keySiteId]}");
    modelSite = Get.arguments[keyModelSite];
    providerCheckList = ProviderCheckList(modelSite);

    controllerRefreshWeather = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    ///날씨 자동 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshWeather();
    });

    ///공지사항 받아오기
    providerNotice = ProviderNotice(modelSite);

    super.initState();
  }

  @override
  void dispose() {
    providerCheckList.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackground,
      body: SafeArea(
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: providerCheckList),
            ChangeNotifierProvider.value(value: providerNotice),
          ],
          builder: (context, child) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///현장 이미지 영역
                SizedBox(
                  width: Get.width,
                  height: Get.height / 3,
                  child: Stack(
                    children: [
                      ///현장 이미지
                      CachedNetworkImage(
                        width: Get.width,
                        height: Get.height / 3,
                        imageUrl: modelSite.urlSiteImage,
                        fit: BoxFit.cover,
                      ),

                      ///뒤로가기 버튼
                      Align(
                        alignment: Alignment.topLeft,
                        child: InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            padding: const EdgeInsets.all(15),
                            decoration: btnDecoration,
                            child: const FaIcon(
                              FontAwesomeIcons.angleLeft,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Row(
                    children: [
                      ///로고 이미지
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CachedNetworkImage(
                          width: 60,
                          height: 60,
                          imageUrl: modelSite.urlLogoImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ///근무지명
                          Text(
                            modelSite.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),

                          ///주소
                          Row(
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.locationDot,
                                size: 15,
                                color: Colors.black,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(modelSite.modelLocation.si != null
                                  ? '${modelSite.modelLocation.si} ${modelSite.modelLocation.gu} ${modelSite.modelLocation.dong}'
                                  : labelSiteLocation),
                            ],
                          ),
                        ],
                      )),

                      ///인원 수
                     /* Column(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.userGroup,
                            size: 17,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            '${modelSite.userCount}명',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),*/
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                ///팀영역
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        bottom: BorderSide(
                      width: 1.5,
                      color: colorBackground,
                    )),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        '팀',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 17),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          addCheckList();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(width: 1, color: Colors.orange),
                              color: Colors.white),
                          child: const Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.plus,
                                color: Colors.orange,
                                size: 13,
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Text(
                                '만들기',
                                style: TextStyle(color: Colors.orange),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                ///팀 리스트뷰
                Consumer<ProviderCheckList>(
                  builder: (context, value, child) => ListView.builder(
                    itemCount: value.listModelCheckList.length,
                    itemBuilder: (context, index) => ItemCheckList(value.listModelCheckList[index]),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),

                ///공지사항 영역
                Container(
                  width: Get.width,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ///공지 사항
                          const Text(
                            '공지 사항',
                            style: CustomTextStyle.bigBlackBold(),
                          ),

                          Visibility(
                            visible: MyApp.providerUser.modelUser?.id == modelSite.master,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.orange, // Background color
                              ),
                              onPressed: () {
                                Get.to(() => RouteNoticeNew(
                                      modelSite: modelSite,
                                    ));
                              },
                              child: const Text(
                                '작성하기',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                ///공지사항 리스트
                Consumer<ProviderNotice>(
                  builder: (context, value, child) => ListView.builder(
                    itemCount: value.listModelNotice.length,
                    itemBuilder: (context, index) => ItemNoticeSmall(value.listModelNotice[index]),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                    onRefreshWeather: _refreshWeather,
                    controllerRefreshWeather: controllerRefreshWeather,
                    key: UniqueKey(),
                  ),
                ),

                /*ValueListenableBuilder(
                  valueListenable: valueNotifierWeather,
                  builder: (context, value, child) => InkWell(
                    onTap: () async {
                      if (value != null) {
                        String urlBase = 'https://m.search.naver.com/search.naver?sm=mtp_hty.top&where=m&query=';
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
                                              style:
                                                  const TextStyle(color: Colors.black45, fontWeight: FontWeight.w700),
                                            )
                                          : Container(),

                                      ///날씨 새로고침 아이콘
                                      InkWell(
                                        onTap: _refreshWeather,
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: RotationTransition(
                                            turns: Tween(begin: 0.0, end: 1.0).animate(controllerRefreshWeather),
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
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }

  addCheckList() {
    Get.toNamed(keyRouteCheckListNew, arguments: {keyModelSite: modelSite});
  }

  _refreshWeather() async {
    if (controllerRefreshWeather.isAnimating) {
      MyApp.logger.d("이미 실행 중");
      return;
    }

    controllerRefreshWeather.repeat();
    final DateTime dateTimeNow = DateTime.now();
    int time = dateTimeNow.millisecondsSinceEpoch;

    if (modelSite.modelLocation.lat == null || modelSite.modelLocation.lng == null) {
      MyApp.logger.d("lat, lng == null");
      controllerRefreshWeather.reset();
      return;
    }

    LatLng latLng = LatLng(modelSite.modelLocation.lat!, modelSite.modelLocation.lng!);

    MyApp.logger.d("주소 받아오는 데 걸린 시간 : ${DateTime.now().millisecondsSinceEpoch - time}ms");
    time = dateTimeNow.millisecondsSinceEpoch;

    ModelWeather? modelWeather = await getWeatherFromLatLng(latLng.latitude, latLng.longitude);
    //MyApp.logger.d('조회된 날씨 정보 : ${modelWeather.toString()}');

    //MyApp.logger.d("기상청에서 날씨 정보 받아오는 데 걸린 시간 : ${DateTime.now().millisecondsSinceEpoch-time}ms");
    //time = DateTime.now().millisecondsSinceEpoch;

    valueNotifierWeather.value = modelWeather;

    controllerRefreshWeather.reset();
  }
}
