import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBVO6npnw5UqBRRQ39bqsLbShl9ljPVY-o',
    appId: '1:985775079155:android:7a9bf2af5e1bf674a9c186',
    messagingSenderId: '985775079155',
    projectId: 'price-tracker-61b3f',
    storageBucket: 'price-tracker-61b3f.firebasestorage.app',
  );
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyAYc7cYbNw0gy4AUFREzFy0BwMcE6o_3B4',
  appId: '1:985775079155:web:7d2c490a6ba40c63a9c186',
  messagingSenderId: '985775079155',
  projectId: 'price-tracker-61b3f',
  storageBucket: 'price-tracker-61b3f.firebasestorage.app',
  authDomain: 'price-tracker-61b3f.firebaseapp.com',
  measurementId: '',
);
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: '',
    appId: '',
    messagingSenderId: '',
    projectId: '',
    storageBucket: '',
  );

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      default:
        return android;
    }
  }
}