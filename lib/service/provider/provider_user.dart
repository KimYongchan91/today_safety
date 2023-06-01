import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:today_safety/const/model/model_user.dart';
import 'package:today_safety/const/model/model_user_easy_login.dart';

import '../../const/value/key.dart';
import '../../my_app.dart';
import '../util/util_snackbar.dart';

class ProviderUser extends ChangeNotifier {
  ModelUser? modelUser;

  loginEasy() {}

  loginWithKakao() async {
    ModelUserEasyLogin? modelUserEasyLogin;
    try {
      modelUserEasyLogin = await getUserDataFromKakao();

      if (modelUserEasyLogin != null) {}
    } catch (e) {
      MyApp.logger.wtf(e.toString());
    }
  }

  loginWithNaver() {}

  clearProvider() {
    modelUser = null;
    notifyListeners();
  }

  Future<ModelUserEasyLogin?> getUserDataFromKakao() async {
    KakaoSdk.init(nativeAppKey: 'f77b6bf70c14c1698265fd3a1d965768');

    bool isLoginAlready = false;

    try {
      isLoginAlready = await AuthApi.instance.hasToken();
    } on Exception catch (e) {
      MyApp.logger.d('로그인 되어있는지 확인 실패 : ${e.toString()}');
    }

    try {
      if (isLoginAlready) {
        User user = await UserApi.instance.me();
        MyApp.logger.d('현재 로그인 되어있는 계정 : ${user.kakaoAccount?.email}');
      } else {
        MyApp.logger.d('현재 로그인 되어있지 않음');
      }
    } on Exception catch (e) {
      isLoginAlready = false;
      MyApp.logger.wtf('로그인 토큰 조회 실패 : ${e.toString()}');
    }

    //로그인 되어있다면 로그아웃
    if (isLoginAlready) {
      try {
        await UserApi.instance.logout();
      } on Exception catch (e) {
        MyApp.logger.wtf('로그아웃하는데 실패 : ${e.toString()}');
        //return null;
      }
    }
    bool isInstalled;
    try {
      isInstalled = await isKakaoTalkInstalled();
    } catch (e) {
      isInstalled = false;
      MyApp.logger.wtf(e.toString());
    }

    if (isInstalled) {
      try {
        await UserApi.instance.loginWithKakaoTalk();
        MyApp.logger.d('카카오톡으로 로그인 성공');
      } catch (error) {
        MyApp.logger.wtf('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          MyApp.logger.wtf('로그인 취소');
          showSnackBarOnRoute(messageKakaoLoginFail);
          return null;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
      }
    } else {
      try {
        await UserApi.instance.loginWithKakaoAccount();
        MyApp.logger.d('카카오계정으로 로그인 성공');
      } catch (error) {
        MyApp.logger.wtf('카카오계정으로 로그인 실패 $error');
        showSnackBarOnRoute(messageKakaoLoginFail);
        return null;
      }
    }

    try {
      User user = await UserApi.instance.me();
      MyApp.logger.d('사용자 정보 요청 성공'
          '\n회원번호: ${user.id}' //필요 없음
          '\n성별: ${user.kakaoAccount?.gender}'
          '\n이메일: ${user.kakaoAccount?.email}');

      //카카오 로그인 최종 성공
      bool isAgreeEmail = user.kakaoAccount?.emailNeedsAgreement ?? false;
      bool isHasEmail = user.kakaoAccount?.isEmailValid ?? false;
      bool isVerifyEmail = user.kakaoAccount?.isEmailVerified ?? false;
      String? emailForJoin = user.kakaoAccount?.email;
      MyApp.logger.d(''
          '\nisAgreeEmail : $isAgreeEmail'
          '\nisHasEmail : $isHasEmail'
          '\nisVerifyEmail : $isVerifyEmail'
          '\nemailForJoin : $emailForJoin');

      if (emailForJoin != null) {
        //이메일 정상

        //성별
        String sexForJoin;
        bool isAgreeGender = user.kakaoAccount?.genderNeedsAgreement ?? false;
        Gender? gender = user.kakaoAccount?.gender;

        MyApp.logger.d(''
            '\nisAgreeGender : $isAgreeGender'
            '\ngender : ${gender.toString()}');

        if (gender == Gender.male) {
          sexForJoin = keySexMale;
        } else if (gender == Gender.female) {
          sexForJoin = keySexFemale;
        } else {
          sexForJoin = '';
        }

        //바로 로그아웃
        //필요 없을듯
        //로그인 시작시에 이미 로그아웃 하고 시작한다.

        return ModelUserEasyLogin(
          loginType: keyKakao,
          email: emailForJoin,
          sex: sexForJoin,
        );
      } else {
        //이메일 비정상
        showSnackBarOnRoute(messageKakaoLoginInvalidEmail);
        return null;
      }
    } catch (error) {
      MyApp.logger.wtf('사용자 정보 요청 실패 $error');
      showSnackBarOnRoute(messageKakaoLoginInvalidEmail);
      return null;
    }
  }
}
