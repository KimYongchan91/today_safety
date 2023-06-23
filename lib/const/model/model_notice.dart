import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:today_safety/const/model/model_check_list.dart';
import 'package:today_safety/const/model/model_site.dart';
import 'package:today_safety/const/value/key.dart';

import '../../service/util/util_firestore.dart';

class ModelNotice {
  final String docId;
  final ModelSite modelSite;
  final List<ModelCheckList> listModelCheckList;
  final Timestamp date;
  final String title;
  final String body;
  final bool isSendFcm;

  ModelNotice({
    this.docId = '',
    required this.modelSite,
    required this.listModelCheckList,
    required this.date,
    required this.title,
    required this.body,
    required this.isSendFcm,
  });

  ModelNotice.fromJson(Map map, this.docId)
      : modelSite = ModelSite.fromJson(map[keySite] ?? {}, ''),
        listModelCheckList = getListModelCheckListFromServer(map[keyCheckList]),
        date = getTimestampFromData(map[keyDate]) ?? Timestamp.now(),
        title = map[keyTitle] ?? '',
        body = map[keyBody] ?? '',
        isSendFcm = map[keyIsSendFcm] ?? false;

  Map<String, dynamic> toJson({bool isIncludeDocID = false, bool isForServerForm = false}) {
    Map<String, dynamic> result = {
      //keyDocId: docId,
      keySite: modelSite.toJson(isIncludeDocID: true),
      keyCheckList: getModelCheckListFromLocal(listModelCheckList),
      keyDate: date,
      keyTitle: title,
      keyBody: body,
      keyIsSendFcm: isSendFcm,
    };

    if (isIncludeDocID) {
      result[keyDocId] = docId;
    }

    return isForServerForm ? transformForServerDataType(result) : result;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelNotice && runtimeType == other.runtimeType && docId == other.docId && date == other.date;

  @override
  int get hashCode => docId.hashCode ^ date.hashCode;
}
