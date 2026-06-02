import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  static const String _userKey = 'cardiosense_cached_user';

  AuthService() {
    _loadSession();
    // Also listen to auth state changes from Firebase
    _auth.authStateChanges().listen((fb_auth.User? fbUser) async {
      if (fbUser == null) {
        _currentUser = null;
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_userKey);
        notifyListeners();
      } else if (_currentUser == null) {
        // Try to recover user data from Firestore if session lost
        await _fetchUserData(fbUser.uid);
      }
    });
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_userKey);
    if (cached != null) {
      try {
        _currentUser = User.fromJson(jsonDecode(cached));
        notifyListeners();
      } catch (_) {
        // Cached format outdated, ignore
      }
    }
  }

  Future<void> _fetchUserData(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = User.fromJson({...doc.data()!, 'id': doc.id});
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Firebase Authentication
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // 2. Fetch User Details from Firestore to verify role
      final doc = await _db.collection('users').doc(result.user!.uid).get();
      
      if (doc.exists) {
        final userData = doc.data()!;
        if (userData['role'] != role) {
          await _auth.signOut();
          _isLoading = false;
          notifyListeners();
          return {'success': false, 'message': 'Incorrect role selected for this account.'};
        }

        _currentUser = User.fromJson({...userData, 'id': doc.id});
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
        
        _isLoading = false;
        notifyListeners();
        return {'success': true};
      } else {
        await _auth.signOut();
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': 'User profile not found.'};
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': e.message ?? 'Authentication failed.'};
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Create User in Firebase Auth
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      // 2. Store additional user data in Firestore
      final userData = {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      await _db.collection('users').doc(result.user!.uid).set(userData);

      _isLoading = false;
      notifyListeners();
      return {'success': true};
    } on fb_auth.FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': e.message ?? 'Registration failed.'};
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    notifyListeners();
  }
}
