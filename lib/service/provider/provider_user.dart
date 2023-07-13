import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as ks;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:today_safety/const/model/model_notice.dart';
import 'package:today_safety/const/model/model_site.dart';
import 'package:today_safety/const/model/model_user.dart';
import 'package:today_safety/const/model/model_user_easy_login.dart';
import 'package:today_safety/service/util/util_login.dart';
import 'package:today_safety/ui/dialog/dialog_input_name.dart';

import '../../const/value/key.dart';
import '../../my_app.dart';
import '../util/util_snackbar.dart';

typedef GetUserDataFromEasyLogin = Future<ModelUserEasyLogin?> Function();

enum LoginType {
  kakao,
  naver,
  google,
  apple,
}

class ProviderUser extends ChangeNotifier {
  ModelUser? modelUser;
  ModelSite? modelSiteMy;
  StreamSubscription? subscriptionSiteMy;

  //공지사항 관련
  StreamSubscription? subscriptionNoticeRecent;
  ModelNotice? modelNotice;
  String? siteDocIdListenNotice;

  ///자동 로그인 시작
  loginAuto() async {
    if (FirebaseAuth.instance.currentUser != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(keyUserS)
          .where(keyId, isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .limit(1)
          .get(const GetOptions(source: Source.server));

      if (querySnapshot.docs.isNotEmpty) {
        //유저 문서가 존재함
        ModelUser modelUser =
            ModelUser.fromJson(querySnapshot.docs.first.data() as Map<dynamic, dynamic>, querySnapshot.docs.first.id);
        if (modelUser.state == keyOn) {
          //MyApp.logger.d("유저 문서가 존재함");
          this.modelUser = modelUser;
          jobAfterLoginSuccess();
          notifyListeners();
        } else {
          //state가 on이 아님
          MyApp.logger.d("유저 state가 on이 아님");
          clearProvider(isNotify: false);
        }
      } else {
        //유저 문서가 존재 하지 않음
        MyApp.logger.d("유저 문서가 존재 하지 않음");
        clearProvider(isNotify: false);
      }
    }
  }

  ///간편 로그인 시작
  Future<void> loginEasy(LoginType loginType) async {
    //로그아웃부터
    await clearProvider();

    GetUserDataFromEasyLogin getUserDataFromEasyLogin;
    switch (loginType) {
      case LoginType.kakao:
        getUserDataFromEasyLogin = getUserDataFromKakao;
        break;
      case LoginType.naver:
        getUserDataFromEasyLogin = getUserDataFromNaver;
        break;
      case LoginType.google:
        getUserDataFromEasyLogin = getUserDataFromGoogle;
        break;
      case LoginType.apple:
        getUserDataFromEasyLogin = getUserDataFromApple;
        break;
    }

    ModelUserEasyLogin? modelUserEasyLogin = await getUserDataFromEasyLogin();
    if (modelUserEasyLogin == null) {
      MyApp.logger.wtf("modelUserEasyLogin == null");
      return;
    }

    HttpsCallableResult<dynamic> result = await FirebaseFunctions.instanceFor(region: "asia-northeast3")
        .httpsCallable('loginEasy')
        .call(<String, dynamic>{
      keyEmail: modelUserEasyLogin.email,
      'login_type': loginType.toString().split(".").last,
    });
    MyApp.logger.d("응답 결과 : ${result.data}");

    if (result.data[keyAuthenticated] == true) {
      //로그인 성공

      //FirebaseAuth 로그인 적용
      await loginWithToken(result.data['data'][keyToken],
          ModelUser.fromJson(result.data['data']['doc_data'], result.data['data']['doc_id']));
    } else {
      //로그인한 이력이 없음
      if (result.data[keyMessage] == keyUserNotFound) {
        //유저가 존재 하지 않음.
        //회원 가입 진행
        //이름을 물어보자.
        String? name;
        if (modelUserEasyLogin.name != null) {
          name = modelUserEasyLogin.name;
        } else {
          name = await Get.dialog(
            DialogInputName(modelUserEasyLogin.email),
            barrierDismissible: false,
          );
        }

        if (name == null) {
          showSnackBarOnRoute('이름이 입력되지 않았어요.');
          return;
        }

        ModelUser modelUserNew = ModelUser(
          id: getIdWithLoginType(modelUserEasyLogin),
          idExceptLT: modelUserEasyLogin.email,
          name: name,
          loginType: modelUserEasyLogin.loginType,
          state: keyOn,
          dateJoin: Timestamp.now(),
        );

        //회원 가입 시작
        try {
          Map<String, dynamic> resultJoin = await joinEasy(modelUserNew);

          //회원가입 성공

          //FirebaseAuth 로그인 적용
          await loginWithToken(resultJoin[keyToken], ModelUser.fromJson(modelUserNew.toJson(), resultJoin[keyDocId]));
        } on Exception catch (e) {
          MyApp.logger.wtf("회원 가입 중에 에러 발생 : ${e.toString()}");
          showSnackBarOnRoute(messageJoinFail);
          await clearProvider();
          return;
        }
      } else if (result.data[keyMessage] == '') {
        //유저가 강제 탈퇴된 상태
      } else if (result.data[keyMessage] == '') {
        //유저가 스스로 탈퇴한 상태
      } else {
        //알 수 없는 로그인 실패
      }
    }
  }

  loginWithToken(String token, ModelUser modelUser) async {
    try {
      await FirebaseAuth.instance.signInWithCustomToken(token);
      this.modelUser = modelUser;

      jobAfterLoginSuccess();
      showSnackBarOnRoute('로그인했어요.');

      notifyListeners();
    } on Exception catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> joinEasy(ModelUser modelUser) async {
    try {
      HttpsCallableResult<dynamic> result = await FirebaseFunctions.instanceFor(region: "asia-northeast3")
          .httpsCallable('join')
          .call(modelUser.toJson(isForServerForm: true));
      MyApp.logger.d("응답 결과 : ${result.data}");

      if (result.data[keyResult] == true) {
        return {
          keyDocId: result.data[keyDocId],
          keyToken: result.data[keyToken],
        };
      } else {
        throw Exception();
      }
    } on Exception catch (_) {
      rethrow;
    }
  }

/*  loginWithKakao() async {
    ModelUserEasyLogin? modelUserEasyLogin = await getUserDataFromKakao();
  }

  loginWithNaver() {}*/

  ///카카로오부터 정보 받아오기
  Future<ModelUserEasyLogin?> getUserDataFromKakao() async {
    bool isLoginAlready = false;

    try {
      isLoginAlready = await ks.AuthApi.instance.hasToken();
    } on Exception catch (e) {
      MyApp.logger.d('로그인 되어있는지 확인 실패 : ${e.toString()}');
    }

    try {
      if (isLoginAlready) {
        ks.User user = await ks.UserApi.instance.me();
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
        await ks.UserApi.instance.logout();
      } on Exception catch (e) {
        MyApp.logger.wtf('로그아웃하는데 실패 : ${e.toString()}');
        //return null;
      }
    }
    bool isInstalled;
    try {
      isInstalled = await ks.isKakaoTalkInstalled();
    } catch (e) {
      isInstalled = false;
      MyApp.logger.wtf(e.toString());
    }

    if (isInstalled) {
      try {
        await ks.UserApi.instance.loginWithKakaoTalk();
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
        await ks.UserApi.instance.loginWithKakaoAccount();
        MyApp.logger.d('카카오계정으로 로그인 성공');
      } catch (error) {
        MyApp.logger.wtf('카카오계정으로 로그인 실패 $error');
        showSnackBarOnRoute(messageKakaoLoginFail);
        return null;
      }
    }

    try {
      ks.User user = await ks.UserApi.instance.me();
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
        String? sexForJoin;
        bool isAgreeGender = user.kakaoAccount?.genderNeedsAgreement ?? false;
        ks.Gender? gender = user.kakaoAccount?.gender;

        MyApp.logger.d(''
            '\nisAgreeGender : $isAgreeGender'
            '\ngender : ${gender.toString()}');

        if (gender == ks.Gender.male) {
          sexForJoin = keySexMale;
        } else if (gender == ks.Gender.female) {
          sexForJoin = keySexFemale;
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
      showSnackBarOnRoute('카카로 로그인을 사용할 수 없어요.\n잠시 후에 다시 시도해 주세요.');
      return null;
    }
  }

  ///네이버로부터 정보 받아오기
  Future<ModelUserEasyLogin?> getUserDataFromNaver() async {
    try {
      NaverLoginResult naverLoginResult = await FlutterNaverLogin.logIn();

      //NaverAccessToken naverAccessToken = await FlutterNaverLogin.currentAccessToken;
      MyApp.logger.d("네이버 로그인 결과\n"
          "이름 : ${naverLoginResult.account.name}");

      if (naverLoginResult.account.name.isEmpty || naverLoginResult.account.email.isEmpty) {
        throw Exception("naverLoginResult.account.name.isEmpty || naverLoginResult.account.email.isEmpty");
      }

      return ModelUserEasyLogin(
        loginType: keyNaver,
        email: naverLoginResult.account.email,
        name: naverLoginResult.account.name,
      );
    } catch (e) {
      MyApp.logger.wtf("네이버 로그인 실패 : ${e.toString()}");
      return null;
    }
  }

  ///구글로부터 정보 받아오기
  Future<ModelUserEasyLogin?> getUserDataFromGoogle() async {
    GoogleSignIn googleSignIn = GoogleSignIn(
      hostedDomain: "kayple.com",
      serverClientId: "843327665364-j0p8oon7neq5eu44qalpr23oj01e6s2h.apps.googleusercontent.com",
    );
    GoogleSignInAccount? googleSignInAccount;
    try {
      googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount == null) {
        showSnackBarOnRoute(messageLoginFail);
        return null;
      }
    } catch (e) {
      MyApp.logger.wtf("구글 로그인 오류 발생 : ${e.toString()}");
    }

    MyApp.logger.d("로그인 결과 : ${googleSignInAccount.toString()}");
    return null;
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    String charset = 'kr.co.kayple.today_safety@${DateTime.now().millisecondsSinceEpoch}';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  ///애플로부터 정보 받아오기
  Future<ModelUserEasyLogin?> getUserDataFromApple() async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    try {
      AuthorizationCredentialAppleID authorizationCredentialAppleID = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      MyApp.logger.d(
          "authorizationCredentialAppleID 결과 : ${authorizationCredentialAppleID.email}, ${authorizationCredentialAppleID.givenName}");

      // Create an `OAuthCredential` from the credential returned by Apple.
      OAuthCredential oauthCredential = OAuthProvider("apple.com").credential(
        idToken: authorizationCredentialAppleID.identityToken,
        accessToken: authorizationCredentialAppleID.authorizationCode,
        rawNonce: rawNonce,
      );

      MyApp.logger.d("oauthCredential 결과 : ${oauthCredential.idToken}");

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      MyApp.logger.d("userCredential 결과 : ${userCredential.user?.email}, ${userCredential.user?.displayName}");

      if (userCredential.user == null || userCredential.user?.email == null || userCredential.user!.email!.isEmpty) {
        throw Exception("userCredential.user == null");
      }

      //firebase auth 로그아웃
      await FirebaseAuth.instance.signOut();

      return ModelUserEasyLogin(
        loginType: keyApple,
        email: userCredential.user!.email!,
        name: userCredential.user?.displayName,
      );
    } catch (e) {
      MyApp.logger.wtf("애플 로그인 실패 : ${e.toString()}");
    }

    return null;
  }

  ///로그인 성공 후의 작업
  jobAfterLoginSuccess() async {
    ///내 인증서 리스너 등록
    if (modelUser != null) {
      MyApp.providerUserCheckHistoryOnMe.set(modelUser!);
    }

    ///내가 관리하는 근무지에 대한 리스너 등록
    subscriptionSiteMy = FirebaseFirestore.instance
        .collection(keySites)
        .where(keyMaster, isEqualTo: modelUser?.id ?? '')
        .snapshots()
        .listen((event) {
      for (var element in event.docChanges) {
        switch (element.type) {
          case DocumentChangeType.added:
          case DocumentChangeType.modified:
            ModelSite modelSite = ModelSite.fromJson(element.doc.data() as Map, element.doc.id);
            modelSiteMy = modelSite;
            notifyListeners();
            break;
          case DocumentChangeType.removed:
            modelSiteMy = null;
            notifyListeners();
            break;
        }
      }
    });

    ///최근에 내가 인증한 site의 공지사항에 대한 리스너 등록
    getModelNotice();

    ///토큰이 바뀌었다면 수정해줌
    _addToken();
  }

  getModelNotice({String? siteDocIdNew}) async {
    //처음이거나, 새로운 site라면 초기화
    if (siteDocIdListenNotice == null ||
        (siteDocIdListenNotice != null && siteDocIdNew != null && siteDocIdListenNotice != siteDocIdNew)) {
      subscriptionNoticeRecent?.cancel();
      clearProviderNotice();

      if (modelUser == null) {
        MyApp.logger.wtf("modelUser==null");
        return;
      }

      //최근에 내가 인증한 site를 조회
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection(keyUserCheckHistories)
            .where('$keyUser.$keyId', isEqualTo: modelUser!.id)
            .orderBy(keyDate, descending: true)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          //최근에 내가 인증한 site가 없으면
          //내가 관리 중인 site라도 조회

          querySnapshot = await FirebaseFirestore.instance
              .collection(keySites)
              .where(keyMaster, isEqualTo: modelUser!.id)
              .orderBy(keyDate, descending: true)
              .limit(1)
              .get();

          if (querySnapshot.docs.isEmpty) {
            throw Exception("querySnapshot.docs.isEmpty");
          }

          siteDocIdListenNotice = querySnapshot.docs.first.id;
        } else {
          Map json = (querySnapshot.docs.first.data() as Map)[keyCheckList]?[keySite] ?? {};
          ModelSite modelSite = ModelSite.fromJson(json, json[keyDocId] ?? '');
          siteDocIdListenNotice = modelSite.docId;
        }

        //MyApp.logger.d("modelSite ${modelSite.toJson().toString()}");
        //MyApp.logger.d("siteDocIdListenNotice $siteDocIdListenNotice");

        //공지사항 구하기
        subscriptionNoticeRecent = FirebaseFirestore.instance
            .collection(keyNoticeS)
            .where('$keySite.$keyDocId', isEqualTo: siteDocIdListenNotice)
            .orderBy(keyDate, descending: true)
            .limit(1)
            .snapshots()
            .listen((event) {
          for (var element in event.docChanges) {
            ModelNotice modelNoticeNew = ModelNotice.fromJson(element.doc.data() as Map, element.doc.id);
            //MyApp.logger.d("modelNoticeNew ${modelNoticeNew.toJson().toString()}");

            switch (element.type) {
              case DocumentChangeType.added:
              case DocumentChangeType.modified:
                modelNotice = modelNoticeNew;
                notifyListeners();
                break;
              case DocumentChangeType.removed:
                MyApp.logger.d("공지사항 삭제됨?? ${modelNoticeNew.title}");
                break;
            }
          }
        });
      } catch (e) {
        MyApp.logger.wtf("getModelNotice 실패 : ${e.toString()}");
      }
    } else {
      MyApp.logger.d("getModelNotice 유지함.");
    }
  }

