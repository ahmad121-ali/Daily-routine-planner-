import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal() {
    _init();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void _init() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _loadThemePreference(user.uid);
      }
    });
  }

  Future<void> _loadThemePreference(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data()!.containsKey('isDarkMode')) {
        _isDarkMode = doc.data()!['isDarkMode'] ?? true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading theme preference: $e");
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _saveThemePreference();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    await _saveThemePreference();
  }

  Future<void> _saveThemePreference() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      try {
        await _firestore.collection('users').doc(uid).update({
          'isDarkMode': _isDarkMode,
        });
      } catch (e) {
        // If document doesn't exist or field update fails
        debugPrint("Error saving theme preference: $e");
      }
    }
  }
}
