import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiver/core.dart';
import 'package:today_safety/const/model/model_company.dart';
import 'package:today_safety/const/model/model_location.dart';
import 'package:today_safety/const/value/key.dart';

import '../../service/util/util_firestore.dart';

class ModelSite {
  final String docId;
  final String name;
  final Timestamp date;
  final ModelLocation modelLocation;
  final int userCount;
  final ModelCompany modelCompany;

  ModelSite.fromJson(Map map, this.docId)

      ///유저 13
      : name = map[keyName] ?? '',
        date = getTimestampFromData(map[keyDate]) ?? Timestamp.now(),
        modelLocation = ModelLocation.fromJson(map[keyLocation]),
        userCount = map[keyUserCount] ?? 0,
        modelCompany = ModelCompany.fromJson(map[keyCompany]);

  Map<String, dynamic> toJson({bool isForServerForm = false}) {
    Map<String, dynamic> result = {
      //keyDocId: docId,
      keyName: name,
      keyDate: date,
      keyLocation: modelLocation.toJson(),
      keyUserCount: userCount,
      keyCompany: modelCompany.toJson(),
    };

    return isForServerForm ? transformForServerDataType(result) : result;
  }

  @override
  operator ==(other) => other is ModelSite && docId == other.docId && date == other.date;

  @override
  int get hashCode => hash2(docId, date);
}
