import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:today_safety/const/model/model_constraint_location.dart';
import 'package:today_safety/const/model/model_site.dart';

import '../../service/util/util_firestore.dart';
import '../value/key.dart';
import 'model_check.dart';
import 'model_constraint_time.dart';

class ModelCheckList {
  final String docId;
  final String name;
  final Timestamp date;
  final ModelSite modelSite;

  final ModelConstraintLocation? modelConstraintLocation;
  final ModelConstraintTime? modelConstraintTime;

  final List<ModelCheck> listModelCheck;

  ModelCheckList({
    required this.docId,
    required this.name,
    required this.date,
    required this.modelSite,
    this.modelConstraintLocation,
    this.modelConstraintTime,
    required this.listModelCheck,
  });

  ModelCheckList.fromJson(Map map, this.docId)
      : name = map[keyName] ?? '',
        date = getTimestampFromData(map[keyDate]) ?? Timestamp.now(),
        modelSite = ModelSite.fromJson(map[keySite], map[keySite][keyDocId] ?? ''),
        modelConstraintLocation =
            map[keyConstraintLocation] != null ? ModelConstraintLocation.fromJson(map[keyConstraintLocation]) : null,
        modelConstraintTime =
            map[keyConstraintTime] != null ? ModelConstraintTime.fromJson(map[keyConstraintTime]) : null,
        listModelCheck = getListModelCheckFromServer(map[keyCheckList]);

  Map<String, dynamic> toJson({bool isForServerForm = false}) {
    Map<String, dynamic> result = {
      keyName: name,
      keyDate: date,
      keySite: modelSite.toJson(isIncludeDocID: true),
      keyConstraintLocation: modelConstraintLocation?.toJson(),
      keyConstraintTime: modelConstraintTime?.toJson(),
      keyCheckList: getListModelCheckFromLocal(listModelCheck),
    };

    return isForServerForm ? transformForServerDataType(result) : result;
  }
}
