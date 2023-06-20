import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../my_app.dart';

class RouteScanQr extends StatefulWidget {
  const RouteScanQr({Key? key}) : super(key: key);

  @override
  State<RouteScanQr> createState() => _RouteScanQrState();
}

class _RouteScanQrState extends State<RouteScanQr> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
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
              onQRViewCreated: _onQRViewCreated,
            ),
          )
        ],
      ),
    );
  }



  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      MyApp.logger.d('스캔 데이터 : ${scanData.toString()}');
      setState(() {
        result = scanData;
      });
    });
  }

}
