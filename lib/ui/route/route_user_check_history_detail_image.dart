import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:today_safety/const/model/model_user_check_history.dart';
import 'package:today_safety/const/value/color.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/ui/route/route_check_image_detail.dart';

import '../../const/model/model_check.dart';
import '../../const/model/model_check_image.dart';
import '../../const/value/fuc.dart';

class RouteUserCheckHistoryDetailImage extends StatefulWidget {
  final ModelUserCheckHistory modelUserCheckHistory;

  const RouteUserCheckHistoryDetailImage(this.modelUserCheckHistory, {Key? key}) : super(key: key);

  @override
  State<RouteUserCheckHistoryDetailImage> createState() => _RouteUserCheckHistoryDetailImageState();
}

class _RouteUserCheckHistoryDetailImageState extends State<RouteUserCheckHistoryDetailImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: Get.width,
                height: 60,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    ///회사로고
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        alignment: Alignment.center,
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade700,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Image.asset(
                          'assets/images/logo/app_logo_big_128.png',
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      '${widget.modelUserCheckHistory.modelCheckList.name} (${widget.modelUserCheckHistory.modelUser.name})',
                      style: const CustomTextStyle.bigBlackBold(),
                    ),
                  ],
                ),
              ),
              ListView.separated(
                itemCount: widget.modelUserCheckHistory.listModelCheckImage.length,
                itemBuilder: (context, index) => InkWell(
                    onTap: () {
                      onTapCheckImage(index);
                    },
                    child: _ItemCheckImage(widget.modelUserCheckHistory.listModelCheckImage[index])),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => const SizedBox(
                  height: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  onTapCheckImage(int index) {
    Get.to(
      () => RouteCheckImageDetail(
        widget.modelUserCheckHistory.listModelCheckImage,
        index: index,
        modelUserCheckHistory: widget.modelUserCheckHistory,
      ),
    );
  }
}

class _ItemCheckImage extends StatelessWidget {
  final ModelCheckImage modelCheckImage;

  const _ItemCheckImage(this.modelCheckImage, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ModelCheck modelCheck = getModelCheck(modelCheckImage.fac ?? '');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 10,
            ),

            ///인증 항목 정보
            Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xffbbd6fd)),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.asset(
                      getPathCheckImage(modelCheck),
                      width: 50,
                      height: 50,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  modelCheck.name,
                  style: const TextStyle(color: Colors.black54, fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            ),

            ///인증 사진
            AspectRatio(
              aspectRatio: 1.618 / 1,
              child: CachedNetworkImage(
                imageUrl: modelCheckImage.urlImage,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: LoadingAnimationWidget.inkDrop(color: colorAppPrimary, size: 24),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),

            ///인증 날짜
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${DateFormat('yyyy-MM-dd hh:mm:ss').format(modelCheckImage.date.toDate())}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),

            ///카메라 방향
            ///필요 없을 듯
            //Text('${modelCheckImage.cameraDirection}'),
          ],
        ),
      ),
    );
  }
}
