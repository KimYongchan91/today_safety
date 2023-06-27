import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:today_safety/ui/item/item_main_campaign.dart';

import '../../custom/custom_text_style.dart';

class UtilCampaignList extends StatefulWidget {
  const UtilCampaignList({Key? key}) : super(key: key);

  @override
  State<UtilCampaignList> createState() => _UtilCampaignListState();
}

class _UtilCampaignListState extends State<UtilCampaignList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      width: Get.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '안전오늘과 함께하는 캠페인',
                style: CustomTextStyle.bigBlackBold(),
              )),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: Get.width,
            height: 150,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return ItemMainCampaign();
                }),
          ),
        ],
      ),
    );
  }
}
