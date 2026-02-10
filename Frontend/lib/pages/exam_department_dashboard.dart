import 'package:flutter/material.dart';
import '../theme_colors.dart';
import 'question_paper_approval_page.dart';

class ExamDepartmentDashboard extends StatelessWidget {
  const ExamDepartmentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Exam Department",
          style: TextStyle(color: Colors.black),
        ),
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
            const Text(
              "Dashboard Overview",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Semester Finals · Operational Summary",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),
            _kpiRow(context),

            const SizedBox(height: 28),
            _urgentFacultyNotifications(),

            const SizedBox(height: 28),
            _invigilationOverview(),
          ],
        ),
      ),
    );
  }

  // ───────────────── KPI ROW (COMPACT) ─────────────────
  Widget _kpiRow(BuildContext context) {
    return Row(
      children: [
        _MiniKpiCard(
          title: "Pending Approvals",
          value: "12",
          color: Colors.orange,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaperApprovalPage()),
            );
          },
        ),
        const SizedBox(width: 12),
        const _MiniKpiCard(
          title: "Invigilation Gaps",
          value: "03",
          color: Colors.red,
        ),
        const SizedBox(width: 12),
        const _MiniKpiCard(
          title: "Papers Uploaded",
          value: "08",
          color: Colors.green,
        ),
        const SizedBox(width: 12),
        const _MiniKpiCard(
          title: "Active Exams",
          value: "25",
          color: Colors.blue,
        ),
      ],
    );
  }

  // ───────────────── Faculty Notifications ─────────────────
  Widget _urgentFacultyNotifications() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Urgent: Faculty Notifications",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _facultyRow(
            name: "Dr. Robert Arnold",
            subject: "CS401 · AI",
            remaining: "4h remaining",
            urgent: true,
          ),
          _facultyRow(
            name: "Prof. Sarah Mitchell",
            subject: "EC302 · Digital Logic",
            remaining: "12h remaining",
            urgent: false,
          ),
        ],
      ),
    );
  }

  Widget _facultyRow({
    required String name,
    required String subject,
    required String remaining,
    required bool urgent,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: urgent
                ? Colors.red.withOpacity(0.2)
                : Colors.blue.withOpacity(0.2),
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
              Text(
                remaining,
                style: TextStyle(
                  fontSize: 12,
                  color: urgent ? Colors.red : Colors.orange,
                ),
              ),
              const SizedBox(height: 6),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ApplicationColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
                onPressed: () {
                  // 🔔 Hook notification logic here later
                },
                child: const Text("Send Reminder"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────── Invigilation Overview ─────────────────
  Widget _invigilationOverview() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Invigilation Overview",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _InvigilationRow(
            subject: "Calculus II",
            time: "10:00 AM",
            room: "Room 302",
            assigned: true,
          ),
          _InvigilationRow(
            subject: "Data Structures",
            time: "01:00 PM",
            room: "Main Lab",
            assigned: false,
          ),
          _InvigilationRow(
            subject: "Networking",
            time: "03:00 PM",
            room: "Room 405",
            assigned: true,
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12),
        ],
      ),
      child: child,
    );
  }
}

// ───────────────── KPI CARD ─────────────────
class _MiniKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _MiniKpiCard({
    required this.title,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvigilationRow extends StatelessWidget {
  final String subject;
  final String time;
  final String room;
  final bool assigned;

  const _InvigilationRow({
    required this.subject,
    required this.time,
    required this.room,
    required this.assigned,
  });

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
                Text(
                  subject,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  "$time · $room",
                  style: const TextStyle(color: Colors.grey),
                ),
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
            child: Text(
              assigned ? "Assigned" : "Allocate",
              style: TextStyle(color: assigned ? Colors.green : Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}
