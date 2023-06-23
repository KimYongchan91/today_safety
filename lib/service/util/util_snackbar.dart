import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../const/value/router.dart';
import '../../custom/custom_text_style.dart';


//공통
String messageServerError = '서버와의 통신에 실패했어요.\n잠시 후 다시 시도해주세요.';
String messageNoNetwork = '네트워크 상태를 확인해주세요.';

//로그인 및 회원가입
String messageSuccessJoin = '회원가입에 성공했어요.';
String messageNeedReLogin = '로그인이 해제됐어요.\n다시 로그인해주세요.';
String messageNeedLogin = '로그인을 해주세요.';
String messageExistAlready = '이미 사용 중이에요.';


/*//투표
String messageNotExistFace = '사진에서 얼굴이 인식되지 않았어요.\n다른 사진을 이용해 주세요.';
String messageNotSelectImage = '사진 선택을 취소했어요.';
String messageNotSelectVideo = '동영상 선택을 취소했어요.';
String messageNotEnoughOption = '옵션을 $countOptionMin개 이상 만들어주세요.';
String messageTooLargeVideo = '선택된 동영상의 크기가 너무 커요.\n최대 ${sizeVoteVideoFileMegaByteMax}mb';
String messageStartUpload = '서버로 전송을 시작했어요.';
String messageCantVoteOnPreviewMode = '미리보기에서는 투표할 수 없어요.';
String messageNeedVote = '먼저 투표를 해주세요.';*/

String messageKakaoLoginFail  = '카카로 로그인에 실패했어요.\n다른 로그인 방법을 이용해주세요.';
String messageKakaoLoginInvalidEmail  = '카카오 계정에 e메일 정보가 없어요.\n다른 로그인 방법을 이용해주세요.';

String messageJoinFail  = '회원 가입에 실패했어요.\n잠시 후에 다시 시도해 주세요.';
String messageLoginFail  = '로그인에 실패했어요.\n다른 로그인 방법을 이용해주세요.'

;

String messagePermissionImageDenied = '이미지를 불러올 권한이 없어요.';
String messagePermissionImageDeniedPermanently = '권한이 완전히 거부되었어요.\n설정으로 이동해 직접 허용해 주세요.';
String messageEmptySelectedImage  = '선택된 사진이 없어요.';


void showSnackBarOnRoute(
  String content, {
  String title = '알림',
  String? labelSnackBarButton,
  void Function()? functionSnackBarActionCallBack,
  bool isBackgroundBlack = true,
  SnackPosition snackPosition = SnackPosition.TOP,
  Duration duration = const Duration(seconds: 3),
  bool isDismissible = true,
}) {
  /*Get.closeAllSnackbars();
    //닫기 함수 등록
    if (MyApp?.functionCloseAllSnackBar == null) {
      MyApp.functionCloseAllSnackBar = () {
        print("모든 스낵바 닫음");
        Get.closeAllSnackbars();
      };
    }*/

  Get.closeAllSnackbars();

  Get.showSnackbar(
    GetSnackBar(
      titleText: Text(
        title,
        style: isBackgroundBlack
            ? const CustomTextStyle.bigBlack().copyWith(color: Colors.white)
            : const CustomTextStyle.bigBlack(),
      ),
      messageText: Text(
        content,
        style: isBackgroundBlack
            ? const CustomTextStyle.normalBlack().copyWith(color: Colors.white)
            : const CustomTextStyle.normalBlack(),
      ),
      backgroundColor: isBackgroundBlack ? Colors.black : Colors.white,
      snackPosition: snackPosition,
      duration: duration,
      borderRadius: 10,
      isDismissible: isDismissible,

      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      //reverseAnimationCurve: Curves.easeOutExpo,
      mainButton: functionSnackBarActionCallBack != null
          ? TextButton(
              onPressed: () {
                Get.closeAllSnackbars();
                functionSnackBarActionCallBack();
              },
              child: Text(
                labelSnackBarButton!,
                style: const TextStyle(color: Colors.white),
              ),
            )
          : Container() /*TextButton(
              onPressed: () {
                if (kDebugMode) {
                  print("클릭");
                }
                Get.closeCurrentSnackbar();
                //MyApp?.functionCloseAllSnackBar();
              },
              child: const Text(
                '확인',
                style: TextStyle(color: Colors.white),
              ),
            )*/
      ,
    ),
  );
}

void showSnackBarLogin() {
  showSnackBarOnRoute(
    messageNeedLogin,
    labelSnackBarButton: '로그인',
    functionSnackBarActionCallBack: () {
      Get.toNamed(keyRouteLogin);
    },
  );
}

void showSnackBarOnRouteOnTopBackgroundWhite(String value) {
  showSnackBarOnRoute(
    value,
    snackPosition: SnackPosition.TOP,
    isBackgroundBlack: false,
  );
}
