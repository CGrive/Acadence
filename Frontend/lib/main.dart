import 'package:flutter/material.dart';
import 'package:frontend/pages/navigation_rail.dart';
import 'package:frontend/pages/tab.dart';
import 'package:frontend/theme_colors.dart';
import 'package:frontend/pages/admin_dashboard.dart';
import 'package:frontend/pages/student_dashboard.dart';
import 'package:frontend/pages/faculty_dashboard.dart';
import 'package:frontend/pages/exam_department_shell.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => AppState(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool isRailExpanded = false;
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
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          const VerticalDivider(
            thickness: 2,
            width: 2,
            color: ApplicationColors.primaryBlue,
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
        return Text(
          "Nothing is selected; Make sure one of side rails are selected :)",
        );
    }
  }
}
