import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of user data from Firestore
  Stream<DocumentSnapshot> getUserDataStream() {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore.collection('users').doc(user.uid).snapshots();
    }
    return const Stream.empty();
  }

  // Get user data once
  Future<DocumentSnapshot?> getUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await _firestore.collection('users').doc(user.uid).get();
    }
    return null;
  }

  // Update Profile
  Future<void> updateProfile({String? fullName, String? email}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    Map<String, dynamic> updates = {};
    
    if (fullName != null && fullName.isNotEmpty) {
      await user.updateDisplayName(fullName);
      updates['fullName'] = fullName;
    }

    if (email != null && email.isNotEmpty && email != user.email) {
      // Sends a verification email to the new address
      await user.verifyBeforeUpdateEmail(email);
      updates['email'] = email;
    }

    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(user.uid).update(updates);
    }
  }

  // Update Notification Preference & Token
  Future<void> updateNotificationPreference(bool enabled) async {
    final user = _auth.currentUser;
    if (user == null) return;

    String? token;
    if (enabled) {
      token = await FirebaseMessaging.instance.getToken();
    }

    await _firestore.collection('users').doc(user.uid).update({
      'notificationsEnabled': enabled,
      'fcmToken': enabled ? token : FieldValue.delete(),
    });
  }

  // Sign Up with Email and Password
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(fullName);
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'fullName': fullName,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'isGuest': false,
          'notificationsEnabled': true,
        });
      }
      return userCredential;
    } catch (e) {
      debugPrint("Sign Up Error: $e");
      rethrow;
    }
  }

  // Login
  Future<UserCredential?> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint("Login Error: $e");
      rethrow;
    }
  }

  // Guest Login
  Future<UserCredential?> signInAnonymously() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'fullName': 'Guest User',
          'createdAt': FieldValue.serverTimestamp(),
          'isGuest': true,
          'notificationsEnabled': true,
        }, SetOptions(merge: true));
      }
      return userCredential;
    } catch (e) {
      debugPrint("Guest Login Error: $e");
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
