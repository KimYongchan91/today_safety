import 'package:flutter/material.dart';


//폰트 사이즈
const double _fsSmall = 13;
const double _fsNormal = 16;
const double _fsBig = 20;
const double _fsLarge = 40;
const double _fsExtraLarge = 48;

const FontWeight _fwNormal = FontWeight.w400;
const FontWeight _fwBold = FontWeight.w700;

const Color _fcWhite = Colors.white;
const Color _fcBlack = Colors.black;
const Color _fcGrey = Colors.grey;
const Color _fcDisabled = Color(0xffD3D3D3);
const Color _fcRed = Colors.red;
const Color _fcBlue = Colors.blue;

class CustomTextStyle extends TextStyle {
  const CustomTextStyle({
    required Color color,
    required double fontSize,
    required FontWeight fontWeight,
    String fontFamily = 'Pretendard',
    double? height = 1.2,
  }) : super(
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontFamily: fontFamily,
    height: height,
  );

  ///일반 텍스트
  const CustomTextStyle.normalBlack() : this(color: _fcBlack, fontSize: _fsNormal, fontWeight: _fwNormal);

  const CustomTextStyle.normalBlue() : this(color: _fcBlue, fontSize: _fsNormal, fontWeight: _fwNormal);

  const CustomTextStyle.normalWhite() : this(color: _fcWhite, fontSize: _fsNormal, fontWeight: _fwNormal);

  const CustomTextStyle.normalGrey() : this(color: _fcGrey, fontSize: _fsNormal, fontWeight: _fwNormal);

  const CustomTextStyle.normalRedErrorMessage()
      : this(color: _fcRed, fontSize: _fsNormal, fontWeight: _fwNormal, height: null);

  const CustomTextStyle.normalWhiteBold() : this(color: _fcWhite, fontSize: _fsNormal, fontWeight: _fwBold);

  const CustomTextStyle.normalGreyBold() : this(color: _fcGrey, fontSize: _fsNormal, fontWeight: _fwBold);

  const CustomTextStyle.normalDisabledBold()
      : this(color: _fcDisabled, fontSize: _fsNormal, fontWeight: _fwBold);

  const CustomTextStyle.normalRedBold() : this(color: _fcRed, fontSize: _fsNormal, fontWeight: _fwBold);

  const CustomTextStyle.normalBlackBold() : this(color: _fcBlack, fontSize: _fsNormal, fontWeight: _fwBold);

  const CustomTextStyle.normalBlueBold() : this(color: _fcBlue, fontSize: _fsNormal, fontWeight: _fwBold);

  ///라벨 텍스트(text field 위에)
  const CustomTextStyle.normalGreyTextFieldLabel()
      : this(color: _fcGrey, fontSize: _fsNormal, fontWeight: _fwNormal);

  ///큰 텍스트
  const CustomTextStyle.bigBlack() : this(color: _fcBlack, fontSize: _fsBig, fontWeight: _fwNormal);

  const CustomTextStyle.bigBlackBold() : this(color: _fcBlack, fontSize: _fsBig, fontWeight: _fwBold);

  ///엄청 큰 텍스크
  const CustomTextStyle.largeBlackBold() : this(color: _fcBlack, fontSize: _fsLarge, fontWeight: _fwBold);

  ///차트에 들어가는 텍스트
  const CustomTextStyle.smallBlackBold() : this(color: _fcBlack, fontSize: _fsSmall, fontWeight: _fwBold);

  const CustomTextStyle.extraLargeBlackBold()
      : this(color: _fcBlack, fontSize: _fsExtraLarge, fontWeight: _fwBold);

//
}
