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
        return macos;
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
    apiKey: 'AIzaSyA8KgASIkPVE1_rU19fC7UmgtPVmRABQ1c',
    appId: '1:34892263431:web:0ec45bda6193e5437d7aa2',
    messagingSenderId: '34892263431',
    projectId: 'attendance-ac652',
    authDomain: 'attendance-ac652.firebaseapp.com',
    storageBucket: 'attendance-ac652.appspot.com',
    measurementId: 'G-7GGKZMXHPL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCXSw2TcSqvIBGYzLs3jsrLvujmjJsHZ7g',
    appId: '1:34892263431:android:2a8ce81d3f87e0197d7aa2',
    messagingSenderId: '34892263431',
    projectId: 'attendance-ac652',
    storageBucket: 'attendance-ac652.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBJXKyHm6KNzh_fe9eeM5npQXGUCrl5QWQ',
    appId: '1:34892263431:ios:7356202b375224337d7aa2',
    messagingSenderId: '34892263431',
    projectId: 'attendance-ac652',
    storageBucket: 'attendance-ac652.appspot.com',
    iosBundleId: 'com.example.flutterUi',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBJXKyHm6KNzh_fe9eeM5npQXGUCrl5QWQ',
    appId: '1:34892263431:ios:2b34452ad3de2c537d7aa2',
    messagingSenderId: '34892263431',
    projectId: 'attendance-ac652',
    storageBucket: 'attendance-ac652.appspot.com',
    iosBundleId: 'com.example.flutterUi.RunnerTests',
  );
}
