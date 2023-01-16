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

  static const API_KEY = 'AIzaSyDJf1tyznBdHw1cVzCY0WOc5FeuiswL0cM';

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: API_KEY,
    appId: '1:691007032710:web:aa812d2d3b6b885b4ab007',
    messagingSenderId: '691007032710',
    projectId: 'kspot-001',
    authDomain: 'kspot-001.firebaseapp.com',
    storageBucket: 'kspot-001.appspot.com',
    measurementId: 'G-F6X15WDFXJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: API_KEY,
    appId: '1:691007032710:ios:703f1b82b7d8ed874ab007',
    messagingSenderId: '691007032710',
    projectId: 'kspot-001',
    storageBucket: 'kspot-001.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAKO6EYT2DZS50Gkf2DMyCdFZrG-b3gFII',
    appId: '1:691007032710:ios:703f1b82b7d8ed874ab007',
    messagingSenderId: '691007032710',
    projectId: 'kspot-001',
    storageBucket: 'kspot-001.appspot.com',
    androidClientId: '691007032710-1btr37h5hq9an3475ie6vg0vnok9k94d.apps.googleusercontent.com',
    iosClientId: '691007032710-kql8lqqrc831isirs74igptvpdqfgesf.apps.googleusercontent.com',
    iosBundleId: 'com.jhfactory.kspot001',
  );
}