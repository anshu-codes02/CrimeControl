import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = true; // Start with loading true
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  // Constructor to check auth status on initialization
  AuthProvider() {
    checkAuthStatus();
  }

  Future<void> login(String username, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.login(username, password);
      if (result['user'] != null) {
        _user = User.fromJson(result['user']);
        notifyListeners();
      } else {
        _setError('Login failed: Invalid response from server.');
      }
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(Map<String, dynamic> userJson) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.register(userJson);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
      // Clear all user state completely
      _user = null;
      _error = null;
      // Force a complete state refresh
      notifyListeners();
    } catch (e) {
      print('Logout error: $e');
      // Even if logout fails, clear local state completely
      _user = null;
      _error = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> checkAuthStatus() async {
    _setLoading(true);
    _clearError();
    try {
      _user = await _authService.getCurrentUser().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Auth status check timed out');
          return null;
        },
      );
      notifyListeners();
    } catch (e) {
      print('Error checking auth status: $e');
      _user = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
