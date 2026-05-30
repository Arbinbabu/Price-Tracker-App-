import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:1234567890:android:demo',
    messagingSenderId: '1234567890',
    projectId: 'price-tracker-demo',
  );
}