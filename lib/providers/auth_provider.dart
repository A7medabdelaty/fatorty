import 'package:flutter/foundation.dart';

enum UserRole { admin, cashier }

class AuthProvider with ChangeNotifier {
  UserRole? _currentRole;
  bool _isAuthenticated = false;

  UserRole? get currentRole => _currentRole;
  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String username, String password, UserRole role) async {
    // TODO: Implement actual authentication logic
    // For now, we'll just simulate a successful login
    await Future.delayed(const Duration(seconds: 1));

    _currentRole = role;
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentRole = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
