import 'package:today_safety/const/model/model_check_list.dart';

import 'util_app_link.dart';

String getQrCode(ModelCheckList modelCheckList){
  return '$urlAppLink/${modelCheckList.docId}';
}