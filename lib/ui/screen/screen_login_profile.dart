import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:today_safety/service/provider/provider_user.dart';

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
    return Column(
      children: [
        ///앱바 영역
        WidgetAppBar(),

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
                      widget.providerUser.modelUser!.id,
                      style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),

        ///관리하는 근무지 정보 영역
        widget.providerUser.modelSiteMy == null

            ///관리하는 근무지가 없을 때
            ? Column(
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
                      child: const Center(
                        child: FaIcon(
                          FontAwesomeIcons.add,
                          size: 35,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                  const Align(
                      alignment: Alignment.center,
                      child: Text(
                        '근무지 만들기',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45, fontSize: 16),
                      ))
                ],
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
                        '내가 관리하는 근무지',
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

                          const SizedBox(width: 10,),
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
        const Spacer(),

        ///로그아웃
        InkWell(
          onTap: () async {
            MyApp.providerUser.clearProvider();
          },
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            width: double.infinity,
            height: 50,
            child: const Text(
              '로그아웃',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  goRouteSiteDetail() {
    Get.toNamed('$keyRouteSiteDetail/${MyApp.providerUser.modelSiteMy?.docId ?? ''}',
        arguments: {keyModelSite: MyApp.providerUser.modelSiteMy});
  }
}
