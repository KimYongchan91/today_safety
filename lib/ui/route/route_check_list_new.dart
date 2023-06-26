import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:today_safety/const/model/model_check.dart';
import 'package:today_safety/const/model/model_check_list.dart';
import 'package:today_safety/const/model/model_fuc_preset.dart';
import 'package:today_safety/const/value/color.dart';
import 'package:today_safety/const/value/fuc.dart';
import 'package:today_safety/const/value/fuc_preset.dart';
import 'package:today_safety/const/value/key.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/custom/custom_value_listenable_builder2.dart';
import 'package:today_safety/service/util/util_snackbar.dart';
import 'package:today_safety/ui/item/item_fuc_preset.dart';

import '../../const/model/model_constraint_location.dart';
import '../../const/model/model_site.dart';
import '../../const/value/router.dart';
import '../../custom/custom_text_field.dart';
import '../../my_app.dart';
import '../dialog/dialog_close_route.dart';
import '../item/item_check.dart';

const int lengthCheckListNameMin = 3;
const int lengthCheckListNameMax = 20;

const int _sizeMarkerWidth = 60;
const int _sizeMarkerHeight = 60;

class RouteCheckListNew extends StatefulWidget {
  const RouteCheckListNew({Key? key}) : super(key: key);

  @override
  State<RouteCheckListNew> createState() => _RouteCheckListNewState();
}

class _RouteCheckListNewState extends State<RouteCheckListNew> {
  late ModelSite modelSite;
  bool isFucPresetSelected = false; //fuc 선택 단계를 지났는지

  //선택된 안전 점검 항목
  ValueNotifier<List<ModelCheck>> valueNotifierListModelCheck = ValueNotifier([]);

  //전체 안전 점검 항목
  List<ModelCheck> listAllModelCheck = [];
  ValueNotifier<bool> valueNotifierUpload = ValueNotifier(false);

  TextEditingController textEditingControllerName = TextEditingController();

  //ValueNotifier<bool> valueNotifierIsEnableConstraintLocation = ValueNotifier(false);

  ValueNotifier<ModelConstraintLocation?> valueNotifierModelConstraintLocation = ValueNotifier(null);
  KakaoMapController? kakaoMapController;
  List<Marker> listMarker = [];

