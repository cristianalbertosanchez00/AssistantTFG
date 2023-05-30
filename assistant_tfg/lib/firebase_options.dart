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
    apiKey: 'AIzaSyC3cHb-H8rJTfmJNSUlP5R7Hm-jBjAd3T8',
    appId: '1:208078048542:web:1ed7f2d5d6336bb4444d0f',
    messagingSenderId: '208078048542',
    projectId: 'tfgassitantjarvis',
    authDomain: 'tfgassitantjarvis.firebaseapp.com',
    storageBucket: 'tfgassitantjarvis.appspot.com',
    measurementId: 'G-Y3THFVFKND',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBuictXDUMM8CqOpwPowueYVSPj1-It_mc',
    appId: '1:208078048542:android:ee50e381ad457887444d0f',
    messagingSenderId: '208078048542',
    projectId: 'tfgassitantjarvis',
    storageBucket: 'tfgassitantjarvis.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDhEhC-aIG4MkfQTh_JYuGqMIZi27i3z8M',
    appId: '1:208078048542:ios:ab3709c2dd3a8a46444d0f',
    messagingSenderId: '208078048542',
    projectId: 'tfgassitantjarvis',
    storageBucket: 'tfgassitantjarvis.appspot.com',
    iosBundleId: 'com.example.assistantTfg',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDhEhC-aIG4MkfQTh_JYuGqMIZi27i3z8M',
    appId: '1:208078048542:ios:0f4795ccc709d3b8444d0f',
    messagingSenderId: '208078048542',
    projectId: 'tfgassitantjarvis',
    storageBucket: 'tfgassitantjarvis.appspot.com',
    iosBundleId: 'com.example.assistantTfg.RunnerTests',
  );
}
