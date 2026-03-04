import 'package:flutter/material.dart';
import '../services/api_service.dart';

enum UserRole { admin, faculty, student, examDept }

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  String? _token;
  UserRole? _role;
  String? _name;

  ApiService get apiService => _apiService;
  String? get token => _token;
  UserRole? get role => _role;
  String? get name {
    // print('AuthProvider.name getter called, returning: $_name');
    return _name;
  }
  bool get isLoggedIn => _token != null;

  void login(String token, UserRole role, String name) {
    // print('AuthProvider.login called with name: $name');
    _token = token;
    _role = role;
    _name = name;
    _apiService.setToken(token);
    notifyListeners();
  }

  void logout() {
    _token = null;
    _role = null;
    _name = null;
    _apiService.setToken('');
    notifyListeners();
  }
}