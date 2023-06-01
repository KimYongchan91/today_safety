import 'package:cloud_firestore/cloud_firestore.dart';

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