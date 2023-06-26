import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:today_safety/custom/custom_text_style.dart';

import '../../const/value/router.dart';
import '../../my_app.dart';

class RouteQrCodeScan extends StatefulWidget {
  const RouteQrCodeScan({Key? key}) : super(key: key);

  @override
  State<RouteQrCodeScan> createState() => _RouteQrCodeScanState();
}

class _RouteQrCodeScanState extends State<RouteQrCodeScan> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  StreamSubscription? streamSubscription;
  Barcode? result;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: QRView(
              key: qrKey,
              overlay: QrScannerOverlayShape(
                cutOutSize: Get.width * 0.8,
              ),
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Center(
            child: Text(
              '인식됨. ${result?.code ?? '아직'}',
              style: CustomTextStyle.normalRedBold(),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    streamSubscription = controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null && scanData.code!.contains(urlBaseAppLink)) {
        Get.offNamed(scanData.code!.replaceAll(urlBaseAppLink, ''));
        this.controller!.pauseCamera();
        streamSubscription?.cancel();
      }
    });
  }
}
