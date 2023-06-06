import 'package:today_safety/const/value/key.dart';

class ModelLocation {
  final double? lat;
  final double? lng;

  final String? gh4;
  final String? gh5;
  final String? gh6;
  final String? gh7;

  final String? si;
  final String? gu;
  final String? dong;

  ModelLocation.fromJson(Map json)
      : lat = json[keyLat],
        lng = json[keyLng],
        gh4 = json[keyGh4],
        gh5 = json[keyGh5],
        gh6 = json[keyGh6],
        gh7 = json[keyGh7],
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
    result[keySi] = si;
    result[keyGu] = gu;
    result[keyDong] = dong;

    return result;
  }
}