  _addToken() async {
    //fcm 초기화 대기
    if (MyApp.completerInitFcm.isCompleted == false) {
      await MyApp.completerInitFcm.future;
    }

    //토큰이 없다면 추가
    if (modelUser != null && MyApp.tokenFcm != null && modelUser!.listToken.contains(MyApp.tokenFcm) == false) {
      await FirebaseFirestore.instance.collection(keyUserS).doc(modelUser!.docId).update({
        keyToken: FieldValue.arrayUnion([MyApp.tokenFcm]),
      });
      //modelUser!.listToken.add(MyApp.tokenFcm);
    }
  }

  logoutFromAll() async {
    //구글 로그아웃
    try {
      if (FirebaseAuth.instance.currentUser != null) FirebaseAuth.instance.signOut();
    } on Exception catch (e) {
      MyApp.logger.wtf("구글 로그아웃 실패 : ${e.toString()}");
    }

    //카카오 로그아웃
    try {
      OAuthToken? oAuthToken = await ks.TokenManagerProvider.instance.manager.getToken();
      if (oAuthToken != null) {
        ks.UserApi.instance.logout();
      }
    } on Exception catch (e) {
      MyApp.logger.wtf("카카오 로그아웃 실패 : ${e.toString()}");
    }

    //네이버 로그아웃
    try {
      NaverAccountResult naverAccountResult = await FlutterNaverLogin.currentAccount();
      FlutterNaverLogin.logOut();
    } on Exception catch (e) {
      MyApp.logger.wtf("네이버 로그아웃 실패 : ${e.toString()}");
    }

    subscriptionSiteMy?.cancel();
    clearProviderNotice();
  }

