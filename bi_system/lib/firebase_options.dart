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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyAwGzdlhAhH5SQWkzyO9h42Fdg2GY_PGqY',
    appId: '1:1043162107879:web:af5786e794d5f84ad03742',
    messagingSenderId: '1043162107879',
    projectId: 'sport-bi-system',
    authDomain: 'sport-bi-system.firebaseapp.com',
    storageBucket: 'sport-bi-system.firebasestorage.app',
    measurementId: 'G-B4FWF2HE64',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDUC285Ewm0UHV1oCQ64p8imYfLl-j0D6I',
    appId: '1:1043162107879:android:a90ecd802424f24bd03742',
    messagingSenderId: '1043162107879',
    projectId: 'sport-bi-system',
    storageBucket: 'sport-bi-system.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBJKuLuAFAu2XjtsCPjUap2MwZ1bi0twzc',
    appId: '1:1043162107879:ios:b1876446ab57d231d03742',
    messagingSenderId: '1043162107879',
    projectId: 'sport-bi-system',
    storageBucket: 'sport-bi-system.firebasestorage.app',
    iosBundleId: 'com.example.biSystem',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBJKuLuAFAu2XjtsCPjUap2MwZ1bi0twzc',
    appId: '1:1043162107879:ios:b1876446ab57d231d03742',
    messagingSenderId: '1043162107879',
    projectId: 'sport-bi-system',
    storageBucket: 'sport-bi-system.firebasestorage.app',
    iosBundleId: 'com.example.biSystem',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAwGzdlhAhH5SQWkzyO9h42Fdg2GY_PGqY',
    appId: '1:1043162107879:web:e8fa2933be1e2444d03742',
    messagingSenderId: '1043162107879',
    projectId: 'sport-bi-system',
    authDomain: 'sport-bi-system.firebaseapp.com',
    storageBucket: 'sport-bi-system.firebasestorage.app',
    measurementId: 'G-35DR0NE5F0',
  );

}