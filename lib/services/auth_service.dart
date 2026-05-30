import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  Future<void>? _googleSignInInitialization;

  Future<void> _ensureGoogleSignInInitialized() {
    _googleSignInInitialization ??= _googleSignIn.initialize();
    return _googleSignInInitialization!;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> registerWithEmail(String email, String password, String name) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = credential.user;

    if (user != null) {
      final profile = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
        trackedProducts: const [],
      );
      try {
        await _firestore.collection('users').doc(user.uid).set(profile.toJson());
      } catch (_) {
        // Keep registration working even when Firestore rules or connectivity block profile creation.
      }

      try {
        await user.updateDisplayName(name);
      } catch (_) {
        // Display name is optional; do not fail signup if it cannot be updated.
      }
    }

    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      return _auth.signInWithPopup(GoogleAuthProvider());
    }

    await _ensureGoogleSignInInitialized();

    final googleUser = await _googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;
    if (googleAuth.idToken == null) {
      throw FirebaseAuthException(code: 'aborted-by-user', message: 'Google sign-in was cancelled.');
    }

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _ensureGoogleSignInInitialized();

    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}