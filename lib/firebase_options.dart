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
    apiKey: 'AIzaSyBdhpI9O3W9zjzGNiyYqCrOfL6TSdmLX-k',
    appId: '1:940056466165:web:074fa6504436818d0eebbc',
    messagingSenderId: '940056466165',
    projectId: 'tabpos-93583',
    authDomain: 'tabpos-93583.firebaseapp.com',
    storageBucket: 'tabpos-93583.appspot.com',
    measurementId: 'G-0H6L513PXV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDc8k8jfTv9O9nJwveRcmCI4z8A7oO4vdQ',
    appId: '1:940056466165:android:a0206f48cb8bb2ac0eebbc',
    messagingSenderId: '940056466165',
    projectId: 'tabpos-93583',
    storageBucket: 'tabpos-93583.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyANYvrWjD7_bdsrGWfLCbvljPeTBCcqPEQ',
    appId: '1:940056466165:ios:31ed27631248730e0eebbc',
    messagingSenderId: '940056466165',
    projectId: 'tabpos-93583',
    storageBucket: 'tabpos-93583.appspot.com',
    iosClientId: '940056466165-3b9ah4dlim7s244g2mhrc38jmeqdupdk.apps.googleusercontent.com',
    iosBundleId: 'com.example.tabpos',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyANYvrWjD7_bdsrGWfLCbvljPeTBCcqPEQ',
    appId: '1:940056466165:ios:31ed27631248730e0eebbc',
    messagingSenderId: '940056466165',
    projectId: 'tabpos-93583',
    storageBucket: 'tabpos-93583.appspot.com',
    iosClientId: '940056466165-3b9ah4dlim7s244g2mhrc38jmeqdupdk.apps.googleusercontent.com',
    iosBundleId: 'com.example.tabpos',
  );
}