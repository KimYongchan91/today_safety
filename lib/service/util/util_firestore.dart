import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:today_safety/const/model/model_check_image.dart';

import '../../const/model/model_check.dart';
import '../../const/model/model_user_check_history.dart';
import '../../my_app.dart';

Timestamp? getTimestampFromData(dynamic data) {
  if (data == null) {
    return null;
  }

  if (data is Timestamp) {
    return data;
  } else if (data is Map) {
    final seconds = data["_seconds"];
    final nanoseconds = data["_nanoseconds"];

    if (seconds == null || nanoseconds == null) {
      return null;
    }
    return Timestamp(seconds, nanoseconds);
  } else if (data is int) {
    return Timestamp.fromMillisecondsSinceEpoch(data);
  } else {
    return null;
  }
}

Map<String, dynamic> transformForServerDataType(Map<String, dynamic> mapOld) {
  Map<String, dynamic> mapNew = {...mapOld};
  for (var element in mapNew.keys) {
    if (mapNew[element] is Timestamp) {
      mapNew[element] = (mapNew[element] as Timestamp).millisecondsSinceEpoch;
    }
  }

  MyApp.logger.d("변경된 맵 : ${mapNew.toString()}");

  return mapNew;
}

///
List<ModelCheck> getListModelCheckFromServer(dynamic list) {
  List<ModelCheck> result = [];

  if (list is List) {
    for (var element in list) {
      result.add(ModelCheck.fromJson(element));
    }
  }

  return result;
}

dynamic getListModelCheckFromLocal(List<ModelCheck> list){
  List<dynamic> result = [];

  for (var element in list) {
    result.add(element.toJson());
  }


  return result;
}

///
List<ModelCheckImage> getListModelCheckImageFromServer(dynamic list) {
  List<ModelCheckImage> result = [];

  if (list is List) {
    for (var element in list) {
      result.add(ModelCheckImage.fromJson(element));
    }
  }

  return result;
}

dynamic getListModelCheckImageFromLocal(List<ModelCheckImage> list){
  List<dynamic> result = [];

  for (var element in list) {
    result.add(element.toJson());
  }


  return result;
}

///
List<ModelUserCheckHistory> getListModelUserCheckHistoryFromServer(dynamic list) {
  List<ModelUserCheckHistory> result = [];

  if (list is List) {
    for (var element in list) {
      result.add(ModelUserCheckHistory.fromJson(element));
    }
  }

  return result;
}

dynamic getListModelUserCheckHistoryFromLocal(List<ModelUserCheckHistory> list){
  List<dynamic> result = [];

  for (var element in list) {
    result.add(element.toJson());
  }


  return result;
}