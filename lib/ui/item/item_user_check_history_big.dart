import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:today_safety/const/model/model_check_list.dart';
import 'package:today_safety/const/model/model_user_check_history.dart';
import 'package:today_safety/const/value/key.dart';
import 'package:today_safety/const/value/router.dart';
import 'package:today_safety/const/value/value.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/ui/dialog/dialog_help_user_check_hostory_state.dart';
import 'package:today_safety/ui/route/route_check_image_detail.dart';
import 'package:today_safety/ui/route/route_map_detail.dart';
import 'package:today_safety/ui/route/route_user_check_history_detail.dart';

import '../../const/value/layout_main.dart';

const double sizeCheckImage = 60;

///메인 루트에서 내 인증서를 보여줄 때 사용
class ItemUserCheckHistoryBig extends StatelessWidget {
  final ModelUserCheckHistory modelUserCheckHistory;
  final ModelCheckList? modelCheckList;
  final double padding;

  const ItemUserCheckHistoryBig(this.modelUserCheckHistory, {this.modelCheckList, this.padding = 0, Key? key})
      : super(key: key);

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

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ///인증서 영역
            InkWell(
              onTap: onTap,
              child: AspectRatio(
                aspectRatio: aspectRatioMainItemUserCheckHistoryBig1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              ///회사 현장 이미지
                              Positioned.fill(
                                child: CachedNetworkImage(
                                  imageUrl: modelUserCheckHistory.modelCheckList.modelSite.urlSiteImage,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              ///회사 로고 + 회사명 + 안전 점검 인증
                              Positioned(
                                bottom: 10,
                                left: 10,
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12), color: Colors.black.withOpacity(0.5)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: CachedNetworkImage(
                                            imageUrl: modelUserCheckHistory.modelCheckList.modelSite.urlLogoImage,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          '${modelUserCheckHistory.modelCheckList.modelSite.name}\n안전 점검 인증',
                                          style: const CustomTextStyle.normalWhiteBold(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              ///확인 완료 or 승인 대기 중
                              ///확인 완료면 초록색
                              ///승인 대기 중이면 주황색
                              Positioned(
                                top: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () {
                                    Get.dialog(const DialogHelpUserCheckHistoryState());
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: modelUserCheckHistory.state == keyPend ? Colors.green : Colors.orange,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
                                style: const TextStyle(fontWeight: FontWeight.bold),
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
            ),
          ],
        ),
      ),
    );
  }

  onTap() {
    Get.toNamed('$keyRouteUserCheckHistoryDetail/${modelUserCheckHistory.docId}', arguments: {
      keyModelUserCheckHistory: modelUserCheckHistory,
    });
  }
}
