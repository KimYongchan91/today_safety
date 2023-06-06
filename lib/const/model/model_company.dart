import 'package:today_safety/const/value/key.dart';

class ModelCompany {
  final String id;
  final String name;
  final String urlLogoImage;

  ModelCompany.fromJson(Map json)
      : id = json[keyId] ?? '',
        name = json[keyName] ?? '',
        urlLogoImage = json[keyUrlLogoImage] ?? '';

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {};

    result[keyId] = id;
    result[keyName] = name;
    result[keyUrlLogoImage] = urlLogoImage;
    return result;
  }
}
