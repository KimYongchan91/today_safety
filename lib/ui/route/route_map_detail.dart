import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:today_safety/const/model/model_user_check_history.dart';

import '../../my_app.dart';

const int _sizeMarkerWidth = 60;
const int _sizeMarkerHeight = 60;

class RouteMapDetail extends StatefulWidget {
  final ModelUserCheckHistory modelUserCheckHistory;

  const RouteMapDetail({required this.modelUserCheckHistory, Key? key}) : super(key: key);

  @override
  State<RouteMapDetail> createState() => _RouteMapDetailState();
}

class _RouteMapDetailState extends State<RouteMapDetail> {
  KakaoMapController? kakaoMapController;
  late Completer completerLoadKakaoMap;
  ValueNotifier<List<Marker>> valueNotifierListMarker = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    completerLoadKakaoMap = Completer();

    //MyApp.logger.d("주소 : ${widget.modelUserCheckHistory.modelLocation.toJson().toString()}");

    completerLoadKakaoMap.future.then((_) {
      if (widget.modelUserCheckHistory.modelLocation.lat != null &&
          widget.modelUserCheckHistory.modelLocation.lng != null) {
        List<Marker> listMarkerNew = [...valueNotifierListMarker.value];
        listMarkerNew.add(
          Marker(
              markerId: widget.modelUserCheckHistory.modelLocation.addressLoad ?? 'address_load',
              latLng: LatLng(
                widget.modelUserCheckHistory.modelLocation.lat!,
                widget.modelUserCheckHistory.modelLocation.lng!,
              ),
              width: _sizeMarkerWidth,
              height: _sizeMarkerHeight,
              offsetX: _sizeMarkerWidth ~/ 2,
              offsetY: _sizeMarkerHeight ~/ 2,
              infoWindowContent: '인증 위치',
              infoWindowFirstShow: true,
              infoWindowRemovable: false,

              //마커 이미지
              markerImageSrc:
                  'data:image/jpeg;base64,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'),
        );

        valueNotifierListMarker.value = listMarkerNew;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: ValueListenableBuilder(
                valueListenable: valueNotifierListMarker,
                builder: (context, value, child) => KakaoMap(
                  onMapCreated: ((controller) {
                    completerLoadKakaoMap.complete();
                    kakaoMapController = controller;

                    moveToCurrentPosition();
                  }),
                  markers: value,
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: ElevatedButton(
                child: Text('현재 위치로'),
                onPressed: moveToCurrentPosition,
              ),
            )
          ],
        ),
      ),
    );
  }

  moveToCurrentPosition() {
    if (widget.modelUserCheckHistory.modelLocation.lat != null &&
        widget.modelUserCheckHistory.modelLocation.lng != null) {
      try {
        kakaoMapController?.panTo(LatLng(widget.modelUserCheckHistory.modelLocation.lat!,
            widget.modelUserCheckHistory.modelLocation.lng!));
      } catch (e) {
        MyApp.logger.wtf('panTo 실패 : ${e.toString()}');
      }
    }
  }
}
