import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:today_safety/const/model/model_site.dart';

import '../../const/value/label.dart';
import '../../const/value/router.dart';
import '../../custom/custom_text_style.dart';
import '../../my_app.dart';

const double _sizeLogoImage = 120;

class RouteSiteDetail extends StatefulWidget {
  const RouteSiteDetail({Key? key}) : super(key: key);

  @override
  State<RouteSiteDetail> createState() => _RouteSiteDetailState();
}

class _RouteSiteDetailState extends State<RouteSiteDetail> {
  late ModelSite modelSite;

  @override
  void initState() {
    MyApp.logger.d("사이트 id : ${Get.parameters[keySiteId]}");
    modelSite = Get.arguments[keyModelSite];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(modelSite.name),
              CachedNetworkImage(
                width: _sizeLogoImage * 0.8,
                height: _sizeLogoImage * 0.8,
                imageUrl: modelSite.urlLogoImage,
                fit: BoxFit.cover,
              ),
              Text(modelSite.modelLocation.si != null
                  ? '${modelSite.modelLocation.si} ${modelSite.modelLocation.gu} ${modelSite.modelLocation.dong}'
                  : labelSiteLocation),
              Text('${modelSite.userCount}명 가입'),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Text(
                    '안전점검 체크리스트',
                    style: CustomTextStyle.normalGreyBold(),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: addCheckList,
                    child: const Text(
                      '추가',
                      style: CustomTextStyle.normalWhite(),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  addCheckList() {
    Get.toNamed(keyRouteSiteCheckListNew, arguments: {keyModelSite: modelSite});
  }
}
