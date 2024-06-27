// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyDfFj4G22xkrCAnbYM3vvjpFBJuGeWY_Hs',
    appId: '1:134973073580:web:928558e13f0cb238145709',
    messagingSenderId: '134973073580',
    projectId: 'seatease-a3812',
    authDomain: 'seatease-a3812.firebaseapp.com',
    storageBucket: 'seatease-a3812.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD2nqwPWhz-kQyBIS-IsX-3dYSSqeTinsY',
    appId: '1:134973073580:android:2368a78e97ea8afa145709',
    messagingSenderId: '134973073580',
    projectId: 'seatease-a3812',
    storageBucket: 'seatease-a3812.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBVUalBqmPMZQS9M4Y5284D20KyzkzUL8A',
    appId: '1:134973073580:ios:83accdcf212713ee145709',
    messagingSenderId: '134973073580',
    projectId: 'seatease-a3812',
    storageBucket: 'seatease-a3812.appspot.com',
    iosBundleId: 'com.example.seatEase',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBVUalBqmPMZQS9M4Y5284D20KyzkzUL8A',
    appId: '1:134973073580:ios:83accdcf212713ee145709',
    messagingSenderId: '134973073580',
    projectId: 'seatease-a3812',
    storageBucket: 'seatease-a3812.appspot.com',
    iosBundleId: 'com.example.seatEase',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDfFj4G22xkrCAnbYM3vvjpFBJuGeWY_Hs',
    appId: '1:134973073580:web:e1a79cf1bad8a4f3145709',
    messagingSenderId: '134973073580',
    projectId: 'seatease-a3812',
    authDomain: 'seatease-a3812.firebaseapp.com',
    storageBucket: 'seatease-a3812.appspot.com',
  );

}