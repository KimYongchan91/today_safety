import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:today_safety/const/model/model_check.dart';

///check 이미지 파일 기본 주소
const String _pathBaseFucImage = 'assets/images/fuc';

///check 코드
//고소 작업
const String keyWearSafetyHelmet = 'wear_safety_helmet';
const String keyWearSafetyRope = 'wear_safety_rope';

//전기 작업
const String keyWearInsulatedGloves = 'wear_insulated_gloves';
const String keyWearInsulatedShoes = 'wear_insulated_shoes';

//공통
const String keySetSafetySign = 'set_safety_sign';

//화학물 취급 작업
const String keyWearSafetyGlasses = 'wear_safety_glasses';
const String keyWearSafetyGloves = 'wear_safety_gloves';
const String keyWearSafetyMask = 'wear_safety_mask';

//수상 작업
const String keyWearLifeJacket = 'wear_life_jacket';
const String keySetLifeTube = 'set_life_tube';

///fuc 코드 전체 리스트
///바로 위의 모든 코드를 추가해야 함
const List<String> listAllFucCode = [
  keyWearSafetyHelmet,
  keyWearSafetyRope,
  keyWearInsulatedGloves,
  keyWearInsulatedShoes,
  keySetSafetySign,
  keyWearSafetyGlasses,
  keyWearSafetyGloves,
  keyWearSafetyMask,
  keyWearLifeJacket,
  keySetLifeTube,
];

///check 코드를 받아 check 모델을 반환
ModelCheck getModelCheck(String code) {
  switch (code) {
    case keyWearSafetyHelmet:
      return ModelCheck(name: '안전모 착용', fac: keyWearSafetyHelmet, date: Timestamp.now());

    case keyWearSafetyRope:
      return ModelCheck(name: '안전 로프 착용', fac: keyWearSafetyRope, date: Timestamp.now());

    case keyWearInsulatedGloves:
      return ModelCheck(name: '절연 장갑 착용', fac: keyWearInsulatedGloves, date: Timestamp.now());

    case keyWearInsulatedShoes:
      return ModelCheck(name: '절연 안전화 착용', fac: keyWearInsulatedShoes, date: Timestamp.now());

    case keySetSafetySign:
      return ModelCheck(name: '안전 표지판 설치', fac: keySetSafetySign, date: Timestamp.now());

    case keyWearSafetyGlasses:
      return ModelCheck(name: '보안경 착용', fac: keyWearSafetyGlasses, date: Timestamp.now());

    case keyWearSafetyGloves:
      return ModelCheck(name: '장갑 착용', fac: keyWearSafetyGloves, date: Timestamp.now());

    case keyWearSafetyMask:
      return ModelCheck(name: '마스크 착용', fac: keyWearSafetyMask, date: Timestamp.now());

    case keyWearLifeJacket:
      return ModelCheck(name: '구명 조끼 착용', fac: keyWearLifeJacket, date: Timestamp.now());

    case keySetLifeTube:
      return ModelCheck(name: '구명 튜브 구비', fac: keySetLifeTube, date: Timestamp.now());

    default:
      return ModelCheck(name: '안전모 착용', fac: keyWearSafetyHelmet, date: Timestamp.now());
  }
}

/// check 모델의 이미지 파일 주소를 반환
String getPathCheckImage(ModelCheck modelCheck) {
  String path = "$_pathBaseFucImage/${modelCheck.fac}.png";
  return path;
}