  clearProviderNotice() {
    subscriptionNoticeRecent?.cancel();
    siteDocIdListenNotice = null;
    modelNotice = null;
  }

  clearProvider({bool isNotify = true}) async {
    modelUser = null;
    if (isNotify) notifyListeners();
    MyApp.providerUserCheckHistoryOnMe.clearProvider();

    logoutFromAll();

    /*List<Future> listFutureLogOut = [];
    listFutureLogOut.add(FirebaseAuth.instance.signOut());
    listFutureLogOut.add(ks.UserApi.instance.me().then((value) {
      if (value.kakaoAccount != null) {

      }
    }));
    await Future.wait(listFutureLogOut);*/
  }

  ///회원 탈퇴
  outUser() async {
    if (modelUser == null) {
      MyApp.logger.wtf("modelUser ==null");
      return;
    }

    ///유저, 근무지, 인증 삭제
    List<Future> listFuture = [];
    List<DocumentReference> listDocumentReference = [];
    //유저 삭제
    listFuture.add(FirebaseFirestore.instance.collection(keyUserS).where(keyId, isEqualTo: modelUser!.id).get().then(
      (value) {
        for (var element in value.docs) {
          listDocumentReference.add(element.reference);
        }
      },
    ));

    //근무지 삭제
    listFuture
        .add(FirebaseFirestore.instance.collection(keySites).where(keyMaster, isEqualTo: modelUser!.id).get().then(
      (value) {
        for (var element in value.docs) {
          listDocumentReference.add(element.reference);
        }
      },
    ));

    //인증 삭제
    listFuture.add(FirebaseFirestore.instance
        .collection(keyUserCheckHistories)
        .where('$keyUser.$keyId', isEqualTo: modelUser!.id)
        .get()
        .then(
      (value) {
        for (var element in value.docs) {
          listDocumentReference.add(element.reference);
        }
      },
    ));

    await Future.wait(listFuture);

    await Future.wait([...listDocumentReference.map((e) => e.delete())]);

    if (modelUser!.loginType == keyApple) {
      //토큰 삭제
    }

    clearProvider();
  }
}
