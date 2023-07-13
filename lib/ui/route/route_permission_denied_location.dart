import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:today_safety/const/value/color.dart';

class RoutePermissionDeniedLocation extends StatelessWidget {
  const RoutePermissionDeniedLocation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.locationPinLock,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            height: 100,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                '부정적인 인증을 방지하기 위해 위치 정보가 반드시 필요해요. 이 위치 정보는 인증을 제외한 어떠한 다른 용도로 사용되거나 공유되지 않으니 걱정 마세요.',
                                style: TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      AppSettings.openAppSettings();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      width: Get.width,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.orange,
                      ),
                      child: const Text(
                        '위치 권한 허용하러 가기',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: InkWell(
                onTap: () {
                  Get.back();
                },
                child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 32,
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
