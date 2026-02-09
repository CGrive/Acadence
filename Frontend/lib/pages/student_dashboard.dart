import 'package:flutter/material.dart';

class StudentDashboardTab extends StatelessWidget {
  const StudentDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
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
              const Text(
                "Welcome back, let’s track your academic progress.",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 24),
              _statsRow(),
              const SizedBox(height: 32),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _upcomingLectures()),
                  const SizedBox(width: 24),
                  SizedBox(width: 320, child: _academicNotices()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔍 Top Bar
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
        const CircleAvatar(
          backgroundColor: Color(0xFF97A5C9),
          child: Icon(Icons.person, color: Colors.white),
        ),
      ],
    );
  }

  // 📊 KPI Cards
  Widget _statsRow() {
    return Row(
      children: const [
        _StatCard(
          title: "Today’s Lectures",
          value: "4",
          subtitle: "Next: 10:30 AM",
          icon: Icons.calendar_today,
        ),
        SizedBox(width: 16),
        _StatCard(
          title: "Upcoming Exams",
          value: "02",
          subtitle: "Applied Calculus – Nov 5",
          icon: Icons.assignment,
        ),
        SizedBox(width: 16),
        _StatCard(
          title: "Syllabus Progress",
          value: "72%",
          subtitle: "Active",
          icon: Icons.check_circle,
        ),
        SizedBox(width: 16),
        _StatCard(
          title: "Attendance",
          value: "88.5%",
          subtitle: "Target 75%",
          icon: Icons.bar_chart,
        ),
      ],
    );
  }

  // 📅 Upcoming Lectures
  Widget _upcomingLectures() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("Upcoming Lectures", "View Weekly Schedule"),
          const SizedBox(height: 16),

          _lectureRow(
            subject: "Data Structures",
            faculty: "Dr. Emily Watson",
            time: "10:30 AM",
            mode: "Physical",
          ),
          _lectureRow(
            subject: "Applied Calculus",
            faculty: "Prof. Mark Stevens",
            time: "01:00 PM",
            mode: "Online",
          ),
          _lectureRow(
            subject: "Cloud Computing",
            faculty: "Dr. Sophia Lin",
            time: "03:30 PM",
            mode: "Physical",
          ),
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
            backgroundColor: const Color(0xFF97A5C9).withOpacity(0.15),
          ),
        ],
      ),
    );
  }

  // 🚨 Academic Notices
  Widget _academicNotices() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Academic Notices",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _notice(
            title: "Final Exam Schedule Out",
            subtitle: "Check the exam timetable.",
            icon: Icons.warning_amber,
          ),
          _notice(
            title: "New Study Material Added",
            subtitle: "Chapter 5 notes uploaded.",
            icon: Icons.book,
          ),
          _notice(
            title: "Holiday Notice",
            subtitle: "College closed on Friday.",
            icon: Icons.event,
          ),

          const SizedBox(height: 12),
          TextButton(
            onPressed: () {},
            child: const Text("See All Announcements"),
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
          Icon(icon, color: const Color(0xFF97A5C9)),
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

  // 🧱 Shared UI helpers
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
        Text(action, style: const TextStyle(color: Color(0xFF97A5C9))),
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
            Icon(icon, color: const Color(0xFF97A5C9)),
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
