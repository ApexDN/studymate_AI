import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_models.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign Up
  Future<String?> signUp(String name, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await _db.collection('users').doc(cred.user!.uid).set(
        UserProfile(uid: cred.user!.uid, name: name.trim(), email: email.trim()).toMap(),
      );
      await cred.user!.updateDisplayName(name.trim());
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Sign In
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  // Get user profile
  Future<UserProfile?> getUserProfile() async {
    if (currentUser == null) return null;
    final doc = await _db.collection('users').doc(currentUser!.uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(doc.data()!);
  }
}
