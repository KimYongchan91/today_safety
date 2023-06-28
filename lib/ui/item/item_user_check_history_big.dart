import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:today_safety/const/model/model_check_list.dart';
import 'package:today_safety/const/model/model_user_check_history.dart';
import 'package:today_safety/const/value/color.dart';
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
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: InkWell(
                onTap: onTap,
                child: AspectRatio(
                  aspectRatio: aspectRatioMainItemUserCheckHistoryBig1,
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
                              bottom: 0,
                              child: Container(
                                width: Get.width,
                                decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                                        width: 20,
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${modelUserCheckHistory.modelCheckList.modelSite.name}',
                                            style: const CustomTextStyle.normalWhiteBold().copyWith(fontSize: 20),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Text(
                                            '안전 점검 인증',
                                            style: CustomTextStyle.normalWhiteBold(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 60,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                      color: modelUserCheckHistory.state == keyOn
                                          ? colorCheckStateOn
                                          : modelUserCheckHistory.state == keyPend
                                              ? colorCheckStatePend
                                              : colorCheckStateReject,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              modelUserCheckHistory.modelCheckList.name,
                              style: const CustomTextStyle.bigBlackBold(),
                            ),
                            const Spacer(),
                            Text(
                              DateFormat('yyyy-MM-dd').format(modelUserCheckHistory.date.toDate()),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                          ],
                        ),
                      )
                    ],
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
