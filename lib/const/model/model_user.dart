import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiver/core.dart';
import 'package:today_safety/const/value/key.dart';

import '../../service/util/util_firestore.dart';

class ModelUser {
  final String docId;
  final String id;
  final String idExceptLT;
  final String name;
  final String loginType;
  final String state;
  final Timestamp dateJoin;
  List<dynamic> listToken = [];

  ModelUser({
    this.docId = '',
    required this.id,
    required this.idExceptLT,
    required this.name,
    required this.loginType,
    required this.state,
    required this.dateJoin,
  });

  ModelUser.fromJson(Map map, this.docId)

      ///유저 13
      : id = map[keyId] ?? '',
        idExceptLT = map[keyIdExceptLT] ?? '',
        name = map[keyName] ?? '',
        loginType = map[keyLoginType] ?? '',
        state = map[keyState] ?? '',
        dateJoin = getTimestampFromData(map[keyDateJoin]) ?? Timestamp.now(),
        listToken = map[keyToken] ?? [];

  Map<String, dynamic> toJson({bool isForServerForm = false}) {
    Map<String, dynamic> result = {
      //keyDocId: docId,
      keyId: id,
      keyIdExceptLT: idExceptLT,
      keyName: name,
      keyLoginType: loginType,
      keyState: state,
      keyDateJoin: dateJoin,
      keyToken: listToken,
    };

    return isForServerForm ? transformForServerDataType(result) : result;
  }

  @override
  operator ==(other) => other is ModelUser && docId == other.docId && id == other.id;

  @override
  int get hashCode => hash2(docId, id);
}
