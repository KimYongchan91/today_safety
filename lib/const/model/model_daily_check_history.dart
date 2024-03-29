import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiver/core.dart';

import '../../service/util/util_firestore.dart';
import '../value/key.dart';
import 'model_user_check_history.dart';

class ModelDailyCheckHistory {
  final String docId;
  final Timestamp date;
  final String dateDisplay;
  final int dateWeek;
  final int userCheckHistoryCount;

  //final List<ModelUserCheckHistory> listModelUserCheckHistory;

  ModelDailyCheckHistory.fromJson(Map json, this.docId)
      : date = getTimestampFromData(json[keyDate]) ?? Timestamp.now(),
        dateDisplay = json[keyDateDisplay] ?? '',
        dateWeek = json[keyDateWeek] ?? 1,
        userCheckHistoryCount = json[keyUserCheckHistoryCount] ?? 0;

  //listModelUserCheckHistory = getListModelUserCheckHistoryFromServer(json[keyUserCheckHistory] ?? []);

  @override
  bool operator ==(Object other) {
    return other is ModelDailyCheckHistory && other.docId == docId && other.dateDisplay == dateDisplay;
  }

  @override
  int get hashCode => hash2(docId, dateDisplay);
}
