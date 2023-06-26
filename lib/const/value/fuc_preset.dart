import '../model/model_fuc_preset.dart';
import 'fuc.dart';

/// fuc : Frequently Used Checklist

///fuc 프리셋 이미지 파일 기본 주소
const String _pathBaseFucPresetImage = 'assets/images/fuc_preset';

///fuc 프리셋 코드
const String keyWorkWithElectric = 'work_with_electric';
const String keyWorkWithChemical = 'work_with_chemical';
const String keyWorkOnWater = 'work_on_water';
const String keyWorkAtHeight = 'work_at_height';

///fuc 프리셋 코드 전체 리스트
///바로 위의 모든 코드를 추가해야 함
const List<String> listAllFucPresetCode = [
  keyWorkWithElectric,
  keyWorkWithChemical,
  keyWorkOnWater,
  keyWorkAtHeight,
];

///fuc 프리셋 코드 -> fuc 리스트
///예로 고소 작업 -> [안전모 착용, 안전 표지판 설치]
///바로 위의 모든 코드를 추가해야 함
const Map<String, List<String>> mapFucPresetToFuc = {
  keyWorkWithElectric: [
    keyWearSafetyHelmet,
    keyWearInsulatedGloves,
    keyWearInsulatedShoes,
    keySetSafetySign,
  ],
  keyWorkWithChemical: [
    keyWearSafetyGlasses,
    keyWearSafetyGloves,
    keyWearSafetyMask,
    keySetSafetySign,
  ],
  keyWorkOnWater: [
    keyWearLifeJacket,
    keySetLifeTube,
  ],
  keyWorkAtHeight: [
    keyWearSafetyHelmet,
    keyWearSafetyRope,
    keySetSafetySign,
  ],
};

///프리셋 코드를 받아 fuc 프리셋 모델을 반환
ModelFucPreset getModelFucPreset(String code) {
  switch (code) {

    case keyWorkWithElectric:
      return ModelFucPreset('전기 취급 작업', keyWorkWithElectric);

    case keyWorkWithChemical:
      return ModelFucPreset('화학물 취급 작업', keyWorkWithChemical);

    case keyWorkOnWater:
      return ModelFucPreset('수상 작업', keyWorkOnWater);

    case keyWorkAtHeight:
      return ModelFucPreset('고소 작업', keyWorkAtHeight);

    default:
      return ModelFucPreset('고소 작업', keyWorkAtHeight);
  }
}

/// fuc 프리셋 모델의 이미지 파일 주소를 반환
/// png
String getPathFucPresetImage(ModelFucPreset modelFucPreset) {
  String path = "$_pathBaseFucPresetImage/${modelFucPreset.code}.png";
  return path;
}
