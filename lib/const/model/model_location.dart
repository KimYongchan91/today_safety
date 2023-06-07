import 'package:today_safety/const/value/key.dart';

class ModelLocation {
  double? lat;
  double? lng;

  String? gh4;
  String? gh5;
  String? gh6;
  String? gh7;

  String? si;
  String? gu;
  String? dong;
  String? addressLoad;
  String? addressJibun;
  String? addressBuildingName;

  ModelLocation.fromJson(Map json)
      : lat = json[keyLat],
        lng = json[keyLng],
        gh4 = json[keyGh4],
        gh5 = json[keyGh5],
        gh6 = json[keyGh6],
        gh7 = json[keyGh7],
        addressLoad = json[keyAddressLoad],
        addressJibun = json[keyAddressJibun],
        addressBuildingName = json[keyAddressBuildingName],
        si = json[keySi],
        gu = json[keyGu],
        dong = json[keyDong];

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

    return result;
  }
}
