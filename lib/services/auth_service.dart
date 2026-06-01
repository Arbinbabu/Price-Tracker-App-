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
      final provider = GoogleAuthProvider();
      try {
        return await _auth.signInWithPopup(provider);
      } catch (e) {
        throw FirebaseAuthException(
          code: 'ERROR_WEB_SIGNIN',
          message: 'Web Google sign-in failed: $e. Ensure popups are allowed and add localhost/127.0.0.1 to Firebase authorized domains.',
        );
      }
    }

    await _ensureGoogleSignInInitialized();

    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _auth.signOut();

    if (!kIsWeb) {
      await _ensureGoogleSignInInitialized();
      await _googleSignIn.signOut();
    }
  }
}