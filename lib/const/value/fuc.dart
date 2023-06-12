import '../model/model_fuc.dart';

/// fuc : Frequently Used Checklist

/*
고소 작업 : work_at_height
전기 관련 작업 : work_with_electric
*/

///fuc 이미지 파일 기본 주소
const String _pathBaseFucImage = 'assets/images/fuc';
//assets/images/fuc/work_with_electric.png

///fuc 코드
const String keyWearSafetyHelmet = 'wear_safety_helmet';
const String keyWearInsulatedGloves = 'wear_insulated_gloves';
const String keyWearInsulatedShoes = 'wear_insulated_shoes';
const String keySetSafetySign = 'set_safety_sign';

///fuc 코드 리스트
///바로 위의 모든 코드를 추가해야 함
const List<String> listAllFucCode = [
  keyWearSafetyHelmet,
  keySetSafetySign,
];

///프리셋 코드를 받아 fuc 프리셋 모델을 반환
ModelFuc getModelFuc(String code) {
  switch (code) {
    case keyWearSafetyHelmet:
      return ModelFuc('안전모 착용', keyWearSafetyHelmet);

    case keyWearInsulatedGloves:
      return ModelFuc('절연 장갑 착용', keyWearInsulatedGloves);

    case keyWearInsulatedShoes:
      return ModelFuc('절연 안전화 착용', keyWearInsulatedShoes);

    case keySetSafetySign:
      return ModelFuc('안전 표지판 설치', keySetSafetySign);

    default:
      return ModelFuc('안전모 착용', keyWearSafetyHelmet);
  }
}

/// fuc 프리셋 모델의 이미지 파일 주소를 반환
/// png
/// 없으면 '';
String getPathFucImage(ModelFuc modelFuc) {
  String path = "$_pathBaseFucImage/${modelFuc.code}.png";
  return path;
}
