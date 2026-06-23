import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      case TargetPlatform.iOS: return ios;
      default: throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDknX86TX0ueOWQHvQph-QU951foi0azFw',
    appId: '1:265085603046:web:ac405cf8d972d51bf79fb5',
    messagingSenderId: '265085603046',
    projectId: 'durakitos-durakos',
    authDomain: 'durakitos-durakos.firebaseapp.com',
    storageBucket: 'durakitos-durakos.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDknX86TX0ueOWQHvQph-QU951foi0azFw',
    appId: '1:265085603046:android:cbb10cf704655701747f27',
    messagingSenderId: '265085603046',
    projectId: 'durakitos-durakos',
    storageBucket: 'durakitos-durakos.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDknX86TX0ueOWQHvQph-QU951foi0azFw',
    appId: '1:265085603046:ios:placeholder',
    messagingSenderId: '265085603046',
    projectId: 'durakitos-durakos',
    storageBucket: 'durakitos-durakos.firebasestorage.app',
    iosBundleId: 'com.x1futurobillo.durakitos',  );
}
