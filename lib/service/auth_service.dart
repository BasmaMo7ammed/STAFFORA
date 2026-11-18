
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // SIGN UP
  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    UserCredential credential;

    // Step 1: Create Firebase Authentication account
    try {
      debugPrint('SIGN UP: Creating Authentication account...');

      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      debugPrint('SIGN UP: Authentication account created successfully.');
    } on FirebaseAuthException catch (e) {
      debugPrint('SIGN UP AUTH ERROR: ${e.code}');
      debugPrint('SIGN UP AUTH MESSAGE: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('SIGN UP UNKNOWN ERROR: $e');
      rethrow;
    }

    final user = credential.user;

    if (user == null) {
      throw Exception('Account was created, but user data is unavailable.');
    }

    // Step 2: Save admin information
    try {
      await user.updateDisplayName(name.trim());

      await _firestore.collection('admins').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('SIGN UP: Admin data saved successfully.');

      return credential;
    } on FirebaseException catch (e) {
      debugPrint('FIREBASE DATA ERROR: ${e.code}');
      debugPrint('FIREBASE DATA MESSAGE: ${e.message}');

      throw Exception(
        'Your account was created, but saving admin data failed: ${e.message}',
      );
    } catch (e) {
      debugPrint('SIGN UP PROFILE ERROR: $e');
      rethrow;
    }
  }

  // LOGIN
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('LOGIN: Starting Firebase request...');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      debugPrint('LOGIN: Firebase request completed.');
      debugPrint('LOGIN: Successful. UID = ${credential.user?.uid}');

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('LOGIN ERROR CODE: ${e.code}');
      debugPrint('LOGIN ERROR MESSAGE: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('LOGIN UNKNOWN ERROR: $e');
      rethrow;
    }
  }

  // FORGOT PASSWORD
  Future<void> resetPassword({
    required String email,
  }) async {
    try {
      debugPrint('PASSWORD RESET: Starting...');

      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      );

      debugPrint('PASSWORD RESET: Email sent successfully.');
    } on FirebaseAuthException catch (e) {
      debugPrint('PASSWORD RESET ERROR: ${e.code}');
      debugPrint('PASSWORD RESET MESSAGE: ${e.message}');
      rethrow;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    try {
      await _auth.signOut();
      debugPrint('LOGOUT: Successful.');
    } catch (e) {
      debugPrint('LOGOUT ERROR: $e');
      rethrow;
    }
  }
}
