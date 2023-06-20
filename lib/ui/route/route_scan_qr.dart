import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:today_safety/custom/custom_text_style.dart';

import '../../const/value/router.dart';
import '../../my_app.dart';

class RouteScanQr extends StatefulWidget {
  const RouteScanQr({Key? key}) : super(key: key);

  @override
  State<RouteScanQr> createState() => _RouteScanQrState();
}

class _RouteScanQrState extends State<RouteScanQr> {
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
              overlay: QrScannerOverlayShape(),
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
      String urlBase = 'https://kayple.com/today_safety/check_list/';

      if (scanData.code != null && scanData.code!.contains(urlBase)) {
        String checkListId = scanData.code!.replaceAll(urlBase, '');
        if (checkListId.contains('/')) {
          checkListId = checkListId.split('/').first;
        }

        Get.offNamed('$keyRouteCheckListDetail/$checkListId');
        this.controller!.pauseCamera();
        streamSubscription?.cancel();
      }

      //https://kayple.com/today_safety/check_list/Y7eoaYJLn5v1YvolI0xW
    });
  }
}
