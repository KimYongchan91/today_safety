import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:today_safety/const/model/model_check_list.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/service/util/util_snackbar.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

import '../../const/value/color.dart';
import '../../const/value/router.dart';
import '../../my_app.dart';

const double _aspectRatioA4 = 1 / 1.4142;

class RouteQrCodeDetail extends StatefulWidget {
  final ModelCheckList modelCheckList;

  const RouteQrCodeDetail(this.modelCheckList, {Key? key}) : super(key: key);

  @override
  State<RouteQrCodeDetail> createState() => _RouteQrCodeDetailState();
}

class _RouteQrCodeDetailState extends State<RouteQrCodeDetail> {
  final WidgetsToImageController widgetsToImageController = WidgetsToImageController();
  final ValueNotifier<bool> valueNotifierIsProcessingImage = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackground,
      body: SafeArea(
        child: Column(
          children: [
            ///앱바 영역
            Container(
              width: Get.width,
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.white,
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: const FaIcon(FontAwesomeIcons.angleLeft),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: captureWidgetToImage,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ValueListenableBuilder(
                        valueListenable: valueNotifierIsProcessingImage,
                        builder: (context, value, child) => value == false
                            ? const Icon(Icons.share)
                            : LoadingAnimationWidget.inkDrop(color: Colors.black, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            ///구분선
            Container(
              width: Get.width,
              height: 0.5,
              color: Colors.black45,
            ),

            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Card(
                      elevation: 2,
                      child: WidgetsToImage(
                        controller: widgetsToImageController,
                        child: Container(
                          width: Get.width * 0.9,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: AspectRatio(
                            aspectRatio: _aspectRatioA4,
                            child: Center(
                              child: Column(
                                // mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/logo/appIcon.png',
                                          width: 25,
                                          height: 25,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        const Text(
                                          '오늘안전',
                                          style: TextStyle(color: Colors.black, fontFamily: "SANGJU", fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ),

                                  ///QR 코드 영역
                                  SizedBox(
                                    width: Get.width * 0.7,
                                    height: Get.width * 0.7,
                                    child: SfBarcodeGenerator(
                                      value:
                                          '$urlBaseAppLink$keyRouteCheckListDetail/${widget.modelCheckList.docId}/$keyRouteCheckListCheckWithOutSlash',
                                      symbology: QRCode(),
                                      showValue: false,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),

                                  ///근무지 이름
                                  Text(
                                    widget.modelCheckList.modelSite.name,
                                    style: const CustomTextStyle.bigBlackBold(),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),

                                  ///팀 이름
                                  Text(
                                    widget.modelCheckList.name,
                                    style: const CustomTextStyle.extraLargeBlackBold(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      '인쇄 미리보기',
                      style: CustomTextStyle.normalGreyBold(),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  captureWidgetToImage() async {
    if (valueNotifierIsProcessingImage.value) {
      return;
    }

    valueNotifierIsProcessingImage.value = true;

    Uint8List? bytes = await widgetsToImageController.capture();
    try {
      if (bytes == null) {
        throw Exception('bytes ==null');
      }
      final tempDir = await getTemporaryDirectory();
      File file = await File('${tempDir.path}/image_qr_check_list_${widget.modelCheckList.docId}.png').create();
      file.writeAsBytesSync(bytes);

      MyApp.logger.d("생성된 파일 주소 : ${file.path}");
      valueNotifierIsProcessingImage.value = false;
      Share.shareXFiles([XFile(file.path)]);
    } on Exception catch (e) {
      MyApp.logger.wtf("이미지 파일 생성 실패 : ${e.toString()}");
      showSnackBarOnRoute("이미지 파일 생성에 실패했어요.");
      valueNotifierIsProcessingImage.value = false;
    }
  }
}
