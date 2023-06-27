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
      padding: const EdgeInsets.only(bottom: 10),
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
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
          color: Colors.redAccent,
          child: Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  child: const FaIcon(
                    FontAwesomeIcons.bullhorn,size: 20,
                    color: Colors.redAccent,
                  )),
              const SizedBox(
                width: 20,
              ),

              Expanded(
                  child: Text(
                    modelNotice == null ? '공지사항' : modelNotice!.title,
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
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
