import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:smartcare/models/user.dart';
import 'package:smartcare/services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._firebaseService);

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    // notifyListeners();

    try {
      final firebaseUser = await _firebaseService.signInWithEmailAndPassword(
        email,
        password,
      );

      if (firebaseUser != null) {
        _currentUser = await _firebaseService.getUserProfile(firebaseUser.uid);

        if (_currentUser == null) {
          // Create a basic profile if it doesn't exist
          _currentUser = User(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'User',
            email: firebaseUser.email ?? email,
          );

          await _firebaseService.createUserProfile(_currentUser!);
        }

        _isLoading = false;
        // notifyListeners();
        return true;
      } else {
        _error = 'Failed to login';
        _isLoading = false;
        // notifyListeners();
        return false;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _error = 'No user found with this email';
          break;
        case 'wrong-password':
          _error = 'Wrong password';
          break;
        case 'invalid-email':
          _error = 'Invalid email format';
          break;
        default:
          _error = e.message ?? 'An error occurred';
      }
      _isLoading = false;
      // notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      // notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final firebaseUser =
          await _firebaseService.createUserWithEmailAndPassword(
        email,
        password,
      );

      if (firebaseUser != null) {
        // Update display name
        await firebaseUser.updateDisplayName(name);

        // Create user profile
        _currentUser = User(
          id: firebaseUser.uid,
          name: name,
          email: email,
        );

        await _firebaseService.createUserProfile(_currentUser!);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to register';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          _error = 'Email is already in use';
          break;
        case 'weak-password':
          _error = 'Password is too weak';
          break;
        case 'invalid-email':
          _error = 'Invalid email format';
          break;
        default:
          _error = e.message ?? 'An error occurred';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? name,
    String? address,
    String? phone,
    String? language,
    String? profileImage,
  }) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseService.updateUserProfile(
        _currentUser!.id,
        name: name,
        address: address,
        phone: phone,
        language: language,
        profileImage: profileImage,
      );

      // Update local user object
      _currentUser = _currentUser!.copyWith(
        name: name,
        address: address,
        phone: phone,
        language: language,
        profileImage: profileImage,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEmergencyContact(String name, String phone) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final contactId = await _firebaseService.addEmergencyContact(
        _currentUser!.id,
        name,
        phone,
      );

      final newContact = EmergencyContact(
        id: contactId,
        name: name,
        phone: phone,
      );

      final updatedContacts =
          List<EmergencyContact>.from(_currentUser!.emergencyContacts)
            ..add(newContact);

      _currentUser = _currentUser!.copyWith(
        emergencyContacts: updatedContacts,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeEmergencyContact(String id) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseService.removeEmergencyContact(_currentUser!.id, id);

      final updatedContacts = _currentUser!.emergencyContacts
          .where((contact) => contact.id != id)
          .toList();

      _currentUser = _currentUser!.copyWith(
        emergencyContacts: updatedContacts,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if user is already logged in
  Future<bool> checkCurrentUser() async {
    try {
      final currentFirebaseUser =
          firebase_auth.FirebaseAuth.instance.currentUser;

      if (currentFirebaseUser != null) {
        _currentUser =
            await _firebaseService.getUserProfile(currentFirebaseUser.uid);
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
