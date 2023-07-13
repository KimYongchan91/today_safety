import 'package:app_settings/app_settings.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:today_safety/my_app.dart';
import 'package:today_safety/service/util/util_snackbar.dart';

///권한을 확인하고, 필요할 경우 요청함
///정상적인 경우 true를 반환함
///요청에 실패하거나, 완전히 거부될 경우 false를 반환함
Future<bool> requestPermission(Permission permission) async {
  PermissionStatus permissionStatusOld = await permission.status;
  MyApp.logger.d("현재 권한 상태 : ${permissionStatusOld.toString()}");

  if (permissionStatusOld == PermissionStatus.permanentlyDenied) {
    MyApp.logger.wtf("권한 완전히 거부된 상태임");

    if (permission == Permission.locationWhenInUse) {
      //et.to(()=>);
    } else {
      showSnackBarOnRoute(
        messagePermissionImageDeniedPermanently,
        labelSnackBarButton: '이동',
        functionSnackBarActionCallBack: () {
          AppSettings.openAppSettings();
        },
      );
    }

    return false;
  }

  try {
    PermissionStatus permissionStatusNew = await permission.request();
    MyApp.logger.d("권한 요청 시작");
    if (permissionStatusNew == PermissionStatus.granted ||
        permissionStatusNew == PermissionStatus.limited ||
        permissionStatusNew == PermissionStatus.restricted) {
      //권한 허용
      return true;
    } else {
      //권한 거부
      return false;
    }
  } catch (e) {
    MyApp.logger.wtf('권한 요청 오류 : ${e.toString()}');
    return false;
  }
}
