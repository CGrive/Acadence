import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  String? _token;

  ApiService get apiService => _apiService;
  String? get token => _token;
  bool get isLoggedIn => _token != null;

  void login(String token) {
    _token = token;
    _apiService.setToken(token);
    notifyListeners();
  }

  void logout() {
    _token = null;
    _apiService.setToken('');
    notifyListeners();
  }
}