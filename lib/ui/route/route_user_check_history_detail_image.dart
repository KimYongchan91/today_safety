import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:today_safety/const/model/model_user_check_history.dart';
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: ListView.separated(
            itemCount: widget.modelUserCheckHistory.listModelCheckImage.length,
            itemBuilder: (context, index) => InkWell(
                onTap: () {
                  onTapCheckImage(index);
                },
                child: _ItemCheckImage(widget.modelUserCheckHistory.listModelCheckImage[index])),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(
              height: 20,
            ),
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
        modelUser: widget.modelUserCheckHistory.modelUser,
        modelDevice: widget.modelUserCheckHistory.modelDevice,
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ///인증 항목 정보
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
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
            SizedBox(
              width: 20,
            ),
            Text(
              modelCheck.name,
              style: const TextStyle(color: Colors.black54, fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ],
        ),

        ///인증 날짜
        Text('${DateFormat('yyyy-MM-dd hh:mm:ss').format(modelCheckImage.date.toDate())} 촬영'),

        ///인증 사진
        AspectRatio(
          aspectRatio: 1.618 / 1,
          child: CachedNetworkImage(
            imageUrl: modelCheckImage.urlImage,
            fit: BoxFit.cover,
          ),
        ),

        ///카메라 방향
        ///필요 없을 듯
        //Text('${modelCheckImage.cameraDirection}'),
      ],
    );
  }
}
