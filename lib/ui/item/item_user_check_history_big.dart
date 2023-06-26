import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:today_safety/const/model/model_check_list.dart';
import 'package:today_safety/const/model/model_user_check_history.dart';
import 'package:today_safety/const/value/key.dart';
import 'package:today_safety/const/value/value.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/ui/route/route_check_image_detail.dart';
import 'package:today_safety/ui/route/route_map_detail.dart';
import 'package:today_safety/ui/route/route_user_check_history_detail.dart';

const double sizeCheckImage = 60;

///site detail, check list detail 등의 페이지에서
///최근 인증한 직원들 목록 보여줄 때 사용
class ItemUserCheckHistoryBig extends StatelessWidget {
  final ModelUserCheckHistory modelUserCheckHistory;
  final ModelCheckList? modelCheckList;

  const ItemUserCheckHistoryBig(this.modelUserCheckHistory, {this.modelCheckList, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int millisecondGap =
        DateTime.now().millisecondsSinceEpoch - modelUserCheckHistory.date.millisecondsSinceEpoch;
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

    return Center(
      child: InkWell(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 1 / 1.618,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/logo/sample_logo_230625.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Text(
                          '${modelUserCheckHistory.modelCheckList.modelSite.name}\n안전 점검 인증',
                          style: const CustomTextStyle.normalWhiteBold(),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Text('${modelUserCheckHistory.state == keyPend ? '대기 중' : '확인 완료'}'),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        modelUserCheckHistory.modelCheckList.name,
                        style: const CustomTextStyle.bigBlackBold(),
                      ),
                      Text(
                        DateFormat('yyyy-MM-dd').format(modelUserCheckHistory.date.toDate()),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              ],
            )

            /*ExpandablePanel(
              header: Row(
                children: [
                  Text(modelUserCheckHistory.modelUser.name),
                  const Spacer(),
                  Text(
                    millisecondGapFormatted,
                    style: const CustomTextStyle.normalRedBold(),
                  )
                ],
              ), //todo kyc, 인증 시간 추가
              collapsed: Container(),
              expanded: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '인증 날짜 : ${DateFormat('yyyy-MM-dd HH:mm:ss').format(modelUserCheckHistory.date.toDate())}'),
                  InkWell(
                    onTap: onTapLocation,
                    child: Row(
                      children: [
                        Text(
                          "인증 위치 :${modelUserCheckHistory.modelLocation.si} ${modelUserCheckHistory.modelLocation.gu} "
                          "${modelUserCheckHistory.modelLocation.dong}",
                          style: const CustomTextStyle.normalBlue(),
                        ),
                        const Icon(Icons.map)
                      ],
                    ),
                  ),
                  Text("기기 정보 : ${modelUserCheckHistory.modelDevice.toJson().toString()}"),

                  ///인증 사진 가로 리스트 뷰
                  SizedBox(
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
                  )
                ],
              ), //todo kyc, 인증 주소 등 추가
            )*/
            ,
          ),
        ),
      ),
    );
  }

  onTap() {
    Get.to(() => RouteUserCheckHistoryDetail(modelUserCheckHistory));
  }
}
