import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiver/core.dart';

import '../../service/util/util_firestore.dart';
import '../value/key.dart';

class ModelCheckHistory {
  final String name;
  final Timestamp date;

  ///fac = fac code임
  ///사용자 지정 check라면 null
  final String? fac;
  final String urlCheckImage;
  final String cameraDirection;

  ModelCheckHistory({
    required this.name,
    required this.date,
    required this.fac,
    required this.urlCheckImage,
    required this.cameraDirection,
  });

  ModelCheckHistory.fromJson(Map map)

      ///유저 13
      : name = map[keyName] ?? '',
        date = getTimestampFromData(map[keyDate]) ?? Timestamp.now(),
        fac = map[keyFac],
        urlCheckImage = map[keyUrlCheckImage] ?? '',
        cameraDirection = map[keyCameraDirection] ?? '';

  Map<String, dynamic> toJson({bool isForServerForm = false}) {
    Map<String, dynamic> result = {
      keyName: name,
      keyDate: date,
      keyFac: fac,
      keyUrlCheckImage: urlCheckImage,
      keyCameraDirection: cameraDirection,
    };

    return isForServerForm ? transformForServerDataType(result) : result;
  }

  @override
  bool operator ==(Object other) {
    return other is ModelCheckHistory && other.name == name;
  }

  @override
  int get hashCode => hash2(name, fac);
}
