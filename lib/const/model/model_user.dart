import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiver/core.dart';
import 'package:today_safety/const/value/key.dart';

import '../../service/util/util_firestore.dart';

class ModelUser {
  final String docId;
  final String id;
  final String state;
  final Timestamp dateJoin;

  ModelUser({
    this.docId = '',
    required this.id,
    required this.state,
    required this.dateJoin,
  });

  ModelUser.fromJson(Map map, this.docId)

      ///유저 13
      : id = map[keyId] ?? '',
        state = map[keyState] ?? '',
        dateJoin = getTimestampFromData(map[keyDateJoin]) ?? Timestamp.now();

  Map<String, dynamic> toJson() {
    return {
      keyDocId: docId,
      keyId: id,
      keyState: state,
      keyDateJoin: dateJoin,
    };
  }

  @override
  operator ==(other) => other is ModelUser && docId == other.docId && id == other.id;

  @override
  int get hashCode => hash2(docId, id);
}
