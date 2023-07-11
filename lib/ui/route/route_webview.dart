import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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

  ValueNotifier<bool> valueNotifierIsLoading = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                 /* Text(
                    '여긴 웹뷰임',
                    style: CustomTextStyle.normalRedBold(),
                  ),*/
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
                child: Stack(
                  children: [
                    ///웹뷰
                    Positioned.fill(
                      child: InAppWebView(
                        initialUrlRequest: URLRequest(url: Uri.parse(widget.urlInitial)),
                        onLoadStop: (controller, url) {
                          valueNotifierIsLoading.value = false;
                          print("로드 스탑");
                        },
                        onWebViewCreated: (controller) {
                          webViewController = controller;
                        },
                      ),
                    ),

                    ///웹뷰 로딩 중인지
                    Center(
                      child: ValueListenableBuilder(
                        valueListenable: valueNotifierIsLoading,
                        builder: (context, value, child) => Visibility(
                          visible: value,
                          child: LoadingAnimationWidget.inkDrop(color: Colors.green, size: 32),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    bool isCanGoBack = await webViewController?.canGoBack() ?? false;
    if (isCanGoBack) {
      await webViewController?.goBack();
      return false;
    }

    return true;
  }
}
