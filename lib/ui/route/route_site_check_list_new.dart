import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:today_safety/const/model/model_fuc_preset.dart';
import 'package:today_safety/const/value/fuc.dart';
import 'package:today_safety/const/value/fuc_preset.dart';
import 'package:today_safety/custom/custom_text_style.dart';
import 'package:today_safety/ui/item/item_fuc_preset.dart';

import '../../const/model/model_fuc.dart';
import '../../const/model/model_site.dart';
import '../../const/value/router.dart';
import '../item/item_fuc.dart';

class RouteSiteCheckListNew extends StatefulWidget {
  const RouteSiteCheckListNew({Key? key}) : super(key: key);

  @override
  State<RouteSiteCheckListNew> createState() => _RouteSiteCheckListNewState();
}

class _RouteSiteCheckListNewState extends State<RouteSiteCheckListNew> {
  late ModelSite modelSite;
  bool isFucPresetSelected = false; //fuc 선택 단계를 지났는지

  List<ModelFuc> listModelFuc = [];

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
                    ListView.builder(
                      itemBuilder: (context, index) => InkWell(
                        onTap: () {},
                        child: ItemFuc(
                          listModelFuc[index],
                        ),
                      ),
                      itemCount: listModelFuc.length,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                    )
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
        mapFucPresetToFuc[modelFucPreset.code]?.forEach((element) {
          listModelFuc.add(getModelFuc(element));
        });
      }
    });
  }
}
