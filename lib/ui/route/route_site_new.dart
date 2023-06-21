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
import 'package:today_safety/service/util/util_location.dart';
import 'package:today_safety/service/util/util_snackbar.dart';
import 'package:today_safety/ui/dialog/dialog_close_route.dart';
import 'package:today_safety/ui/item/item_site_search.dart';
import 'package:http/http.dart' as http;

import '../../const/value/key.dart';
import '../../const/value/value.dart';
import '../../custom/custom_text_field.dart';
import '../../custom/custom_text_style.dart';
import '../../my_app.dart';
import '../../service/util/util_permission.dart';

const double _sizeLogoImage = 120;

const int lengthSiteNameMin = 5;
const int lengthSiteNameMax = 20;

enum _ImageType {
  logo,
  site,
}

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

  TextStyle titleStyle = const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18);

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
                            onTap: () {
                              Get.back();
                            },
                            child: FaIcon(FontAwesomeIcons.angleLeft),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          const Expanded(
                              child: Text(
                            '근무지 만들기',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          )),
                        ],
                      ),
                    ),

                    ///앱바 구분선
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 1,
                      color: Colors.black45,
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ///근무지 로고 이미지
                          Container(
                            width: _sizeLogoImage,
                            height: _sizeLogoImage,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                width: 2,
                                color: Colors.grey,
                              ),
                            ),
                            child: modelSiteNew.urlLogoImage.isNotEmpty

                                ///로고 이미지를 넣었다면
                                ? Stack(
                                    children: [
                                      //로고 이미지
                                      Positioned.fill(
                                        child: (modelSiteNew.urlLogoImage.startsWith('/data')
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: Image.file(
                                                  File(modelSiteNew.urlLogoImage),
                                                  width: _sizeLogoImage,
                                                  height: _sizeLogoImage,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: CachedNetworkImage(
                                                  width: _sizeLogoImage,
                                                  height: _sizeLogoImage,
                                                  imageUrl: modelSiteNew.urlLogoImage,
                                                  fit: BoxFit.cover,
                                                ),
                                              )),
                                      ),

                                      //로고 이미지 제거 버튼
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: InkWell(
                                          onTap: () {
                                            deleteImage(_ImageType.logo);
                                          },
                                          child: Container(
                                              padding: const EdgeInsets.all(5),
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle, color: Color(0x55000000)),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 20,
                                              )),
                                        ),
                                      )
                                    ],
                                  )

                                ///로고 이미지를 넣기 전
                                : Center(
                                    child: InkWell(
                                      onTap: () {
                                        pickImage(_ImageType.logo);
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            FaIcon(
                                              FontAwesomeIcons.images,
                                              color: Colors.grey,
                                              size: 30,
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              '로고 이미지를 추가해 주세요.',
                                              style:
                                                  TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                          ),

                          ///근무지 현장 이미지
                          Container(
                            width: Get.width,
                            height: Get.height / 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                width: 2,
                                color: Colors.grey,
                              ),
                            ),
                            child: modelSiteNew.urlSiteImage.isNotEmpty

                                ///현장 이미지를 넣었다면
                                ? Stack(
                                    children: [
                                      //로고 이미지
                                      Positioned.fill(
                                        child: (modelSiteNew.urlSiteImage.startsWith('/data')
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: Image.file(
                                                  File(modelSiteNew.urlSiteImage),
                                                  width: Get.width,
                                                  height: Get.height / 4,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: CachedNetworkImage(
                                                  width: Get.width,
                                                  height: Get.height / 4,
                                                  imageUrl: modelSiteNew.urlSiteImage,
                                                  fit: BoxFit.cover,
                                                ),
                                              )),
                                      ),

                                      //로고 이미지 제거 버튼
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: InkWell(
                                          onTap: () {
                                            deleteImage(_ImageType.site);
                                          },
                                          child: Container(
                                              padding: const EdgeInsets.all(5),
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle, color: Color(0x55000000)),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 20,
                                              )),
                                        ),
                                      )
                                    ],
                                  )

                                ///현장 이미지를 넣기 전
                                : Center(
                                    child: InkWell(
                                      onTap: () {
                                        pickImage(_ImageType.site);
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            FaIcon(
                                              FontAwesomeIcons.images,
                                              color: Colors.grey,
                                              size: 30,
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              '현장 이미지를 추가해 주세요.',
                                              style:
                                                  TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                                            )
                                          ],
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
                              child: Text(
                                '이름',
                                style: titleStyle,
                              )),
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
                              child: Text(
                                '주소',
                                style: titleStyle,
                              )),

                          const SizedBox(
                            height: 20,
                          ),

                          ///주소 검색 버튼
                          InkWell(
                            onTap: searchLocation,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.all(15),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5), color: colorBackground),
                              child: modelSiteNew.modelLocation.addressLoad != null
                                  ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      const FaIcon(
                                        FontAwesomeIcons.locationDot,
                                        color: Colors.blue,
                                        size: 14,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        '${modelSiteNew.modelLocation.addressLoad}',
                                        style: const TextStyle(color: Colors.blue),
                                      )
                                    ])
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        FaIcon(
                                          FontAwesomeIcons.locationDot,
                                          size: 14,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
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
                      height: 10,
                    ),

                    //

                    modelSiteNew.modelLocation.lat != null
                        ? SizedBox(
                            width: Get.width,
                            height: 250,
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  pickImage(_ImageType imageType) async {
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

    if (imageType == _ImageType.logo) {
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

      setState(() {
        modelSiteNew.urlLogoImage = croppedFile!.path;
      });
    } else {
      setState(() {
        modelSiteNew.urlSiteImage = xfile.path;
      });
    }

    //MyApp.logger.d("이미지파일 주소 : ${xfile.path}");
  }

  deleteImage(_ImageType imageType) {
    if (imageType == _ImageType.logo) {
      setState(() {
        modelSiteNew.urlLogoImage = "";
      });
    } else {
      setState(() {
        modelSiteNew.urlSiteImage = "";
      });
    }
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
    MyApp.logger.d("kpostal 결과\n"
        "address : ${result.address}\n"
        "si : ${result.sido}\n"
        "gu : ${result.sigungu}\n"
        "dong : ${result.bname}\n"
        "code : ${result.bcode}");

    ModelLocation modelLocationNew = ModelLocation.fromJson({});

    ///여기서바로 h_code를 받도록하자
    try {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'KakaoAK de2c9d30f737be6f897916c21f92c156'
      };

      String url =
          'https://dapi.kakao.com/v2/local/search/address.json?analyze_type=similar&page=1&size=20&query=';
      String query = result.address;

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
        modelLocationNew.lat = double.parse(listMapAddressData.first['y'] ?? '${result.latitude}');
        modelLocationNew.lng = double.parse(listMapAddressData.first['x'] ?? '${result.longitude}');

        //지번 주소
        modelLocationNew.code = listMapAddressData.first['address']['h_code'];
        modelLocationNew.si = listMapAddressData.first['address']['region_1depth_name'];
        modelLocationNew.gu = listMapAddressData.first['address']['region_2depth_name'];
        modelLocationNew.dong = listMapAddressData.first['address']['region_3depth_name'];
        modelLocationNew.addressJibun = listMapAddressData.first['address']['address_name'];

        //도로명 주소
        modelLocationNew.addressLoad = listMapAddressData.first['road_address']['address_name'];
        modelLocationNew.addressBuildingName = listMapAddressData.first['road_address']['building_name'];
      }
    } on Exception catch (e) {
      MyApp.logger.wtf("카카오 rest api 요청 실패 : ${e.toString()}");
      return;
    }

    GeoHash geoHash7 = GeoHash.fromDecimalDegrees(modelLocationNew.lng, modelLocationNew.lat, precision: 7);

    modelLocationNew.gh7 = geoHash7.geohash;
    modelLocationNew.gh6 = geoHash7.geohash.substring(0, 6);
    modelLocationNew.gh5 = geoHash7.geohash.substring(0, 5);
    modelLocationNew.gh4 = geoHash7.geohash.substring(0, 4);

    if (modelLocationNew.code == null || modelLocationNew.code!.isEmpty) {
      MyApp.logger.wtf('modelLocationNew.code == null || modelLocationNew.code!.isEmpty');
      ModelLocation? modelLocationIncludeCodeH =
          await getModelLocationWeatherFromLatLng(modelLocationNew.lat, modelLocationNew.lng);
      if (modelLocationIncludeCodeH == null) {
        throw Exception('modelLocationNew.code ==null && modelLocationIncludeCodeH ==null');
      }

      modelLocationNew.code = modelLocationIncludeCodeH.code;
    }

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
    kakaoMapController?.panTo(LatLng(modelSiteNew.modelLocation.lat!, modelSiteNew.modelLocation.lng!));
    kakaoMapController?.setLevel(3);
    valueNotifierMarkers.value = {
      Marker(
          markerId: 'MARKER_${modelSiteNew.modelLocation.lat}, ${modelSiteNew.modelLocation.lat}',
          latLng: LatLng(modelSiteNew.modelLocation.lat!, modelSiteNew.modelLocation.lng!))
    };
  }

  complete() async {
    if (valueNotifierUpload.value == true) {
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
