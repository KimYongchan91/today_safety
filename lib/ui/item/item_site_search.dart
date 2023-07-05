import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:today_safety/const/model/model_site.dart';

import '../../const/value/label.dart';

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
            child: SizedBox(
              width: _sizeLogoImage * 0.8,
              height: _sizeLogoImage * 0.8,
              child: modelSite.urlLogoImage.isNotEmpty
                  ? (modelSite.urlLogoImage.startsWith('https')
                      ? CachedNetworkImage(
                          width: _sizeLogoImage * 0.8,
                          height: _sizeLogoImage * 0.8,
                          imageUrl: modelSite.urlLogoImage,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(
                            modelSite.urlLogoImage,
                          ),
                          width: _sizeLogoImage * 0.8,
                          height: _sizeLogoImage * 0.8,
                          fit: BoxFit.cover,
                        ))
                  : const Center(
                      child: Icon(Icons.photo),
                    ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(modelSite.name.isNotEmpty ? modelSite.name : labelSiteName),
                Text(modelSite.modelLocation.si != null
                    ? '${modelSite.modelLocation.si} ${modelSite.modelLocation.gu} ${modelSite.modelLocation.dong}'
                    : labelSiteLocation),
                Text('${modelSite.userCount}명 가입'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
