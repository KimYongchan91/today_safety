import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../custom/custom_text_style.dart';
import '../../../my_app.dart';

enum DialogDeleteSiteOrTeamType { site, team }

class DialogDeleteSiteOrTeam extends StatelessWidget {
  final DialogDeleteSiteOrTeamType dialogDeleteSiteOrTeamType;
  final String labelButton;

  const DialogDeleteSiteOrTeam(this.dialogDeleteSiteOrTeamType, {super.key, this.labelButton = '삭제'});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xffffffff),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      insetPadding: EdgeInsets.zero,
      content: Container(
        constraints: BoxConstraints(
          maxWidth: Get.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 24,
            ),
            const Text(
              '확인 요청',
              style: CustomTextStyle.bigBlackBold(),
            ),
            const SizedBox(
              height: 32,
            ),
            Text(
                '${dialogDeleteSiteOrTeamType == DialogDeleteSiteOrTeamType.site ? '근무지를' : '팀을'} 삭제할까요?\n다시 되돌릴 수 없어요.',
                textAlign: TextAlign.center,
                style: const CustomTextStyle.normalBlack()),
            const SizedBox(
              height: 32,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ///취소 버튼
                InkWell(
                  onTap: () {
                    Get.back(result: false);
                  },
                  child: Container(
                    width: 147,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xffabb3bb),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Text(
                          '취소',
                          style: CustomTextStyle.normalGrey(),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 20,
                ),

                ///전송 버튼
                InkWell(
                  onTap: () {
                    Get.back(result: true);
                  },
                  child: Container(
                    width: 147,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xfff84343),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          labelButton,
                          style: const CustomTextStyle.normalWhiteBold(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}
