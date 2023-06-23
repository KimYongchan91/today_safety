import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:today_safety/const/model/model_notice.dart';
import 'package:today_safety/const/value/key.dart';

import '../../my_app.dart';

///doc id를 이용해서 서버에서 공지사항 모델을 받아옴
Future<ModelNotice?> getModelNoticeFromServerByDocId(String docId) async {
  //서버에서 받아오는 코드
  //
  try {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection(keyNoticeS).doc(docId).get();
    if (documentSnapshot.exists) {
      ModelNotice modelNotice = ModelNotice.fromJson(documentSnapshot.data() as Map, documentSnapshot.id);
      MyApp.logger.d("서버에서 받아온 체크리스트 : ${modelNotice.toJson().toString()}");

      return modelNotice;
    } else {
      return null;
    }
  } on Exception catch (e) {
    MyApp.logger.wtf("서버에서 받아오기 실패 : ${e.toString()}");
    return null;
  }
}
