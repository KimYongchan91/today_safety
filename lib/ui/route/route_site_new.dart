import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kpostal/kpostal.dart';
import 'package:path/path.dart' as pt;
import 'package:permission_handler/permission_handler.dart';
import 'package:today_safety/const/model/model_location.dart';
import 'package:today_safety/const/model/model_site.dart';
import 'package:today_safety/const/value/color.dart';
import 'package:today_safety/const/value/router.dart';
import 'package:today_safety/service/util/util_snackbar.dart';
import 'package:today_safety/ui/dialog/dialog_close_route.dart';
import 'package:today_safety/ui/item/item_site_search.dart';
import 'package:http/http.dart' as http;

import '../../const/value/key.dart';
import '../../custom/custom_text_field.dart';
import '../../custom/custom_text_style.dart';
import '../../my_app.dart';
import '../../service/util/util_permission.dart';

const double _sizeLogoImage = 240;

const int lengthSiteNameMin = 5;
const int lengthSiteNameMax = 20;

class RouteSiteNew extends StatefulWidget {
  final ModelSite? modelSiteOld;

  const RouteSiteNew({this.modelSiteOld, Key? key}) : super(key: key);

  @override
  State<RouteSiteNew> createState() => _RouteSiteNewState();
}

class _RouteSiteNewState extends State<RouteSiteNew> {
  late ModelSite modelSiteNew;

  final ImagePicker imagePicker = ImagePicker();
  ImageCropper imageCropper = ImageCropper();
  Completer completer = Completer();
  KakaoMapController? kakaoMapController;
  ValueNotifier<Set<Marker>> valueNotifierMarkers = ValueNotifier({});

  ValueNotifier<bool> valueNotifierUpload = ValueNotifier(false);

