import 'package:today_safety/const/model/model_user_easy_login.dart';

String getIdWithLoginType(ModelUserEasyLogin modelUserEasyLogin) {
  return "${modelUserEasyLogin.email}&lt=${modelUserEasyLogin.loginType}";
}

String getIdExceptLoginType(String idWithLoginType) {
  return idWithLoginType.split("&lt=").first;
}
