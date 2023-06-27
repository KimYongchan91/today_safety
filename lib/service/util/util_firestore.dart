import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:today_safety/const/model/model_check_image.dart';
import 'package:today_safety/const/model/model_check_list.dart';
import 'package:today_safety/const/value/key.dart';

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
  for (var key in mapNew.keys) {
    dynamic value = mapNew[key];
    if (value is Map) {
      //타입이 맵이라면
      //또 한번 변환
      value = transformForServerDataType(value as Map<String, dynamic>);
    } else if (value is List) {
      //리스트라면
      //죄다 변환
      for (var element in value) {
        element = transformForServerDataType(element);
      }
    } else {
      //맵도 아니고 리스트도 아니면
      //비로소 변환
      if (mapNew[key] is Timestamp) {
        mapNew[key] = (mapNew[key] as Timestamp).millisecondsSinceEpoch;
      }
    }
  }

  //MyApp.logger.d("변경된 맵 : ${mapNew.toString()}");

  return mapNew;
}

Map<String, dynamic> _transformMap(Map mapOld) {
  Map<String, dynamic> mapNew = {...mapOld};
  for (var element in mapNew.keys) {
    if (mapNew[element] is Timestamp) {
      mapNew[element] = (mapNew[element] as Timestamp).millisecondsSinceEpoch;
    }
  }
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

dynamic getListModelCheckFromLocal(List<ModelCheck> list) {
  List<dynamic> result = [];

  for (var element in list) {
    result.add(element.toJson());
  }

  return result;
}

///ModelCheckImage
List<ModelCheckImage> getListModelCheckImageFromServer(dynamic list) {
  List<ModelCheckImage> result = [];

  if (list is List) {
    for (var element in list) {
      result.add(ModelCheckImage.fromJson(element));
    }
  }

  return result;
}

dynamic getListModelCheckImageFromLocal(List<ModelCheckImage> list) {
  List<dynamic> result = [];

  for (var element in list) {
    result.add(element.toJson());
  }

  return result;
}

///ModelUserCheckHistory
List<ModelUserCheckHistory> getListModelUserCheckHistoryFromServer(dynamic list) {
  List<ModelUserCheckHistory> result = [];

  if (list is List) {
    for (var element in list) {
      result.add(ModelUserCheckHistory.fromJson(element));
    }
  }

  return result;
}

dynamic getListModelUserCheckHistoryFromLocal(List<ModelUserCheckHistory> list) {
  List<dynamic> result = [];

  for (var element in list) {
    result.add(element.toJson());
  }

  return result;
}

///ModelCheckList
List<ModelCheckList> getListModelCheckListFromServer(dynamic list) {
  List<ModelCheckList> result = [];

  if (list != null && list is List) {
    for (var element in list) {
      result.add(ModelCheckList.fromJson(element, element[keyDocId] ?? ''));
    }
  }

  return result;
}

dynamic getModelCheckListFromLocal(List<ModelCheckList> list) {
  List<dynamic> result = [];

  for (var element in list) {
    result.add(element.toJson());
  }

  return result;
}
