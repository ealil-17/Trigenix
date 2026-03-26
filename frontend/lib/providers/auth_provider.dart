import 'package:flutter/material.dart';

enum AppRole { none, patient, doctor }

class AuthProvider with ChangeNotifier {
  AppRole _role = AppRole.none;
  bool _isAuthenticated = false;

  AppRole get role => _role;
  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String email, String password, AppRole selectedRole) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    
    // In a real app we'd validate via backend. Here we mock success.
    if (email.isNotEmpty && password.isNotEmpty) {
      _role = selectedRole;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _role = AppRole.none;
    _isAuthenticated = false;
    notifyListeners();
  }
}
