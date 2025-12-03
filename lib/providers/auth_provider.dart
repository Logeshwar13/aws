// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseService.auth;
  User? _user;
  bool _loading = true;
  bool get isLoading => _loading;
  User? get user => _user;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _user = _auth.currentUser;

    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _loading = false;
      notifyListeners();
    });

    // If no user is logged in, sign in anonymously to allow reading public data/images
    if (_user == null) {
      try {
        debugPrint('AuthProvider: Signing in anonymously...');
        await _auth.signInAnonymously();
      } catch (e) {
        debugPrint('AuthProvider: Error signing in anonymously: $e');
      }
    }

    _loading = false;
    notifyListeners();
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    _loading = true;
    notifyListeners();
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = credential.user;
      _loading = false;
      notifyListeners();
      return credential;
    } catch (e) {
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<UserCredential> signUp(String email, String password) async {
    _loading = true;
    notifyListeners();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = credential.user;
      _loading = false;
      notifyListeners();
      return credential;
    } catch (e) {
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }
}
