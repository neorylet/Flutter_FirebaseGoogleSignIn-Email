import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
    apiKey: 'AIzaSyBLwsbhkUstAoJWhyu3sc5CgqBZzug3S0s',
    appId: '1:577840549903:android:20141283bea6d8307bd37a',
    messagingSenderId: '577840549903',
    projectId: 'cloodinary9',
    storageBucket: 'cloodinary9.firebasestorage.app',
  );
}
