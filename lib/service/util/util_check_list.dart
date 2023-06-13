import 'package:cloud_firestore/cloud_firestore.dart';

import '../../const/model/model_check_list.dart';
import '../../const/value/key.dart';
import '../../my_app.dart';

///doc id를 이용해서 서버에서 체크리스트 모델을 받아옴
Future<ModelCheckList?> getModelCheckListFromServerByDocId(String docId) async {
  //서버에서 받아오는 코드
  //
  try {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection(keyCheckListS).doc(docId).get();
    if (documentSnapshot.exists) {
      ModelCheckList modelCheckList = ModelCheckList.fromJson(documentSnapshot.data() as Map, documentSnapshot.id);
      MyApp.logger.d("서버에서 받아온 체크리스트 : ${modelCheckList.toJson().toString()}");

      return modelCheckList;
    } else {
      return null;
    }
  } on Exception catch (e) {
    MyApp.logger.wtf("서버에서 받아오기 실패 : ${e.toString()}");
    return null;
  }
}
