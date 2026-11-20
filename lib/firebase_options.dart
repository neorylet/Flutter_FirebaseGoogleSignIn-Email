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
      throw UnimplementedError(
        'No default Firebase options for web are available.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnimplementedError(
          'No default Firebase options for iOS are available.',
        );
      case TargetPlatform.macOS:
        throw UnimplementedError(
          'No default Firebase options for macOS are available.',
        );
      case TargetPlatform.windows:
        throw UnimplementedError(
          'No default Firebase options for Windows are available.',
        );
      case TargetPlatform.linux:
        throw UnimplementedError(
          'No default Firebase options for Linux are available.',
        );
      default:
        throw UnimplementedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDMibbXypDpuefj_y6n2VgmKdhJvWVkz5Y',
    appId: '1:988745835342:android:59cfa68438463d75fef41f',
    messagingSenderId: '988745835342',
    projectId: 'fir-project-crud-8a1d0',
    storageBucket: 'fir-project-crud-8a1d0.firebasestorage.app',
  );
}
