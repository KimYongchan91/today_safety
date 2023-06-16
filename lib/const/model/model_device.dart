import 'package:today_safety/const/value/key.dart';

class ModelDevice {
  String model;
  String os;
  String osVersion;

  ModelDevice({
    required this.model,
    required this.os,
    required this.osVersion,
  });

  ModelDevice.fromJson(Map json)
      : model = json[keyModel] ?? '',
        os = json[keyOs] ?? '',
        osVersion = json[keyOsVersion] ?? '';

  Map<String, dynamic> toJson() {
    return {
      keyModel: model,
      keyOs: os,
      keyOsVersion: osVersion,
    };
  }
}
