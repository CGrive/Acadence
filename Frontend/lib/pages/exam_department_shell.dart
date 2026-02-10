import 'package:flutter/material.dart';
import '../theme_colors.dart';
import 'package:frontend/pages/exam_department_dashboard.dart';
import 'package:frontend/pages/question_paper_approval_page.dart';
import 'package:frontend/pages/invigilation_page.dart';
import 'package:frontend/pages/exam_notices_page.dart';

class ExamDepartmentShell extends StatefulWidget {
  const ExamDepartmentShell({super.key});

  @override
  State<ExamDepartmentShell> createState() => _ExamDepartmentShellState();
}

class _ExamDepartmentShellState extends State<ExamDepartmentShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ExamDepartmentDashboard(),
    PaperApprovalPage(),
    InvigilationPage(),
    ExamNoticesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: ApplicationColors.primaryBlue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Overview",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: "Approvals",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_ind),
            label: "Invigilation",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notices",
          ),
        ],
      ),
    );
  }
}
