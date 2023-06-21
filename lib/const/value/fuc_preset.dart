import '../model/model_fuc_preset.dart';
import 'fuc.dart';

/// fuc : Frequently Used Checklist

///fuc 프리셋 이미지 파일 기본 주소
const String _pathBaseFucPresetImage = 'assets/images/fuc_preset';

///fuc 프리셋 코드
const String keyWorkAtHeight = 'work_at_height';
const String keyWorkWithElectric = 'work_with_electric';

///fuc 프리셋 코드 전체 리스트
///바로 위의 모든 코드를 추가해야 함
const List<String> listAllFucPresetCode = [
  keyWorkAtHeight,
  keyWorkWithElectric,
];

///fuc 프리셋 코드 -> fuc 리스트
///예로 고소 작업 -> [안전모 착용, 안전 표지판 설치]
///바로 위의 모든 코드를 추가해야 함
const Map<String, List<String>> mapFucPresetToFuc = {
  keyWorkAtHeight: [
    keyWearSafetyHelmet,
    keySetSafetySign,
  ],
  keyWorkWithElectric: [
    keyWearSafetyHelmet,
    keyWearInsulatedGloves,
    keyWearInsulatedShoes,
    keySetSafetySign,
  ],
};

///프리셋 코드를 받아 fuc 프리셋 모델을 반환
ModelFucPreset getModelFucPreset(String code) {
  switch (code) {
    case keyWorkAtHeight:
      return ModelFucPreset('고소 작업', keyWorkAtHeight);

    case keyWorkWithElectric:
      return ModelFucPreset('전기 작업', keyWorkWithElectric);

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