  @override
  void initState() {
    modelSite = Get.arguments[keyModelSite];

    for (var element in listAllFucCode) {
      listAllModelCheck.add(getModelCheck(element));
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: isFucPresetSelected
              ?

              ///fuc 선택 단계를 지났으면
              InkWell(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          //physics: const NeverScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: InkWell(
                                  onTap: () {
                                    Get.back();
                                  },
                                  child: FaIcon(FontAwesomeIcons.angleLeft),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  '팀의 이름을 입력해 주세요.',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: TextField(
                                  decoration: const InputDecoration(
                                    hintText: 'Ex) 생산팀, 전기팀, 오전 근무팀 등',
                                  ),
                                  controller: textEditingControllerName,
                                ),
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  '팀원이 준수해야 할 안전 점검 항목을 선택해 주세요.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text('추가됨')),
                              const SizedBox(
                                height: 20,
                              ),

                              ///이미 추가된 항목 리스트뷰
                              ValueListenableBuilder(
                                valueListenable: valueNotifierListModelCheck,
                                builder: (context, value, child) => ListView.builder(
                                  itemBuilder: (context, index) => InkWell(
                                    onTap: () {},
                                    child: ItemCheck(
                                        modelCheck: value[index],
                                        itemCheckType: ItemCheckType.delete,
                                        onTap: () {
                                          onDeleteModelFuc(value[index]);
                                        }),
                                  ),
                                  itemCount: value.length,
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text('추가할 수 있는 항목')),

                              ///추가할 수 있는 항목 리스트뷰
                              ValueListenableBuilder(
                                valueListenable: valueNotifierListModelCheck,
                                builder: (context, value, child) => ListView.builder(
                                  itemBuilder: (context, index) => InkWell(
                                    onTap: () {},
                                    child: ItemCheck(
                                        modelCheck: listAllModelCheck
                                            .where((element) => value.contains(element) == false)
                                            .toList()[index],
                                        itemCheckType: ItemCheckType.add,
                                        onTap: () {
                                          onAddModelFuc(listAllModelCheck
                                              .where((element) => value.contains(element) == false)
                                              .toList()[index]);
                                        }),
                                  ),
                                  itemCount: listAllModelCheck.length - value.length,
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                ),
                              ),

                              /*///인증 위치 제한 on/off 토글
                            ValueListenableBuilder(
                                valueListenable: valueNotifierModelConstraintLocation,
                                builder: (context, value, _) => Row(
                                      children: [
                                        Text(
                                          '인증 위치 제한',
                                          style: CustomTextStyle.bigBlackBold(),
                                        ),
                                        CupertinoSwitch(
                                          value: value != null,
                                          onChanged: (value) {
                                            if (value) {
                                              valueNotifierModelConstraintLocation.value =
                                                  ModelConstraintLocation.fromJson({});
                                            } else {
                                              valueNotifierModelConstraintLocation.value = null;
                                            }
                                          },
                                        )
                                      ],
                                    )),

                            ///인증 위치 제한 거리 설정
                            ValueListenableBuilder(
                              valueListenable: valueNotifierModelConstraintLocation,
                              builder: (context, value, child) => Visibility(
                                visible: value != null,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('거리 : ${value?.range ?? 0}m'),
                                    SfSlider(
                                      min: 1,
                                      max: 15,
                                      value: (value?.range ?? 0) ~/ 100,
                                      interval: 1,
                                      showTicks: true,
                                      showLabels: true,
                                      labelFormatterCallback: (actualValue, formattedText) {
                                        return '${actualValue.toInt()}';
                                      },
                                      showDividers: true,
                                      onChanged: (value) {
                                        valueNotifierModelConstraintLocation.value =
                                            ModelConstraintLocation.fromJson(
                                                {keyRange: (value as double).toInt() * 100});
                                      },
                                    ),

                                    ///todo kyc, 마커가 처음 실행시 자동으로 보이지 않음
                                    ///circle이 보이지 않음
                                    IgnorePointer(
                                      child: SizedBox(
                                        height: 300,
                                        child: KakaoMap(
                                          onMapCreated: ((controller) {
                                            print('onMapCreated');
                                            kakaoMapController = controller;
                                            controller.panTo(
                                                LatLng(modelSite.modelLocation.lat!, modelSite.modelLocation.lng!));

                                            if (modelSite.modelLocation.lat != null && modelSite.modelLocation.lng != null) {
                                              listMarker.add(
                                                Marker(
                                                    markerId: 'MARKER_${modelSite.docId}',
                                                    latLng: LatLng(
                                                      modelSite.modelLocation.lat!,
                                                      modelSite.modelLocation.lng!,
                                                    ),
                                                    width: _sizeMarkerWidth,
                                                    height: _sizeMarkerHeight,
                                                    offsetX: _sizeMarkerWidth ~/ 2,
                                                    offsetY: _sizeMarkerHeight ~/ 2,
                                                    infoWindowContent: '근무지 위치',
                                                    infoWindowFirstShow: true,
                                                    infoWindowRemovable: false,

                                                    //마커 이미지
                                                    markerImageSrc: modelSite.urlLogoImage),
                                              );
                                            }

                                          }),
                                          markers: listMarker,
                                          circles: [
                                            Circle(
                                                circleId: 'CIRCLE_$value',
                                                center: LatLng(
                                                    modelSite.modelLocation.lat!, modelSite.modelLocation.lng!),
                                                radius: 100,
                                                fillColor: Colors.green)
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),

                            ///카카오 맵*/
                            ],
                          ),
                        ),
                      ),

