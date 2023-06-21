import 'package:today_safety/const/value/key.dart';
import 'package:today_safety/const/value/value.dart';

class ModelLocation {
  double lat;
  double lng;

  String gh4;
  String gh5;
  String gh6;
  String gh7;

  String si;
  String gu;
  String dong;
  String? addressLoad;
  String? addressJibun;
  String? addressBuildingName;

  String? code;

  ModelLocation({
    required this.lat,
    required this.lng,
    required this.gh4,
    required this.gh5,
    required this.gh6,
    required this.gh7,
    required this.si,
    required this.gu,
    required this.dong,
    this.addressLoad,
    this.addressJibun,
    this.addressBuildingName,
    this.code,
  }); //행정 구역 코드 (H)

  ModelLocation.fromJson(Map json)
      : lat = json[keyLat] ?? defaultLat,
        lng = json[keyLng] ?? defaultLng,
        gh4 = json[keyGh4] ?? defaultGH4,
        gh5 = json[keyGh5] ?? defaultGH5,
        gh6 = json[keyGh6] ?? defaultGH6,
        gh7 = json[keyGh7] ?? defaultGH7,
        addressLoad = json[keyAddressLoad],
        addressJibun = json[keyAddressJibun],
        addressBuildingName = json[keyAddressBuildingName],
        si = json[keySi] ?? defaultSi,
        gu = json[keyGu] ?? defaultGu,
        dong = json[keyDong] ?? defaultDong,
        code = json[keyCode];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {};

    result[keyLat] = lat;
    result[keyLng] = lng;
    result[keyGh4] = gh4;
    result[keyGh5] = gh5;
    result[keyGh6] = gh6;
    result[keyGh7] = gh7;
    result[keyAddressLoad] = addressLoad;
    result[keyAddressJibun] = addressJibun;
    result[keyAddressBuildingName] = addressBuildingName;
    result[keySi] = si;
    result[keyGu] = gu;
    result[keyDong] = dong;
    result[keyCode] = code;
    return result;
  }
}
