// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyASrwlw05UWgxGWcScpYx9CeXOvp3BYDw0',
    appId: '1:843327665364:web:114e79a2e872beb72d7741',
    messagingSenderId: '843327665364',
    projectId: 'today-safety',
    authDomain: 'today-safety.firebaseapp.com',
    storageBucket: 'today-safety.appspot.com',
    measurementId: 'G-6XZ7RZ0JK2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD0VhFOYt5AcQUaJjObpqL6IDbGzqkijHw',
    appId: '1:843327665364:android:6f522b70dbce4b412d7741',
    messagingSenderId: '843327665364',
    projectId: 'today-safety',
    storageBucket: 'today-safety.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCOFQFnd2XJqPk3h0Xri60s9gZI6w8X2SA',
    appId: '1:843327665364:ios:1c6805bfb28e27ce2d7741',
    messagingSenderId: '843327665364',
    projectId: 'today-safety',
    storageBucket: 'today-safety.appspot.com',
    iosClientId: '843327665364-fsd9mue9j9uje56n63bqrbb642opo1pm.apps.googleusercontent.com',
    iosBundleId: 'kr.co.todaysafety.todaySafety',
  );
}