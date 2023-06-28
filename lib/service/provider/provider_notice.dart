import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:today_safety/const/model/model_site.dart';
import 'package:today_safety/const/value/key.dart';

import '../../const/model/model_check_list.dart';
import '../../const/model/model_notice.dart';
import '../../my_app.dart';

class ProviderNotice extends ChangeNotifier {
  final ModelSite modelSite;
  final ModelCheckList? modelCheckListTarget;

  ProviderNotice(this.modelSite, {this.modelCheckListTarget}) {
    init();
  }

  List<ModelNotice> listModelNotice = [];
  StreamSubscription? subscription;

  init() {
    subscription = FirebaseFirestore.instance
        .collection(keyNoticeS)
        .where('$keySite.$keyDocId', isEqualTo: modelSite.docId)
        .orderBy(keyDate, descending: true)
        .limit(3) //최대 3개
        .snapshots()
        .listen((event) {
      for (var element in event.docChanges) {
        ModelNotice modelNotice = ModelNotice.fromJson(element.doc.data() as Map, element.doc.id);
        if (modelCheckListTarget != null) {
          if (modelNotice.listModelCheckList.where((element) => element.name == modelCheckListTarget!.name).isEmpty) {
            MyApp.logger.d('이 공지사항에 해당되는 팀이 아님.');
            continue;
          }
        }

        switch (element.type) {
          case DocumentChangeType.added:
            listModelNotice.add(modelNotice);
            break;
          case DocumentChangeType.modified:
            int index = listModelNotice.indexOf(modelNotice); //doc_id, date는 안 바뀐다는 전제 하에

            if (index != -1) {
              listModelNotice[index] = modelNotice;
            }
            break;
          case DocumentChangeType.removed:
            listModelNotice.removeWhere((element) => element == modelNotice);
            break;
        }

        listModelNotice.sort(
          (a, b) => b.date.millisecondsSinceEpoch.compareTo(a.date.millisecondsSinceEpoch),
        );

        notifyListeners();
      }
    });
  }

  clearProvider() {
    subscription?.cancel();
  }
}
