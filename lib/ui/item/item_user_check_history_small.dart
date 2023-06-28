import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:today_safety/const/model/model_check_list.dart';
import 'package:today_safety/const/model/model_user_check_history.dart';
import 'package:today_safety/const/value/key.dart';
import 'package:today_safety/const/value/value.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/ui/route/route_check_image_detail.dart';
import 'package:today_safety/ui/route/route_map_detail.dart';

import '../../const/value/color.dart';
import '../../const/value/router.dart';

const double sizeCheckImage = 60;

///site detail, check list detail 등의 페이지에서
///최근 인증한 직원들 목록 보여줄 때 사용
class ItemUserCheckHistorySmall extends StatelessWidget {
  final ModelUserCheckHistory modelUserCheckHistory;
  final ModelCheckList? modelCheckList;

  const ItemUserCheckHistorySmall(this.modelUserCheckHistory, {this.modelCheckList, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int millisecondGap = DateTime.now().millisecondsSinceEpoch - modelUserCheckHistory.date.millisecondsSinceEpoch;
    String millisecondGapFormatted;
    if (millisecondGap < millisecondMinute) {
      millisecondGapFormatted = "방금";
    } else if (millisecondGap < millisecondHour) {
      millisecondGapFormatted = "${millisecondGap ~/ millisecondMinute}분 전";
    } else if (millisecondGap < millisecondDay) {
      millisecondGapFormatted = "${millisecondGap ~/ millisecondHour}시간 전";
    } else {
      millisecondGapFormatted = "${millisecondGap ~/ millisecondDay}일 전";
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 0.2,
            color: Colors.grey,
          ),
          color: Colors.white,

        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [


                  Builder(
                    builder: (context) {
                      IconData icon;
                      //String text;
                      Color color;

                      switch (modelUserCheckHistory.state) {
                        case keyOn:
                          icon = FontAwesomeIcons.checkCircle;
                          //text = '확인 완료';
                          color = colorCheckStateOn;
                          break;

                        case keyPend:
                          icon = FontAwesomeIcons.dotCircle;
                          //text = '확인 대기 중';
                          color = colorCheckStatePend;
                          break;

                        case keyReject:
                          icon = FontAwesomeIcons.xmarkCircle;
                          //text = '거절';
                          color = colorCheckStateReject;
                          break;

                        default:
                          icon = FontAwesomeIcons.checkCircle;
                          //text = '확인 대기 중';
                          color = colorCheckStatePend;
                          break;
                      }

                      return FaIcon(
                        icon,
                        color: color,
                      );
                    },
                  ),

                  const SizedBox(
                    width: 10,
                  ),


                  Expanded(
                    child: Text(
                      modelUserCheckHistory.modelUser.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 14),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    millisecondGapFormatted,
                    style: const CustomTextStyle.normalRedBold().copyWith(color: Colors.black45),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),



              /*  SizedBox(
                height: 10,
              ),*/

              /*   ///위치 정보
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.locationDot,
                        size: 15,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      InkWell(
                        onTap: onTapLocation,
                        child: Row(
                          children: [
                            Text(
                              "${modelUserCheckHistory.modelLocation.si} ${modelUserCheckHistory.modelLocation.gu} "
                                  "${modelUserCheckHistory.modelLocation.dong}",
                              style: const CustomTextStyle.normalBlue(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),*/

              /*Text("기기 정보 : ${modelUserCheckHistory.modelDevice.toJson().toString()}"),*/

              ///인증 사진 가로 리스트 뷰
              /* SizedBox(
                    height: sizeCheckImage,
                    child: ListView.builder(
                      itemCount: modelUserCheckHistory.listModelCheckImage.length,
                      itemBuilder: (context, index) => InkWell(
                        onTap: () {
                          Get.to(
                            () => RouteCheckImageDetail(
                              modelUserCheckHistory.listModelCheckImage,
                              index: index,
                              modelUser: modelUserCheckHistory.modelUser,
                              modelDevice: modelUserCheckHistory.modelDevice,
                            ),
                          );
                        },
                        child: Hero(
                          tag: modelUserCheckHistory.listModelCheckImage[index].urlImage,
                          child: CachedNetworkImage(
                            imageUrl: modelUserCheckHistory.listModelCheckImage[index].urlImage,
                            width: sizeCheckImage,
                            height: sizeCheckImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      scrollDirection: Axis.horizontal,
                    ),
                  ),*/
            ],
          ),
        ),
      ),
    );
  }

  onTap() {
    Get.toNamed('$keyRouteUserCheckHistoryDetail/${modelUserCheckHistory.docId}');
  }

  onTapLocation() {
    Get.to(() => RouteMapDetail(
          modelUserCheckHistory: modelUserCheckHistory,
          modelCheckList: modelCheckList,
        ));
  }
}
