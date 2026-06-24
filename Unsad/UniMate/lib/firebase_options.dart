
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDTFm5UwXOm9FKKJonL--p3aWKfS1-1Sgo',
    appId: '1:861471514965:android:6ef118266f1d94526d4fdc',
    messagingSenderId: '861471514965',
    projectId: 'unimate-53b42',
    storageBucket: 'unimate-53b42.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD29NQx9yznbK6c8iz-Q_Q5sBORas33-FA',
    appId: '1:861471514965:ios:277e7b7b47a422ac6d4fdc',
    messagingSenderId: '861471514965',
    projectId: 'unimate-53b42',
    storageBucket: 'unimate-53b42.firebasestorage.app',
    iosBundleId: 'com.example.unimate',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD4s9IBiHg3l74d5U5VsJ0CWJErDxHEFbQ',
    appId: '1:861471514965:web:93a18a1c599287d06d4fdc',
    messagingSenderId: '861471514965',
    projectId: 'unimate-53b42',
    authDomain: 'unimate-53b42.firebaseapp.com',
    storageBucket: 'unimate-53b42.firebasestorage.app',
  );

}