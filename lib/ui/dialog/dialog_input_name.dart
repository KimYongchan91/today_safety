import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:today_safety/const/value/color.dart';
import 'package:today_safety/custom/custom_text_field.dart';

import '../../custom/custom_text_style.dart';
import '../../service/util/util_snackbar.dart';

const int lengthNameMin = 2;
const int lengthNameMax = 10;

class DialogInputName extends StatefulWidget {
  final String idExceptLt;

  const DialogInputName(this.idExceptLt, {Key? key}) : super(key: key);

  @override
  State<DialogInputName> createState() => _DialogInputNameState();
}

class _DialogInputNameState extends State<DialogInputName> {
  final TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xffffffff),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      insetPadding: EdgeInsets.zero,
      content: Container(
        width: 338,
        constraints: BoxConstraints(
          maxHeight: Get.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 24,
            ),
            Text(
              '${widget.idExceptLt}님 반가워요.',
              style: const CustomTextStyle.bigBlackBold(),
            ),
            const SizedBox(
              height: 32,
            ),
            const Text('관리자가 확인할 수 있는 이름이나 상호를 입력해주세요.',
                textAlign: TextAlign.center, style: CustomTextStyle.normalBlack()),
            const SizedBox(
              height: 20,
            ),
            CustomTextField(
              hintText: '예시) 홍길동, 오늘 설비',
              controller: textEditingController,
            ),
            const SizedBox(
              height: 20,
            ),

            ///확인 버튼
            InkWell(
              onTap: complete,
              child: Container(
                width: Get.width,
                height: 50,
                decoration: BoxDecoration(
                  color: colorAppPrimary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      '확인',
                      style: CustomTextStyle.normalWhiteBold(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }

  complete() {
    if (textEditingController.text.substring(0, 1) == " " ||
        textEditingController.text.substring(textEditingController.text.length - 1, textEditingController.text.length) == " ") {
      showSnackBarOnRoute('이름이나 상호는 공백으로 시작하거나 끝날 수 없어요.');
      return;
    }

    if (textEditingController.text.isEmpty) {
      showSnackBarOnRoute('이름이나 상호를 입력해 주세요.');
      return;
    }

    if (textEditingController.text.length < lengthNameMin) {
      showSnackBarOnRoute('이름이나 상호는 최소 $lengthNameMin글자예요.');
      return;
    }

    if (textEditingController.text.length > lengthNameMax) {
      showSnackBarOnRoute('이름이나 상호는 최대 $lengthNameMax글자예요.');
      return;
    }

    Get.back(result: textEditingController.text);
  }
}
