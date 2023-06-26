import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
      body: SafeArea(
        child: Stack(
          children: [
            ///가운데 노란색 영역
            ///A4 사이즈 비율임
            Center(
              child: WidgetsToImage(
                controller: widgetsToImageController,
                child: Container(
                  width: Get.width * 0.9,
                  decoration: const BoxDecoration(
                    color: colorAppPrimary,
                  ),
                  child: AspectRatio(
                    aspectRatio: _aspectRatioA4,
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                                height: 20,
                              ),

                              ///근무지 이름
                              Text(
                                widget.modelCheckList.modelSite.name,
                                style: const CustomTextStyle.bigBlackBold(),
                              ),
                              const SizedBox(
                                height: 10,
                              ),

                              ///팀 이름
                              Text(
                                widget.modelCheckList.name,
                                style: const CustomTextStyle.extraLargeBlackBold(),
                              ),
                            ],
                          ),
                        ),

                        ///앱 이름
                        const Positioned(
                          bottom: 5,
                          right: 5,
                          child: Text(
                            '오늘 안전',
                            style: CustomTextStyle.normalWhiteBold(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            ///공유하기 버튼
            Positioned(
              top: 10,
              right: 10,
              child: InkWell(
                onTap: captureWidgetToImage,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: ValueListenableBuilder(
                    valueListenable: valueNotifierIsProcessingImage,
                    builder: (context, value, child) => value == false
                        ? Icon(Icons.share)
                        : LoadingAnimationWidget.inkDrop(color: Colors.black, size: 24),
                  ),
                ),
              ),
            )
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
