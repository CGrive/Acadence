import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:provider/provider.dart';
import 'package:frontend/main.dart';
import 'dart:convert';
import '../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<String?> _authUser(LoginData data, BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await auth.apiService.login(data.name!, data.password!);
      print('Login response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final token = jsonDecode(response.body)['access_token'];
        auth.apiService.setToken(token);
        final userResp = await auth.apiService.get('/auth/me');
        if (userResp.statusCode == 200) {
          final userData = jsonDecode(userResp.body);
          final roleStr = userData['role'];          
          final name = userData['name'];
          UserRole role;
          switch (roleStr) {
            case 'admin':
              role = UserRole.admin;
              break;
            case 'faculty':
              role = UserRole.faculty;
              break;
            case 'student':
              role = UserRole.student;
              break;
            case 'exam_dept':
              role = UserRole.examDept;
              break;
            default:
              role = UserRole.student;
          }          
          auth.login(token, role, name);
          // print('After auth.login, auth.name = ${auth.name}');
          return null;
        } else {
          return 'Failed to get user info';
        }
      } else {
        return 'Invalid email or password';
      }
    } catch (e) {
      print('Login error: $e');
      return 'Connection error';
    }
  }

  Future<String?> _signupUser(SignupData data, BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await auth.apiService.postJson('/auth/register', {
        'email': data.name!,
        'name': data.name!,
        'password': data.password!,
        'role': 'student',                // default role
        'department': 'General',           // default department
      });
      if (response.statusCode == 200) {
        // Auto-login after successful registration
        final loginResp = await auth.apiService.login(data.name!, data.password!);
        if (loginResp.statusCode == 200) {
          final token = jsonDecode(loginResp.body)['access_token'];
          auth.apiService.setToken(token);
          final userResp = await auth.apiService.get('/auth/me');
          if (userResp.statusCode == 200) {
            final userData = jsonDecode(userResp.body);
            final roleStr = userData['role'];            
            final name = userData['name'];
            UserRole role;
            switch (roleStr) {
              case 'admin':
                role = UserRole.admin;
                break;
              case 'faculty':
                role = UserRole.faculty;
                break;
              case 'student':
                role = UserRole.student;
                break;
              case 'exam_dept':
                role = UserRole.examDept;
                break;
              default:
                role = UserRole.student;
            }
            auth.login(token, role, name);
            return null; // success
          }
        }
        return 'Auto-login failed, please log in manually';
      } else {
        // Parse backend error
        final errorBody = jsonDecode(response.body);
        if (errorBody is Map && errorBody.containsKey('detail')) {
          return errorBody['detail'].toString();
        }
        return 'Registration failed';
      }
    } catch (e) {
      print('Signup error: $e');
      return 'Connection error';
    }
  }

  Future<String> _recoverPassword(String name) {
    return Future.value('Password recovery not implemented. Please contact admin.');
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: '',
      headerWidget: Center(
        child: Container(
          height: 200,
          padding: const EdgeInsets.only(top: 40),
          child: Image.asset(
            'assets/logo/Acadence.png',
            width: 180,
            height: 180,
          ),
        ),
      ),
      onLogin: (data) => _authUser(data, context),
      onSignup: (data) => _signupUser(data, context),
      onSubmitAnimationCompleted: () {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        if (auth.isLoggedIn) {
          int initialIndex;
          switch (auth.role) {
            case UserRole.admin:
              initialIndex = 2;
              break;
            case UserRole.faculty:
              initialIndex = 3;
              break;
            case UserRole.student:
              initialIndex = 1;
              break;
            case UserRole.examDept:
              initialIndex = 4;
              break;
            default:
              initialIndex = 0;
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(initialIndex: initialIndex),
            ),
          );
        }
      },
      onRecoverPassword: _recoverPassword,
    );
  }
}