  TextStyle titleStyle = const TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 18
  );


  @override
  void initState() {
    if (widget.modelSiteOld != null) {
      modelSiteNew = ModelSite.fromJson(widget.modelSiteOld!.toJson(), widget.modelSiteOld!.docId);
    } else {
      modelSiteNew = ModelSite.fromJson({
        keyMaster: MyApp.providerUser.modelUser?.id,
      }, '');
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: InkWell(
          onTap: hideKeyboard,
          child: SafeArea(
            child: Scaffold(
              body: SingleChildScrollView(
              child: Column(
              children: [
                ///앱바

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  color: Colors.white,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: (){
                          Get.back();
                        },
                        child: FaIcon(FontAwesomeIcons.angleLeft),
                      ),

                      const SizedBox(width: 20,),

                      const Expanded(child: Text(
                        '근무지 만들기',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                      )),




                    ],
                  ),
                ),



///앱바 구분선
Container(width: MediaQuery.of(context).size.width,
height: 1,
color: Colors.black45,),





Container(
  alignment: Alignment.centerLeft,
  padding: EdgeInsets.symmetric(horizontal: 20),
  color: Colors.white,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ///근무지 이미지


      Align(
        alignment: Alignment.center,
        child: Container(

          width: _sizeLogoImage,
          height: _sizeLogoImage,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.grey,
            ),
          ),
          child: modelSiteNew.urlLogoImage.isNotEmpty
              ? Stack(
            children: [
              //로고 이미지
              Positioned.fill(
                child: (modelSiteNew.urlLogoImage.startsWith('/data')
                    ? Image.file(
                  File(modelSiteNew.urlLogoImage),
                  width: _sizeLogoImage,
                  height: _sizeLogoImage,
                  fit: BoxFit.cover,
                )
                    : CachedNetworkImage(
                  width: _sizeLogoImage,
                  height: _sizeLogoImage,
                  imageUrl: modelSiteNew.urlLogoImage,
                  fit: BoxFit.cover,
                )),
              ),

              //로고 이미지 제거 버튼
              Positioned(
                top: 5,
                right: 5,
                child: InkWell(
                  onTap: deleteImage,
                  child:
                  const Padding(padding: EdgeInsets.all(5), child: Icon(Icons.close)),
                ),
              )
            ],
          )
              : Center(
            child: InkWell(
              onTap: pickImage,
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Icon(
                  Icons.photo,
                  size: _sizeLogoImage * 0.25,
                ),
              ),
            ),
          ),
        ),
      ),




      const SizedBox(
        height: 40,
      ),









///근무지 텍스트
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text('이름',style: titleStyle,)),
      const SizedBox(
        height: 20,
      ),


///근무지 텍스트 폼
      CustomTextField(
        onChanged: (value) {
          setState(() {
            modelSiteNew.name = value;
          });
        },
      ),



      const SizedBox(
        height: 40,
      ),


///주소 텍스트
       Padding(
           padding: const EdgeInsets.symmetric(vertical: 20),
           child: Text('주소',style: titleStyle,)),

      const SizedBox(
        height: 20,
      ),

      ///주소 검색 버튼
      InkWell(
        onTap: searchLocation,


        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),

          padding: EdgeInsets.all(15),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),

            color: colorBackground
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(FontAwesomeIcons.locationDot,size: 14,),
SizedBox(width: 5,),


              Text(
                '주소찾기',
              ),
            ],
          ),
        ),
      ),






      
    ],
  ),
),


                //




                //


                const SizedBox(
                  height: 20,
                ),

                //

                Row(
                  children: [
                    Expanded(child: Text('${modelSiteNew.modelLocation.addressLoad}')),
                    InkWell(
                      onTap: searchLocation,
                      child: const Padding(padding: EdgeInsets.all(10), child: Icon(Icons.search)),
                    )
                  ],
                ),

                modelSiteNew.modelLocation.lat != null
                    ? SizedBox(
                        width: Get.width,
                        height: 200,
                        child: ValueListenableBuilder(
                          valueListenable: valueNotifierMarkers,
                          builder: (context, value, child) => KakaoMap(
                            onMapCreated: ((controller) {
                              completer.complete();
                              kakaoMapController = controller;

                              _moveKaKaoMapToCenterAndAddMarker();
                            }),
                            markers: value.toList(),
                          ),
                        ),
                      )
                    : Container(),

                /*  TextField(),
               //
*/
                //
                const SizedBox(
                  height: 120,
                ),

                const Text('미리보기'),
                ItemSiteSearch(modelSiteNew),

                ///전송 버튼
                InkWell(
                  onTap: complete,
                  child: Container(
                    width: Get.width,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xfff84343),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: ValueListenableBuilder(
                        valueListenable: valueNotifierUpload,
                        builder: (context, value, child) => value
                            ? const CircularProgressIndicator()
                            : const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Text(
                                  '만들기',
                                  style: CustomTextStyle.normalWhiteBold(),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),
              ],
              ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  pickImage() async {
    Permission permissionImage;
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt <= 32) {
      permissionImage = Permission.storage;
    } else {
      permissionImage = Permission.photos;
    }

    bool isPermissionGranted = await requestPermission(permissionImage);
    if (isPermissionGranted == false) {
      return;
    }

    XFile? xfile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (xfile == null) {
      showSnackBarOnRoute(messageEmptySelectedImage);
      return;
    }

    CroppedFile? croppedFile;

    try {
      croppedFile = await imageCropper.cropImage(
        sourcePath: xfile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '로고 이미지 자르기',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: true,
          ),
          IOSUiSettings(
            title: '로고 이미지 자르기',
          ),
        ],
      );
    } on Exception catch (e) {
      MyApp.logger.d("이미지 자르는데 실패 ${e.toString()}");
    }

    if (croppedFile == null) {
      showSnackBarOnRoute(messageEmptySelectedImage);
      return;
    }

    MyApp.logger.d("이미지파일 주소 : ${xfile.path}");

    setState(() {
      modelSiteNew.urlLogoImage = croppedFile!.path;
    });
  }

  deleteImage() {
    setState(() {
      modelSiteNew.urlLogoImage = "";
    });
  }

  Future<bool> onWillPop() async {
    if (modelSiteNew.getIsEmpty()) {
      return true;
    }

    var result = await Get.dialog(const DialogCloseRoute());
    if (result == true) {
      return true;
    } else {
      return false;
    }
  }

  hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  searchLocation() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KpostalView(
          //useLocalServer: false, // default is false
          //localPort: 8080, // default is 8080
          //kakaoKey: '440a470432ea1e6ff3a460609d715301',
          callback: _setLocationByKpostalResult,
        ),
      ),
    );
  }

  _setLocationByKpostalResult(Kpostal result) async {
    print(result.address);

    ModelLocation modelLocationNew = ModelLocation.fromJson({});

    if (result.latitude == null || result.longitude == null) {
      //추가적으로 카카오맵 로컬 api를 이용해 위도 경도 받아옴.

      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'KakaoAK de2c9d30f737be6f897916c21f92c156'
      };

      String url =
          'https://dapi.kakao.com/v2/local/search/address.json?analyze_type=similar&page=1&size=20&query=';
      String query = result.address;

      //MyApp.logger.d('url : ${url + query}');
      //MyApp.logger.d('인코딩 url : ${Uri.encodeFull(url + query)}');

      try {
        var response = await http.get(Uri.parse(Uri.encodeFull(url + query)), headers: requestHeaders);

        if (response.statusCode != 200) {
          throw Exception("Request to $url failed with status ${response.statusCode}: ${response.body}");
        } else {
          //성공
          //MyApp.logger.d('${response.body.toString()}');
          List<dynamic> listMapAddressData = jsonDecode(response.body)['documents'] ?? [];
          if (listMapAddressData.isEmpty) {
            throw Exception("empty listMapAddressData");
          }
          modelLocationNew.lat = listMapAddressData.first['x'];
          modelLocationNew.lng = listMapAddressData.first['y'];
        }
      } on Exception catch (e) {
        MyApp.logger.wtf("카카오 rest api 요청 실패 : ${e.toString()}");

        return;
      }
    } else {
      MyApp.logger.d("lat, lng kpostal에서 받아옴 ${result.latitude}, ${result.latitude}");
      modelLocationNew.lat = result.latitude;
      modelLocationNew.lng = result.longitude;
    }

    //lat, lng까지 모두 끝난 상태
    modelLocationNew.si = result.sido;
    modelLocationNew.gu = result.sigungu;
    modelLocationNew.dong = result.bname;
    modelLocationNew.addressLoad = result.roadAddress;
    modelLocationNew.addressJibun = result.jibunAddress;
    modelLocationNew.addressJibun = result.buildingName;

    // widget.routeSaleNewState.sido = kpostal.sido;
    // widget.routeSaleNewState.sigungu = kpostal.sigungu;
    // widget.routeSaleNewState.bname = kpostal.bname;
    // widget.routeSaleNewState.bname1 = kpostal.bname1;
    // widget.routeSaleNewState.roadAddress = kpostal.roadAddress;
    // widget.routeSaleNewState.jibunAddress = kpostal.jibunAddress;
    // widget.routeSaleNewState.buildingName = kpostal.buildingName;

    GeoHash geoHash7 = GeoHash.fromDecimalDegrees(modelLocationNew.lng!, modelLocationNew.lat!, precision: 7);

    modelLocationNew.gh7 = geoHash7.geohash;
    modelLocationNew.gh6 = geoHash7.geohash.substring(0, 6);
    modelLocationNew.gh5 = geoHash7.geohash.substring(0, 5);
    modelLocationNew.gh4 = geoHash7.geohash.substring(0, 4);

    MyApp.logger.d("주소 최종 결과 : ${modelLocationNew.toJson()}");
    setState(() {
      modelSiteNew.modelLocation = modelLocationNew;
    });

    if (completer.isCompleted == false) {
      await completer.future;
      await Future.delayed(const Duration(microseconds: 50));
    }
    _moveKaKaoMapToCenterAndAddMarker();
  }

  _moveKaKaoMapToCenterAndAddMarker() {
    if (modelSiteNew.modelLocation.lat == null) {
      MyApp.logger.wtf("modelSiteNew.modelLocation.lat ==null 이라 중단함");
      return;
    }
    kakaoMapController?.panTo(LatLng(modelSiteNew.modelLocation.lat!, modelSiteNew.modelLocation.lng!));
    kakaoMapController?.setLevel(3);
    valueNotifierMarkers.value = {
      Marker(
          markerId: 'MARKER_${modelSiteNew.modelLocation.lat}, ${modelSiteNew.modelLocation.lat}',
          latLng: LatLng(modelSiteNew.modelLocation.lat!, modelSiteNew.modelLocation.lng!))
    };
  }

  complete() async {

    if(valueNotifierUpload.value == true){
      return;
    }

    if (modelSiteNew.name.isEmpty) {
      showSnackBarOnRoute('근무지의 이름을 입력해 주세요.');
      return;
    }

    if (modelSiteNew.name.length < lengthSiteNameMin) {
      showSnackBarOnRoute('근무지의 이름은 최소 $lengthSiteNameMin글자예요.');
      return;
    }

    if (modelSiteNew.name.length > lengthSiteNameMax) {
      showSnackBarOnRoute('근무지의 이름은 최대 $lengthSiteNameMax글자예요.');
      return;
    }

    if (modelSiteNew.urlLogoImage.isEmpty) {
      showSnackBarOnRoute('근무지의 로고 이미지를 추가해 주세요.');
      return;
    }

    if (modelSiteNew.modelLocation.lat == null) {
      showSnackBarOnRoute('근무지의 주소를 입력해 주세요.');
      return;
    }

    if (widget.modelSiteOld == null) {
      //신규 모드

      valueNotifierUpload.value = true;

      DocumentReference? documentReference;
      try {
        documentReference = await FirebaseFirestore.instance.collection(keySites).add(modelSiteNew.toJson());

        //이미지 전송
        TaskSnapshot uploadTask = await FirebaseStorage.instance
            .ref(
                "$keyImages/$keySites/${documentReference.id}/${pt.basename(File(modelSiteNew.urlLogoImage).path)}")
            .putFile(File(modelSiteNew.urlLogoImage));

        String downloadURL = await uploadTask.ref.getDownloadURL();

        await documentReference.update({
          keyUrlLogoImage: downloadURL,
        });

        valueNotifierUpload.value = false;

        Get.back();
        showSnackBarOnRoute('근무지를 만들었어요');
        return;
      } catch (e) {
        MyApp.logger.wtf("서버에 전송 실패 : ${e.toString()}");
        showSnackBarOnRoute(messageServerError);
        if (documentReference != null) {
          documentReference.delete();
        }

        valueNotifierUpload.value = false;
        return;
      }
    } else {
      //수정 모드

      showSnackBarOnRoute('근무지를 수정했어요.');
      Get.back();
    }
  }
}
