import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:today_safety/const/model/model_check.dart';

///check 이미지 파일 기본 주소
const String _pathBaseFucImage = 'assets/images/fuc';

///check 코드
const String keyWearSafetyHelmet = 'wear_safety_helmet';
const String keyWearInsulatedGloves = 'wear_insulated_gloves';
const String keyWearInsulatedShoes = 'wear_insulated_shoes';
const String keySetSafetySign = 'set_safety_sign';

///check 코드를 받아 check 모델을 반환
ModelCheck getModelCheck(String code) {
  switch (code) {
    case keyWearSafetyHelmet:
      return ModelCheck(name: '안전모 착용', fac: keyWearSafetyHelmet, date: Timestamp.now());

    case keyWearInsulatedGloves:
      return ModelCheck(name: '절연 장갑 착용', fac: keyWearInsulatedGloves, date: Timestamp.now());

    case keyWearInsulatedShoes:
      return ModelCheck(name: '절연 안전화 착용', fac: keyWearInsulatedShoes, date: Timestamp.now());

    case keySetSafetySign:
      return ModelCheck(name: '안전 표지판 설치', fac: keySetSafetySign, date: Timestamp.now());

    default:
      return ModelCheck(name: '안전모 착용', fac: keyWearSafetyHelmet, date: Timestamp.now());
  }
}

/// check 모델의 이미지 파일 주소를 반환
String getPathCheckImage(ModelCheck modelCheck) {
  String path = "$_pathBaseFucImage/${modelCheck.fac}.png";
  return path;
}
