import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:today_safety/const/model/model_site.dart';
import 'package:today_safety/const/value/color.dart';
import 'package:today_safety/service/provider/provider_check_list.dart';

import '../../const/value/label.dart';
import '../../const/value/router.dart';
import '../../custom/custom_text_style.dart';
import '../../my_app.dart';
import '../item/item_check_list.dart';

const double _sizeLogoImage = 120;

class RouteSiteDetail extends StatefulWidget {
  const RouteSiteDetail({Key? key}) : super(key: key);

  @override
  State<RouteSiteDetail> createState() => _RouteSiteDetailState();
}

class _RouteSiteDetailState extends State<RouteSiteDetail> {
  late ModelSite modelSite;
  late ProviderCheckList providerCheckList;

  BoxDecoration btnDecoration = const BoxDecoration(
    shape: BoxShape.circle,
    color: Color(0x55000000),
  );

  @override
  void initState() {
    //MyApp.logger.d("사이트 id : ${Get.parameters[keySiteId]}");
    modelSite = Get.arguments[keyModelSite];

    providerCheckList = ProviderCheckList(modelSite);

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
          ],
          builder: (context, child) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///이미지 영역
                SizedBox(
                  width: Get.width,
                  height: Get.height / 3,
                  child: Stack(
                    children: [
                      ///이미지
                      CachedNetworkImage(
                        width: Get.width,
                        height: Get.height / 3,
                        imageUrl: modelSite.urlLogoImage,
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
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Row(
                    children: [
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
                            height: 20,
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
                      Column(
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
                      )
                    ],
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Row(
                    children: [
                      const Text(
                        '안전점검 체크리스트',
                        style: CustomTextStyle.normalGreyBold(),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          addCheckList();
                        },
                        child: const SizedBox(
                          child: Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.plus,
                                color: Colors.blue,
                                size: 13,
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Text(
                                '만들기',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Consumer<ProviderCheckList>(
                  builder: (context, value, child) => ListView.builder(
                    itemCount: value.listModelCheckList.length,
                    itemBuilder: (context, index) => ItemCheckList(value.listModelCheckList[index]),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                  ),
                )
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
}
