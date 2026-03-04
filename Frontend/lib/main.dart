import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/pages/navigation_rail.dart';
import 'package:frontend/pages/tab.dart';
import 'package:frontend/theme_colors.dart';
import 'package:frontend/pages/admin_dashboard.dart';
import 'package:frontend/pages/student_dashboard.dart';
import 'package:frontend/pages/faculty_dashboard.dart';
import 'package:frontend/pages/exam_department_shell.dart';
import 'package:frontend/state/app_state.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/auth/login_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Acadence',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
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
      return HomeScreen(initialIndex: initialIndex);
    } else {
      return const LoginScreen();
    }
  }
}

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, required this.initialIndex});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;
  bool isRailExpanded = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onDestinationSelected(int index) {
    if (index == 5) { // Settings is index 5
      _showLogoutDialog();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _showLogoutDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pop(context);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRailDrawer(
            selectedIndex: _selectedIndex,
            isExpanded: isRailExpanded,
            onToggle: () {
              setState(() {
                isRailExpanded = !isRailExpanded;
              });
            },
            onDestinationSelected: _onDestinationSelected,
          ),
          const VerticalDivider(
            thickness: 2,
            width: 2,
            color: ApplicationColors.primaryPurple,
          ),
          Expanded(child: Center(child: _handleRails(_selectedIndex))),
        ],
      ),
    );
  }

  Widget _handleRails(int index) {
    switch (index) {
      case 0:
        return TabHomePage();
      case 1:
        return const StudentDashboardTab();
      case 2:
        return const AdminDashboardTab();
      case 3:
        return const FacultyDashboardTab();
      case 4:
        return const ExamDepartmentShell();
      default:
        return const SizedBox.shrink(); // Settings shows no page
    }
  }
}