import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:today_safety/service/provider/provider_user.dart';
import 'package:today_safety/service/provider/provider_user_check_history_on_me.dart';
import 'package:today_safety/ui/dialog/dialog_out_user.dart';
import 'package:today_safety/ui/item/item_banner.dart';
import 'package:today_safety/ui/route/route_user_check_history_list.dart';

import '../../const/value/router.dart';
import '../../my_app.dart';
import '../widget/widget_app_bar.dart';

class ScreenLoginProfile extends StatefulWidget {
  final ProviderUser providerUser;

  const ScreenLoginProfile(this.providerUser, {Key? key}) : super(key: key);

  @override
  State<ScreenLoginProfile> createState() => _ScreenLoginProfileState();
}

class _ScreenLoginProfileState extends State<ScreenLoginProfile> {
  BoxDecoration boxDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(10),
  );

  BoxDecoration mainButton = BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    color: Colors.white,
    border: Border.all(width: 2, color: Colors.black45),
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ///앱바 영역
          const WidgetAppBar(),

          ///로그인 정보
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            width: Get.width,
            color: Colors.white,
            child: Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.solidUserCircle,
                  color: Colors.grey,
                  size: 40,
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.providerUser.modelUser!.name,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.providerUser.modelUser!.idExceptLT,
                        style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          ///내 인증 내역
          Consumer<ProviderUserCheckHistoryOnMe>(
            builder: (context, value, child) => InkWell(
              onTap: () {
                Get.to(() => RouteUserCheckHistoryList(value.listModelUserCheckHistory));
              },
              child: Container(
                width: Get.width,
                decoration: BoxDecoration(color: Colors.white),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Text(
                        '받은 인증서',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Spacer(),
                      Text(
                        '${value.listModelUserCheckHistory.length}개 ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.orange),
                      ),
                      FaIcon(
                        FontAwesomeIcons.angleRight,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          ///관리하는 근무지 정보 영역
          widget.providerUser.modelSiteMy == null

              ///관리하는 근무지가 없을 때
              ? Container(
                  width: Get.width,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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
                        height: 20,
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
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 5,
                          color: Colors.orange,
                          child: Container(
                            width: Get.width,
                            padding: const EdgeInsets.all(10),
                            height: MediaQuery.of(context).size.height / 4,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.add,
                                  size: 35,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '근무지 만들기',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )

              ///내가 관리하는 근무지가 있을 때
              : InkWell(
                  onTap: goRouteSiteDetail,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '관리하는 근무지',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        ///이미지 영역
                        Container(
                          width: Get.width,
                          height: Get.height / 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.redAccent,
                          ),
                          child:
                              //todo ldj 근무지 현장 이미지 부분 수정
                              ///근무지 현장 이미지
                              ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl: widget.providerUser.modelSiteMy!.urlSiteImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        Row(
                          children: [
                            ///근무지 로고 이미지
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              //borderRadius: BorderRadius.circular(20),
                              child: CachedNetworkImage(
                                imageUrl: widget.providerUser.modelSiteMy!.urlLogoImage,
                                fit: BoxFit.cover,
                                width: 60,
                                height: 60,
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ///근무지 이름
                                  Text(
                                    widget.providerUser.modelSiteMy!.name,
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                                  ),

                                  const SizedBox(
                                    height: 10,
                                  ),

                                  ///주소
                                  Row(
                                    children: [
                                      const FaIcon(
                                        FontAwesomeIcons.locationDot,
                                        size: 16,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                          '${widget.providerUser.modelSiteMy!.modelLocation.si} ${widget.providerUser.modelSiteMy!.modelLocation.gu}'
                                          ' ${widget.providerUser.modelSiteMy!.modelLocation.dong}'),
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

          const ItemMainBanner(),

          SizedBox(height: 20,),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ///로그아웃
              InkWell(
                onTap: () async {
                  MyApp.providerUser.clearProvider();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                  child: Text(
                    '로그아웃',
                    style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey),
                  ),
                ),
              ),

              ///로그아웃
              InkWell(
                onTap: () async {
                  var result = await Get.dialog(DialogOutUser());
                  if(result == true){
                    MyApp.providerUser.outUser();
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                  child: Text(
                    '회원 탈퇴',
                    style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20,),
        ],
      ),
    );
  }

  goRouteSiteDetail() {
    Get.toNamed('$keyRouteSiteDetail/${MyApp.providerUser.modelSiteMy?.docId ?? ''}',
        arguments: {keyModelSite: MyApp.providerUser.modelSiteMy});
  }
}
