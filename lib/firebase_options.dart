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
    apiKey: 'AIzaSyC9uOd9fef2Ef-QE1IUzXNdZJVrzWXX_DE',
    appId: '1:737346394316:web:943a1581131294e26a0a69',
    messagingSenderId: '737346394316',
    projectId: 'crosstrack-italia',
    authDomain: 'crosstrack-italia.firebaseapp.com',
    storageBucket: 'crosstrack-italia.appspot.com',
    measurementId: 'G-BQ9FP0W8F9',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDqoDKgMiYBnelX1B9NQPXFbZc4gBSwcNc',
    appId: '1:737346394316:android:68e36959d81943396a0a69',
    messagingSenderId: '737346394316',
    projectId: 'crosstrack-italia',
    storageBucket: 'crosstrack-italia.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA8V5-jGWVfV-aWT6V735T64XQy4pH-sJs',
    appId: '1:737346394316:ios:12ccfd37dabe8e4a6a0a69',
    messagingSenderId: '737346394316',
    projectId: 'crosstrack-italia',
    storageBucket: 'crosstrack-italia.appspot.com',
    iosClientId:
        '737346394316-ot6m6stbisilj5q9k883osiduih5kjnf.apps.googleusercontent.com',
    iosBundleId: 'com.example.crosstrackItalia',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA8V5-jGWVfV-aWT6V735T64XQy4pH-sJs',
    appId: '1:737346394316:ios:154a8bb5ba479e0e6a0a69',
    messagingSenderId: '737346394316',
    projectId: 'crosstrack-italia',
    storageBucket: 'crosstrack-italia.appspot.com',
    iosClientId:
        '737346394316-sp6pre43rl0tg71r9njc3hk8ce327kjv.apps.googleusercontent.com',
    iosBundleId: 'com.example.crosstrackItalia.RunnerTests',
  );
}