                      ///만들기 버튼
                      InkWell(
                        onTap: complete,
                        child: Container(
                          width: Get.width,
                          height: 70,
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(20),
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
                                        style:
                                            TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              :

              ///fuc 선택 단계 진행 중
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                    children: [
                      const SizedBox(
                        height: 30,
                      ),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          onTap: (){
                            Get.back();
                          },
                          child: FaIcon(FontAwesomeIcons.angleLeft),
                        ),
                      ),

                      const SizedBox(
                        height: 30,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            '어떤 작업과 관련된 팀인가요?',
                            style: CustomTextStyle.bigBlackBold(),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              setFuc(null);
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              child: Text(
                                '건너뛰기',
                                style: CustomTextStyle.normalGreyBold(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ListView.builder(
                          itemBuilder: (context, index) => InkWell(
                            onTap: () {
                              setFuc(getModelFucPreset(listAllFucPresetCode[index]));
                            },
                            child: ItemFucPreset(
                              getModelFucPreset(
                                listAllFucPresetCode[index],
                              ),
                            ),
                          ),
                          itemCount: listAllFucPresetCode.length,
                          shrinkWrap: true,
                        ),
                      )
                    ],
                  ),
              ),
        ),
      ),
    );
  }

  setFuc(ModelFucPreset? modelFucPreset) {
    setState(() {
      isFucPresetSelected = true;

      if (modelFucPreset != null) {
        List<ModelCheck> list = [];

        mapFucPresetToFuc[modelFucPreset.code]?.forEach((element) {
          list.add(getModelCheck(element));
        });

        valueNotifierListModelCheck.value = list;
      }
    });
  }

  onDeleteModelFuc(ModelCheck modelCheck) {
    List<ModelCheck> listNew = [...valueNotifierListModelCheck.value];
    listNew.removeWhere((element) => element.fac == modelCheck.fac && element.date == modelCheck.date);

    valueNotifierListModelCheck.value = listNew;
  }

  onAddModelFuc(ModelCheck modelCheck) {
    List<ModelCheck> listNew = [...valueNotifierListModelCheck.value];
    listNew.add(modelCheck);

    valueNotifierListModelCheck.value = listNew;
  }

  complete() async {
    if (valueNotifierUpload.value == true) {
      return;
    }

    if (textEditingControllerName.text.isEmpty) {
      showSnackBarOnRoute('체크리스트의 이름을 입력해 주세요.');
      return;
    }

    if (textEditingControllerName.text.length < lengthCheckListNameMin) {
      showSnackBarOnRoute('체크리스트의 이름은 최소 $lengthCheckListNameMin글자예요.');
      return;
    }

    if (textEditingControllerName.text.length > lengthCheckListNameMax) {
      showSnackBarOnRoute('체크리스트의 이름은 최대 $lengthCheckListNameMax글자예요.');
      return;
    }

    valueNotifierUpload.value = true;

    ModelCheckList modelCheckList = ModelCheckList(
      docId: '',
      name: textEditingControllerName.text,
      date: Timestamp.now(),
      modelSite: modelSite,
      listModelCheck: valueNotifierListModelCheck.value,
    );
    try {
      DocumentReference documentReference =
          await FirebaseFirestore.instance.collection(keyCheckListS).add(modelCheckList.toJson());
      Get.back();
      showSnackBarOnRoute('체크리스트를 만들었어요.');
    } catch (e) {
      MyApp.logger.wtf('서버에 전송 실패 : ${e.toString()}');
      showSnackBarOnRoute(messageServerError);
    }

    valueNotifierUpload.value = false;
  }

  Future<bool> onWillPop() async {
    var result = await Get.dialog(const DialogCloseRoute(
      content: '저장하지 않고 나갈까요?',
      labelButton: '나가기',
    ));
    if (result == true) {
      return true;
    } else {
      return false;
    }
  }
}
