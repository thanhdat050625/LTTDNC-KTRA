import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD1eXTD3jdRRcRaO00uoK3qtt7ziEVc_nY',
    appId: '1:602993131194:web:c2bfd2fc6d56e2d9d18c83',
    messagingSenderId: '602993131194',
    projectId: 'ltddc-12fd2',
    authDomain: 'ltddc-12fd2.firebaseapp.com',
    storageBucket: 'ltddc-12fd2.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA4hJoOVjVLsCrIthuF8isUT6h5qsDhp30',
    appId: '1:602993131194:android:e8abf7f849016078d18c83',
    messagingSenderId: '602993131194',
    projectId: 'ltddc-12fd2',
    storageBucket: 'ltddc-12fd2.firebasestorage.app',
  );
}
