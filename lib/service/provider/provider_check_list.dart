import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:today_safety/const/model/model_site.dart';

import '../../const/model/model_check_list.dart';
import '../../const/value/key.dart';

class ProviderCheckList extends ChangeNotifier {
  final ModelSite modelSite;
  List<ModelCheckList> listModelCheckList = [];
  StreamSubscription? subscriptionCheckList;

  ProviderCheckList(this.modelSite) {
    _openStream();
  }

  _openStream() {
    subscriptionCheckList = FirebaseFirestore.instance
        .collection(keyCheckListS)
        .where('$keySite.$keyDocId', isEqualTo: modelSite.docId)
        .orderBy('$keySite.$keyDate', descending: false)
        .snapshots()
        .listen((event) {
      for (var element in event.docChanges) {
        switch (element.type) {
          case DocumentChangeType.added:
          case DocumentChangeType.modified:
            ModelCheckList modelCheckList =
                ModelCheckList.fromJson(element.doc.data() as Map, element.doc.id);
            listModelCheckList.add(modelCheckList);
            notifyListeners();
            break;
          case DocumentChangeType.removed:
            listModelCheckList.removeWhere((e) => element.doc.id == e.docId);
            notifyListeners();
            break;
        }
      }
    });
  }

  clearProvider() {
    subscriptionCheckList?.cancel();
    listModelCheckList.clear();
  }
}
