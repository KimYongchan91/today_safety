import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:url_launcher/url_launcher.dart';

class RouteWebView extends StatefulWidget {
  final String urlInitial;

  const RouteWebView(this.urlInitial, {Key? key}) : super(key: key);

  @override
  State<RouteWebView> createState() => _RouteWebViewState();
}

class _RouteWebViewState extends State<RouteWebView> {
  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  '여긴 웹뷰임',
                  style: CustomTextStyle.normalRedBold(),
                ),
                Spacer(),
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Padding(padding: EdgeInsets.all(10), child: Icon(Icons.close)),
                ),
              ],
            ),
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: Uri.parse(widget.urlInitial)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
