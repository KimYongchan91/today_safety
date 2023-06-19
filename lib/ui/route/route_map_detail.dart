import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:today_safety/const/model/model_check_list.dart';
import 'package:today_safety/const/model/model_user_check_history.dart';
import 'package:today_safety/custom/custom_value_listenable_builder2.dart';

import '../../my_app.dart';

const int _sizeMarkerWidth = 60;
const int _sizeMarkerHeight = 60;

class RouteMapDetail extends StatefulWidget {
  final ModelUserCheckHistory modelUserCheckHistory;
  final ModelCheckList? modelCheckList;

  const RouteMapDetail({required this.modelUserCheckHistory, this.modelCheckList, Key? key}) : super(key: key);

  @override
  State<RouteMapDetail> createState() => _RouteMapDetailState();
}

class _RouteMapDetailState extends State<RouteMapDetail> {
  KakaoMapController? kakaoMapController;
  late Completer completerLoadKakaoMap;
  ValueNotifier<List<Marker>> valueNotifierListMarker = ValueNotifier([]);
  ValueNotifier<List<Circle>> valueNotifierListCircle = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    completerLoadKakaoMap = Completer();

    //MyApp.logger.d("주소 : ${widget.modelUserCheckHistory.modelLocation.toJson().toString()}");

    completerLoadKakaoMap.future.then((_) {
      //인증 사진 추가
      if (widget.modelUserCheckHistory.modelLocation.lat != null &&
          widget.modelUserCheckHistory.modelLocation.lng != null) {
        // MyApp.logger.d(
        //     "widget.modelUserCheckHistory.listModelCheckImage : ${widget.modelUserCheckHistory.listModelCheckImage.toString()}");

        List<Marker> listMarkerNew = [...valueNotifierListMarker.value];
        listMarkerNew.add(
          Marker(
              markerId:
                  'MARKER_${widget.modelUserCheckHistory.docId ?? '${widget.modelUserCheckHistory.modelLocation.lat}, ${widget.modelUserCheckHistory.modelLocation.lng}'}',
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
              markerImageSrc: widget.modelUserCheckHistory.listModelCheckImage.first.urlImage),
        );

        valueNotifierListMarker.value = listMarkerNew;
      }

      //사이트 사진 및 Circle 추가
      if (widget.modelCheckList != null &&
          widget.modelCheckList!.modelSite.modelLocation.lat != null &&
          widget.modelCheckList!.modelSite.modelLocation.lng != null) {
        //이미지 추가
        List<Marker> listMarkerNew = [...valueNotifierListMarker.value];
        listMarkerNew.add(
          Marker(
              markerId: 'MARKER_${widget.modelCheckList!.docId}',
              latLng: LatLng(
                widget.modelCheckList!.modelSite.modelLocation.lat!,
                widget.modelCheckList!.modelSite.modelLocation.lng!,
              ),
              width: _sizeMarkerWidth,
              height: _sizeMarkerHeight,
              offsetX: _sizeMarkerWidth ~/ 2,
              offsetY: _sizeMarkerHeight ~/ 2,
              infoWindowContent: '근무지 위치',
              infoWindowFirstShow: true,
              infoWindowRemovable: false,

              //마커 이미지
              markerImageSrc: widget.modelCheckList!.modelSite.urlLogoImage),
        );

        valueNotifierListMarker.value = listMarkerNew;

        //circle 추가
        List<Circle> listCircleNew = [...valueNotifierListCircle.value];
        listCircleNew.add(
          Circle(
            circleId: 'CIRCLE_${widget.modelCheckList!.modelSite.name}',
            center: LatLng(
              widget.modelCheckList!.modelSite.modelLocation.lat!,
              widget.modelCheckList!.modelSite.modelLocation.lng!,
            ),
            radius: 0, //todo kyc, circle 추가
            strokeColor: Colors.green,
            strokeWidth: 5,
            strokeStyle: StrokeStyle.longDash,
            fillColor: Colors.grey,
            fillOpacity: 0.5,
          ),
        );

        valueNotifierListCircle.value = listCircleNew;
      } else {
        MyApp.logger.d('''
        widget.modelCheckList != null &&
            widget.modelCheckList!.modelSite.modelLocation.lat != null &&
            widget.modelCheckList!.modelSite.modelLocation.lng != null 이 아님
           ''');
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
              child: CustomValueListenableBuilder2(
                a: valueNotifierListMarker,
                b: valueNotifierListCircle,
                builder: (context, a, b, child) => KakaoMap(
                  onMapCreated: ((controller) {
                    completerLoadKakaoMap.complete();
                    kakaoMapController = controller;
                    moveToCurrentPosition();
                  }),
                  markers: a,
                  circles: b,
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
        kakaoMapController?.panTo(
            LatLng(widget.modelUserCheckHistory.modelLocation.lat!, widget.modelUserCheckHistory.modelLocation.lng!));
      } catch (e) {
        MyApp.logger.wtf('panTo 실패 : ${e.toString()}');
      }
    }
  }
}
