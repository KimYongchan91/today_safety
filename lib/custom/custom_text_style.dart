import 'package:flutter/material.dart';

import '../const/value/color.dart';

class CustomTextStyle extends TextStyle {
  const CustomTextStyle({
    required Color color,
    required double fontSize,
    required FontWeight fontWeight,
    String fontFamily = 'Pretendard',
    FontStyle fontStyle = FontStyle.normal,
    double? height = 1.1,
  }) : super(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontFamily: fontFamily,
          fontStyle: fontStyle,
          height: height,
        );

  ///큰 텍스크
  const CustomTextStyle.bigBlack() : this(color: Colors.black, fontSize: 40, fontWeight: FontWeight.w700);

  const CustomTextStyle.bigGrey() : this(color: Colors.grey, fontSize: 40, fontWeight: FontWeight.w700);

  ///타이틀 텍스트
  const CustomTextStyle.titleBlack() : this(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700);

  const CustomTextStyle.titleWhite() : this(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700);

  ///라벨 텍스트(text field 위에)
  const CustomTextStyle.labelGrey()
      : this(color: colorGreyTextSub, fontSize: 15, fontWeight: FontWeight.w500);

  const CustomTextStyle.labelTransparent()
      : this(color: Colors.transparent, fontSize: 15, fontWeight: FontWeight.w600);

  ///일반 텍스트
  const CustomTextStyle.contentBlack() : this(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500);

  const CustomTextStyle.contentBlue() : this(color: Colors.blue, fontSize: 15, fontWeight: FontWeight.w500);

  const CustomTextStyle.contentWhite() : this(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500);

  const CustomTextStyle.contentGrey()
      : this(color: colorGreyTextSub, fontSize: 15, fontWeight: FontWeight.w500);

  const CustomTextStyle.contentRed() : this(color: Colors.red, fontSize: 15, fontWeight: FontWeight.w500);

  const CustomTextStyle.contentRedForErrorMessage()
      : this(color: Colors.red, fontSize: 15, fontWeight: FontWeight.w500, height: null);

  ///버튼에 들어가는 텍스트
  const CustomTextStyle.buttonWhite() : this(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700);

  const CustomTextStyle.buttonGrey()
      : this(color: const Color(0xff454c53), fontSize: 16, fontWeight: FontWeight.w700);

  const CustomTextStyle.buttonGreyDisable()
      : this(color: const Color(0xffD3D3D3), fontSize: 16, fontWeight: FontWeight.w700);

  const CustomTextStyle.buttonRed() : this(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w700);

  const CustomTextStyle.buttonBlack() : this(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700);

  const CustomTextStyle.buttonBlue() : this(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.w700);

  //차트에 들어가는 텍스트
  const CustomTextStyle.chartValueBlack()
      : this(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold);

  const CustomTextStyle.chartSingleTextBlack()
      : this(color: Colors.black, fontSize: 48, fontWeight: FontWeight.bold);

//
}
