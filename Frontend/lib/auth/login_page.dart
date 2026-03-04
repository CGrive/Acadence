import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:provider/provider.dart';
import 'package:frontend/main.dart';  // instead of '../main.dart'
import 'dart:convert';
import '../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<String?> _authUser(LoginData data, BuildContext context) async {
  final auth = Provider.of<AuthProvider>(context, listen: false);
  try {
    final response = await auth.apiService.login(data.name, data.password);
    print('Login response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)['access_token'];
      auth.login(token);
      return null;
    } else {
      return 'Invalid email or password';
    }
  } catch (e) {
    print('Login error: $e');
    return 'Connection error';
  }
}

  Future<String?> _signupUser(SignupData data, BuildContext context) {
    return Future.value('Signup not available');
  }

  Future<String> _recoverPassword(String name) {
    return Future.value('Recovery not available');
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Acadence',
      logo: const AssetImage('assets/logo/Acadence.png'),
      onLogin: (data) => _authUser(data, context),
      onSignup: (data) => _signupUser(data, context),
      onSubmitAnimationCompleted: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      },
      onRecoverPassword: _recoverPassword,
    );
  }
}