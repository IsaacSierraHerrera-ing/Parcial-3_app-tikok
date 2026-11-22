library;

/// A collection of default [FirebaseOptions] for different platforms.
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
    apiKey: 'AIzaSyCO0SJ079-fXZJ9h1jSlgJtRk2EWSBRiQk',
    appId: '1:194399641505:web:4e5b9aa89c18ccc869b5e0',
    messagingSenderId: '194399641505',
    projectId: 'app-parcial-7964a',
    authDomain: 'app-parcial-7964a.firebaseapp.com',
    storageBucket: 'app-parcial-7964a.firebasestorage.app',
    measurementId: 'G-F9CCPRT8X4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBRJQVAaQmZIAWE16nwBLlVJHus6A-kvB4',
    appId: '1:194399641505:android:829c4254b47c017069b5e0',
    messagingSenderId: '194399641505',
    projectId: 'app-parcial-7964a',
    storageBucket: 'app-parcial-7964a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCqPluqMjB9e-HKeKZ65ExGLEZVpkzGg5k',
    appId: '1:194399641505:ios:f579f619e660d42f69b5e0',
    messagingSenderId: '194399641505',
    projectId: 'app-parcial-7964a',
    storageBucket: 'app-parcial-7964a.firebasestorage.app',
    iosClientId: '194399641505-p343p6gu2tgsispfk7o954inmd1b8bns.apps.googleusercontent.com',
    iosBundleId: 'com.example.appTiktok',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCqPluqMjB9e-HKeKZ65ExGLEZVpkzGg5k',
    appId: '1:194399641505:ios:f579f619e660d42f69b5e0',
    messagingSenderId: '194399641505',
    projectId: 'app-parcial-7964a',
    storageBucket: 'app-parcial-7964a.firebasestorage.app',
    iosClientId: '194399641505-p343p6gu2tgsispfk7o954inmd1b8bns.apps.googleusercontent.com',
    iosBundleId: 'com.example.appTiktok',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCO0SJ079-fXZJ9h1jSlgJtRk2EWSBRiQk',
    appId: '1:194399641505:web:a7633c7adcd5024969b5e0',
    messagingSenderId: '194399641505',
    projectId: 'app-parcial-7964a',
    authDomain: 'app-parcial-7964a.firebaseapp.com',
    storageBucket: 'app-parcial-7964a.firebasestorage.app',
    measurementId: 'G-3H2GDKD6TC',
  );
}
