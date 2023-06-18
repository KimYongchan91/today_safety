import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:today_safety/const/model/model_check_image.dart';
import 'package:today_safety/const/model/model_device.dart';
import 'package:today_safety/const/model/model_location.dart';
import 'package:today_safety/const/model/model_user.dart';
import 'package:today_safety/const/value/key.dart';
import 'package:today_safety/const/value/router.dart';

import '../../service/util/util_firestore.dart';

class ModelUserCheckHistory {
  String? docId;
  final String checkListId;
  final ModelUser modelUser;
  final Timestamp date;
  final String dateDisplay;
  final int dateWeek;
  final ModelLocation modelLocation;
  final ModelDevice modelDevice;
  final List<ModelCheckImage> listModelCheckImage;

  ModelUserCheckHistory({
    this.docId = '',
    required this.checkListId,
    required this.modelUser,
    required this.date,
    required this.dateDisplay,
    required this.dateWeek,
    required this.modelLocation,
    required this.modelDevice,
    required this.listModelCheckImage,
  });

  ModelUserCheckHistory.fromJson(Map json, {this.docId})
      : checkListId = json[keyCheckListId] ?? '',
        modelUser = ModelUser.fromJson(json[keyUser], json[keyUser]?[keyDocId] ?? ''),
        date = getTimestampFromData(json[keyDate]) ?? Timestamp.now(),
        dateDisplay = json[keyDateDisplay] ?? '',
        dateWeek = json[keyDateWeek] ?? 1,
        modelLocation = ModelLocation.fromJson(json[keyLocation] ?? {}),
        modelDevice = ModelDevice.fromJson(json[keyDevice] ?? {}),
        listModelCheckImage = getListModelCheckImageFromServer(json[keyImage]);

  Map<String, dynamic> toJson() {
    return {
      keyDocId: docId,
      keyCheckListId: checkListId,
      keyUser: modelUser.toJson(),
      keyDate: date,
      keyDateDisplay: dateDisplay,
      keyDateWeek: dateWeek,
      keyLocation: modelLocation.toJson(),
      keyDevice: modelDevice.toJson(),
      keyImage: getListModelCheckImageFromLocal(listModelCheckImage),
    };
  }
}
