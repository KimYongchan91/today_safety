import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiver/core.dart';
import 'package:today_safety/const/model/model_company.dart';
import 'package:today_safety/const/model/model_location.dart';
import 'package:today_safety/const/value/key.dart';
import 'package:today_safety/const/value/value.dart';
import 'package:today_safety/my_app.dart';

import '../../service/util/util_firestore.dart';

class ModelSite {
  final String docId;
  String name;
  Timestamp date;
  String master;
  ModelLocation modelLocation;
  int userCount;
  String urlLogoImage;
  String urlSiteImage;

  ModelSite.fromJson(Map map, this.docId)

      ///유저 13
      : name = map[keyName] ?? '',
        date = getTimestampFromData(map[keyDate]) ?? Timestamp.now(),
        master = map[keyMaster] ?? '',
        modelLocation = ModelLocation.fromJson(map[keyLocation] ?? {}),
        userCount = map[keyUserCount] ?? 1,
        urlLogoImage = map[keyUrlLogoImage] ?? '',
        urlSiteImage = map[keyUrlSiteImage] ?? '';

  Map<String, dynamic> toJson({bool isIncludeDocID = false, bool isForServerForm = false}) {
    Map<String, dynamic> result = {
      //keyDocId: docId,
      keyName: name,
      keyDate: date,
      keyMaster: master,
      keyLocation: modelLocation.toJson(),
      keyUserCount: userCount,
      keyUrlLogoImage: urlLogoImage,
      keyUrlSiteImage: urlSiteImage,
    };

    if (isIncludeDocID) {
      result[keyDocId] = docId;
    }

    return isForServerForm ? transformForServerDataType(result) : result;
  }

  bool getIsEmpty() {
    MyApp.logger.d(""
        "name.isNotEmpty : ${name.isNotEmpty}"
        "modelLocation.lat != null : ${modelLocation.lat == defaultLat}"
        "modelLocation.lat != 0 : ${modelLocation.lat != 0}"
        "urlLogoImage.isNotEmpty : ${urlLogoImage.isNotEmpty}");
    return name.isEmpty && modelLocation.lat == defaultLat && urlLogoImage.isEmpty && urlSiteImage.isEmpty;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelSite && runtimeType == other.runtimeType && docId == other.docId;

  @override
  int get hashCode => docId.hashCode;
}
