import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:today_safety/const/model/model_site.dart';

const double _sizeLogoImage = 120;

class ItemSiteSearch extends StatelessWidget {
  final ModelSite modelSite;

  const ItemSiteSearch(this.modelSite, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      height: _sizeLogoImage,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.zero,
            child: CachedNetworkImage(
              width: _sizeLogoImage * 0.8,
              height: _sizeLogoImage * 0.8,
              imageUrl: modelSite.urlLogoImage,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(modelSite.name),
                Text(
                    '${modelSite.modelLocation.si} ${modelSite.modelLocation.gu} ${modelSite.modelLocation.dong}'),
                Text('${modelSite.userCount}명 가입'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
