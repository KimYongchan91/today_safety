import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:today_safety/const/model/model_user_check_history.dart';
import 'package:today_safety/const/value/key.dart';

import '../../my_app.dart';

///doc id를 이용해서 서버에서 모델을 받아옴
Future<ModelUserCheckHistory?> getModelUserCheckHistoryFromServerByDocId(String docId) async {

  try {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection(keyUserCheckHistories).doc(docId).get();
    if (documentSnapshot.exists) {
      ModelUserCheckHistory modelUserCheckHistory = ModelUserCheckHistory.fromJson(documentSnapshot.data() as Map, docId : documentSnapshot.id);
      MyApp.logger.d("서버에서 받아온 유저 인증 이력 : ${modelUserCheckHistory.toJson().toString()}");

      return modelUserCheckHistory;
    } else {
      return null;
    }
  } on Exception catch (e) {
    MyApp.logger.wtf("서버에서 받아오기 실패 : ${e.toString()}");
    return null;
  }
}
