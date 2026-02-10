import 'package:flutter/material.dart';
import '../theme_colors.dart';

class ExamDepartmentDashboard extends StatelessWidget {
  const ExamDepartmentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text("Exam Department",
            style: TextStyle(color: Colors.black)),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.black),
          SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Dashboard Overview",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text("Semester Finals · Operational Summary",
                style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 20),
            _kpiRow(),

            const SizedBox(height: 28),
            _urgentFacultyNotifications(),

            const SizedBox(height: 28),
            _invigilationOverview(),
          ],
        ),
      ),
    );
  }

  Widget _kpiRow() {
    return Row(
      children: const [
        _MiniKpiCard("Pending Approvals", "12", Colors.orange),
        SizedBox(width: 12),
        _MiniKpiCard("Invigilation Gaps", "03", Colors.red),
        SizedBox(width: 12),
        _MiniKpiCard("Papers Uploaded", "08", Colors.green),
        SizedBox(width: 12),
        _MiniKpiCard("Active Exams", "25", Colors.blue),
      ],
    );
  }

  Widget _urgentFacultyNotifications() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Urgent: Faculty Notifications",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          _FacultyRow("Dr. Robert Arnold", "CS401 · AI", "4h remaining", true),
          _FacultyRow(
              "Prof. Sarah Mitchell", "EC302 · Digital Logic", "12h remaining", false),
        ],
      ),
    );
  }

  Widget _invigilationOverview() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Invigilation Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          _InvigilationRow("Calculus II", "10:00 AM", "Room 302", true),
          _InvigilationRow("Data Structures", "01:00 PM", "Main Lab", false),
          _InvigilationRow("Networking", "03:00 PM", "Room 405", true),
        ],
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12),
        ],
      ),
      child: child,
    );
  }
}

// ───── Sub-widgets ─────

class _MiniKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _MiniKpiCard(this.title, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Text(value,
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _FacultyRow extends StatelessWidget {
  final String name, subject, remaining;
  final bool urgent;

  const _FacultyRow(this.name, this.subject, this.remaining, this.urgent);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                urgent ? Colors.red.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
            child: Text(name[0]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subject, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(remaining,
                  style: TextStyle(
                      fontSize: 12,
                      color: urgent ? Colors.red : Colors.orange)),
              const SizedBox(height: 6),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ApplicationColors.primaryBlue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                onPressed: () {},
                child: const Text("Send Reminder"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvigilationRow extends StatelessWidget {
  final String subject, time, room;
  final bool assigned;

  const _InvigilationRow(this.subject, this.time, this.room, this.assigned);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text("$time · $room",
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: assigned
                  ? Colors.green.withOpacity(0.15)
                  : Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(assigned ? "Assigned" : "Allocate",
                style:
                    TextStyle(color: assigned ? Colors.green : Colors.orange)),
          ),
        ],
      ),
    );
  }
}
