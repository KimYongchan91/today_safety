import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:today_safety/const/model/model_notice.dart';
import 'package:today_safety/service/util/util_snackbar.dart';

import '../../const/value/router.dart';

class ItemNoticeBig extends StatelessWidget {
  final ModelNotice? modelNotice;

  const ItemNoticeBig(this.modelNotice, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      child: InkWell(
        onTap: () {
          if (modelNotice == null) {
            showSnackBarOnRoute('근무지에서 게시한 공지사항이 없어요.');
            return;
          }

          Get.toNamed('$keyRouteNoticeDetail/${modelNotice!.docId}',
              arguments: {keyModelNotice: modelNotice!});
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 15),

          child: Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.redAccent),
                  child: const FaIcon(
                    FontAwesomeIcons.bullhorn,size: 20,
                    color: Colors.white,
                  )),
              const SizedBox(
                width: 20,
              ),

              Expanded(
                  child: Text(
                    modelNotice == null ? '공지사항' : modelNotice!.title,
                    style: TextStyle(color: Colors.redAccent, fontSize: 15, fontWeight: FontWeight.bold),
                  )),
              const FaIcon(
                FontAwesomeIcons.angleRight,
                color: Colors.white,
              ),

            ],

          ),
        ),
      ),
    );
  }
}
