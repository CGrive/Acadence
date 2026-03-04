import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_colors.dart';
import '../providers/auth_provider.dart';

class StudentDashboardTab extends StatefulWidget {
  const StudentDashboardTab({super.key});

  @override
  State<StudentDashboardTab> createState() => _StudentDashboardTabState();
}

class _StudentDashboardTabState extends State<StudentDashboardTab> {
  Map<String, dynamic> _dashboardData = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final api = context.read<AuthProvider>().apiService;
    try {
      final response = await api.get('/student/dashboard');
      if (response.statusCode == 200) {
        setState(() {
          _dashboardData = jsonDecode(response.body);
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load data';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refresh,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final lectures = _dashboardData['today_lectures'] ?? [];
    final exams = _dashboardData['upcoming_exams'] ?? [];
    final progress = _dashboardData['syllabus_progress'] ?? 0;
    final attendance = _dashboardData['attendance'] ?? 0.0;
    final notices = _dashboardData['notices'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(),
              const SizedBox(height: 24),

              const Text(
                "Student Dashboard",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                "Welcome back, ${context.watch<AuthProvider>().name ?? 'Student'}",
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 24),
              _statsRow(lectures.length, exams.length, progress, attendance),
              const SizedBox(height: 32),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _upcomingLectures(lectures)),
                  const SizedBox(width: 24),
                  SizedBox(width: 320, child: _academicNotices(notices)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search lectures, syllabus...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFFF4F6FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Icon(Icons.notifications_none),
        const SizedBox(width: 16),
        CircleAvatar(
          backgroundColor: ApplicationColors.primaryPurple,
          child: const Icon(Icons.person, color: Colors.white),
        ),
      ],
    );
  }

  Widget _statsRow(int lectureCount, int examCount, int progress, double attendance) {
    return Row(
      children: [
        _StatCard(
          title: "Today’s Lectures",
          value: lectureCount.toString(),
          subtitle: lectureCount > 0 ? "Check schedule" : "No lectures",
          icon: Icons.calendar_today,
        ),
        const SizedBox(width: 16),
        _StatCard(
          title: "Upcoming Exams",
          value: examCount.toString(),
          subtitle: examCount > 0 ? "Prepare well" : "No exams",
          icon: Icons.assignment,
        ),
        const SizedBox(width: 16),
        _StatCard(
          title: "Syllabus Progress",
          value: "$progress%",
          subtitle: "Keep going",
          icon: Icons.check_circle,
        ),
        const SizedBox(width: 16),
        _StatCard(
          title: "Attendance",
          value: "${attendance.toStringAsFixed(1)}%",
          subtitle: attendance >= 75 ? "Good" : "Needs attention",
          icon: Icons.bar_chart,
        ),
      ],
    );
  }

  Widget _upcomingLectures(List<dynamic> lectures) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("Today's Lectures", "View All"),
          const SizedBox(height: 16),
          if (lectures.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text("No lectures today")),
            )
          else
            ...lectures.map((l) => _lectureRow(
                  subject: l['subject'] ?? 'Unknown',
                  faculty: l['faculty'] ?? 'Unknown',
                  time: l['time'] ?? 'TBD',
                  mode: l['mode'] ?? 'Physical',
                )).toList(),
        ],
      ),
    );
  }

  Widget _lectureRow({
    required String subject,
    required String faculty,
    required String time,
    required String mode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              subject,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(faculty)),
          Text(time),
          const SizedBox(width: 12),
          Chip(
            label: Text(mode),
            backgroundColor: ApplicationColors.primaryPurple.withOpacity(0.15),
          ),
        ],
      ),
    );
  }

  Widget _academicNotices(List<dynamic> notices) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Notices",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (notices.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text("No notices")),
            )
          else
            ...notices.take(3).map((n) => _notice(
                  title: n['title'] ?? 'Notice',
                  subtitle: n['content'] ?? '',
                  icon: Icons.notifications_active,
                )).toList(),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {},
            child: const Text("See All"),
          ),
        ],
      ),
    );
  }

  Widget _notice({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: ApplicationColors.primaryPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(action, style: TextStyle(color: ApplicationColors.primaryPurple)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: ApplicationColors.primaryPurple),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}