import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:today_safety/const/model/model_site.dart';
import 'package:today_safety/const/value/key.dart';

import '../../const/model/model_notice.dart';

class ProviderNotice extends ChangeNotifier {
  final ModelSite modelSite;

  ProviderNotice(this.modelSite) {
    init();
  }

  List<ModelNotice> listModelNotice = [];
  StreamSubscription? subscription;

  init() {
    subscription = FirebaseFirestore.instance
        .collection(keyNoticeS)
        .where('$keyCheckList.$keyDocId', isEqualTo: modelSite.docId)
        .orderBy(keyDate, descending: true)
        .snapshots()
        .listen((event) {
      for (var element in event.docChanges) {
        ModelNotice modelNotice = ModelNotice.fromJson(element.doc.data() as Map, element.doc.id);
        switch (element.type) {
          case DocumentChangeType.added:
            listModelNotice.add(modelNotice);
            break;
          case DocumentChangeType.modified:
            int index = listModelNotice.indexOf(modelNotice); //doc_id, date는 안 바뀐다는 전제 하에
            listModelNotice[index] = modelNotice;
            break;
          case DocumentChangeType.removed:
            listModelNotice.removeWhere((element) => element == modelNotice);
            break;
        }

        notifyListeners();
      }
    });
  }

  clearProvider() {
    subscription?.cancel();
  }
}
