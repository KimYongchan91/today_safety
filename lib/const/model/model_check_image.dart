import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiver/core.dart';

import '../../service/util/util_firestore.dart';
import '../value/key.dart';

class ModelCheckImage {
  final String name;
  final Timestamp date;

  ///fac = fac code임
  ///사용자 지정 check라면 null
  final String? fac;
  String urlImage;
  final String cameraDirection;

  ModelCheckImage({
    required this.name,
    required this.date,
    required this.fac,
    required this.urlImage,
    required this.cameraDirection,
  });

  ModelCheckImage.fromJson(Map map)

      ///유저 13
      : name = map[keyName] ?? '',
        date = getTimestampFromData(map[keyDate]) ?? Timestamp.now(),
        fac = map[keyFac],
        urlImage = map[keyUrlImage] ?? '',
        cameraDirection = map[keyCameraDirection] ?? '';

  Map<String, dynamic> toJson({bool isForServerForm = false}) {
    Map<String, dynamic> result = {
      keyName: name,
      keyDate: date,
      keyFac: fac,
      keyUrlImage: urlImage,
      keyCameraDirection: cameraDirection,
    };

    return isForServerForm ? transformForServerDataType(result) : result;
  }

  @override
  bool operator ==(Object other) {
    return other is ModelCheckImage && other.name == name;
  }

  @override
  int get hashCode => hash2(name, fac);
}
