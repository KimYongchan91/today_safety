import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:today_safety/const/model/model_check.dart';
import 'package:today_safety/const/model/model_check_list.dart';
import 'package:today_safety/const/model/model_fuc_preset.dart';
import 'package:today_safety/const/value/fuc.dart';
import 'package:today_safety/const/value/fuc_preset.dart';
import 'package:today_safety/const/value/key.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/service/util/util_snackbar.dart';
import 'package:today_safety/ui/item/item_fuc_preset.dart';

import '../../const/model/model_site.dart';
import '../../const/value/router.dart';
import '../../custom/custom_text_field.dart';
import '../../my_app.dart';
import '../item/item_check.dart';

const int lengthCheckListNameMin = 5;
const int lengthCheckListNameMax = 20;

class RouteCheckListNew extends StatefulWidget {
  const RouteCheckListNew({Key? key}) : super(key: key);

  @override
  State<RouteCheckListNew> createState() => _RouteCheckListNewState();
}

class _RouteCheckListNewState extends State<RouteCheckListNew> {
  late ModelSite modelSite;
  bool isFucPresetSelected = false; //fuc 선택 단계를 지났는지

  ValueNotifier<List<ModelCheck>> valueNotifierListModelCheck = ValueNotifier([]);
  ValueNotifier<bool> valueNotifierUpload = ValueNotifier(false);

  TextEditingController textEditingControllerName = TextEditingController();

  @override
  void initState() {
    modelSite = Get.arguments[keyModelSite];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isFucPresetSelected
            ?

            ///fuc 선택 단계를 지났으면
            SingleChildScrollView(
                //physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    const Text('체크리스트 이름'),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomTextField(
                      hintText: '예) 오전 근무조',
                      controller: textEditingControllerName,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ValueListenableBuilder(
                      valueListenable: valueNotifierListModelCheck,
                      builder: (context, value, child) => ListView.builder(
                        itemBuilder: (context, index) => InkWell(
                          onTap: () {},
                          child: ItemCheck(value[index], onDelete: () {
                            onDeleteModelFuc(value[index]);
                          }),
                        ),
                        itemCount: value.length,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                      ),
                    ),

                    ///만들기 버튼
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
              )
            :

            ///fuc 선택 단계 진행 중
            Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      '어떤 작업과 관련되어 있나요?',
                      style: CustomTextStyle.bigBlackBold(),
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
                          padding: EdgeInsets.all(10),
                          child: Text(
                            '건너 뛰기',
                            style: CustomTextStyle.normalGreyBold(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      childAspectRatio: 4 / 5,
                      mainAxisSpacing: 10,
                    ),
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
                  )
                ],
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
}