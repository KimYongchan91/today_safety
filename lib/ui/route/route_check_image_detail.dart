import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:today_safety/const/model/model_device.dart';
import 'package:today_safety/const/model/model_user.dart';
import 'package:today_safety/const/value/key.dart';
import 'package:today_safety/custom/custom_text_style.dart';

import '../../const/model/model_check_image.dart';

class RouteCheckImageDetail extends StatefulWidget {
  final List<ModelCheckImage> listModelCheckImage;
  final int index;
  final ModelUser? modelUser;
  final ModelDevice? modelDevice;

  const RouteCheckImageDetail(this.listModelCheckImage, {this.index = 0, this.modelUser,this.modelDevice, Key? key})
      : super(key: key);

  @override
  State<RouteCheckImageDetail> createState() => _RouteCheckImageDetailState();
}

class _RouteCheckImageDetailState extends State<RouteCheckImageDetail> {
  late final PageController pageController;
  late ValueNotifier<int> valueNotifierIndexCurrentImage;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.index);
    valueNotifierIndexCurrentImage = ValueNotifier(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          ///이미지뷰
          ///전체 화면
          Positioned.fill(
            child: PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: CachedNetworkImageProvider(widget.listModelCheckImage[index].urlImage),
                  initialScale: PhotoViewComputedScale.contained * 1,
                  heroAttributes: PhotoViewHeroAttributes(tag: widget.listModelCheckImage[index].urlImage),
                );
              },
              itemCount: widget.listModelCheckImage.length,
              loadingBuilder: (context, event) => Center(
                child: LoadingAnimationWidget.inkDrop(color: Colors.white, size: 48),
              ),
              // backgroundDecoration: widget.backgroundDecoration,
              pageController: pageController,
              onPageChanged: onPageChanged,
            ),
          ),

          ///현재 인증 사진 정보
          Positioned(
            left: 40,
            bottom: 100,
            child: ValueListenableBuilder(
              valueListenable: valueNotifierIndexCurrentImage,
              builder: (context, value, child) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///체크 항목 순서
                  Text(
                    '${value+1}/${widget.listModelCheckImage.length}',
                    style: const CustomTextStyle.normalRedErrorMessage(),
                  ),

                  ///체크 항목 이름
                  Text(
                    widget.listModelCheckImage[value].name,
                    style: const CustomTextStyle.normalRedErrorMessage(),
                  ),

                  ///촬영 시간
                  Text(
                    '촬영 시간 : ${DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.listModelCheckImage[value].date.toDate())}',
                    style: const CustomTextStyle.normalRedErrorMessage(),
                  ),

                  ///회원 정보
                  ///null이면 제거
                  widget.modelUser != null
                      ? Text(
                    '근무자 : ${widget.modelUser!.name}',
                    style: const CustomTextStyle.normalRedErrorMessage(),
                  )
                      : Container(),

                  ///기기 모델명 정보
                  ///null이면 제거
                  widget.modelDevice != null
                      ? Text(
                          '촬영 기기 : ${widget.modelDevice!.model}',
                          style: const CustomTextStyle.normalRedErrorMessage(),
                        )
                      : Container(),

                  ///전면, 후면 카메라인지
                  Text(
                    '카메라 방향 : ${widget.listModelCheckImage[value].cameraDirection == keyBack? '후면' : '전면'}',
                    style: const CustomTextStyle.normalRedErrorMessage(),
                  )

                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void onPageChanged(int page) {
    valueNotifierIndexCurrentImage.value = page;
  }
}
