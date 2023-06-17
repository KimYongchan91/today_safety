import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:today_safety/const/model/model_check_image.dart';
import 'package:today_safety/const/model/model_device.dart';
import 'package:today_safety/const/model/model_location.dart';
import 'package:today_safety/const/value/key.dart';
import 'package:today_safety/const/value/router.dart';

import '../../service/util/util_firestore.dart';

class ModelUserCheckHistory {
  final String checkListId;
  final String user;
  final Timestamp date;
  final ModelLocation modelLocation;
  final ModelDevice modelDevice;
  final List<ModelCheckImage> listModelCheckImage;

  ModelUserCheckHistory({
    required this.checkListId,
    required this.user,
    required this.date,
    required this.modelLocation,
    required this.modelDevice,
    required this.listModelCheckImage,
  });

  ModelUserCheckHistory.fromJson(Map json)
      : checkListId = json[keyCheckListId] ?? '',
        user = json[keyUser] ?? '',
        date = getTimestampFromData(json[keyDate]) ?? Timestamp.now(),
        modelLocation = ModelLocation.fromJson(json[keyLocation] ?? {}),
        modelDevice = ModelDevice.fromJson(json[keyDevice] ?? {}),
        listModelCheckImage = getListModelCheckImageFromServer(json[keyImage]);

  Map<String,dynamic> toJson(){
    return {
      keyCheckListId : checkListId,
      keyUser : user,
      keyDate : date,
      keyLocation : modelLocation.toJson(),
      keyDevice : modelDevice.toJson(),
      keyImage : getListModelCheckImageFromLocal(listModelCheckImage),
    };
  }
}
