import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../data/static_data.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    try {
      final user = StaticData.users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
        orElse: () => throw Exception('User not found'),
      );

      if (password.length < 6) {
        throw Exception('Invalid password');
      }

      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Invalid email or password';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password, String phone) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    try {
      final existingUser = StaticData.users.any(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );

      if (existingUser) {
        throw Exception('Email already exists');
      }

      final newUser = UserModel(
        id: 'user${StaticData.users.length + 1}',
        name: name,
        email: email,
        phoneNumber: phone,
        isAdmin: false,
        createdAt: DateTime.now(),
      );

      StaticData.users.add(newUser);
      _currentUser = newUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void updateProfile(String name) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(name: name);
      final index = StaticData.users.indexWhere((u) => u.id == _currentUser!.id);
      if (index != -1) {
        StaticData.users[index] = _currentUser!;
      }
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}