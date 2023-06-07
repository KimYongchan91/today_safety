import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:today_safety/my_app.dart';
import 'package:today_safety/service/util/util_snackbar.dart';

///권한을 확인하고, 필요할 경우 요청함
///정상적인 경우 true를 반환함
///요청에 실패하거나, 완전히 거부될 경우 false를 반환함
Future<bool> requestPermission(Permission permission) async {
  PermissionStatus permissionStatusOld = await permission.status;
  if (permissionStatusOld == PermissionStatus.permanentlyDenied) {
    showSnackBarOnRoute(
      messagePermissionImageDeniedPermanently,
      labelSnackBarButton: '이동',
      functionSnackBarActionCallBack: () {
        AppSettings.openAppSettings();
      },
    );

    return false;
  }

  try {
    PermissionStatus permissionStatusNew = await permission.request();
    if (permissionStatusNew == PermissionStatus.granted || permissionStatusNew == PermissionStatus.limited) {
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
