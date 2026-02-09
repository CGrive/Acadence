import 'package:flutter/material.dart';
import '../theme_colors.dart';
import 'package:frontend/pages/lecture_monitoring.dart';

class FacultyDashboardTab extends StatelessWidget {
  const FacultyDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Faculty Dashboard",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Welcome back, Prof. Anderson",
              style: TextStyle(color: Colors.grey),
            ),
            // YAha hai!
            const SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: ApplicationColors.primaryBlue.withOpacity(0.2),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: ApplicationColors.primaryBlue.withOpacity(
                              0.12,
                            ),

                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.schedule,
                            color: ApplicationColors.primaryBlue,
                          ),
                        ),

                        const SizedBox(height: 16),
                        Text(
                          "Lectures Today",
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 6),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: ApplicationColors.primaryBlue,
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: ApplicationColors.primaryBlue,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LectureMonitoringPage(),
                              ),
                            );
                          },
                          child: Text(
                            "3 Sessions",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Next: 11:00 AM",
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: ApplicationColors.primaryBlue,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Remaining Days",
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "12 Days",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Semester End",
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            _gradingQueue(),
            const SizedBox(height: 24),

            _questionPaperSubmission(),
            const SizedBox(height: 24),

            _quickStudentNotice(),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  // ───────────────── Grading Queue ─────────────────
  Widget _gradingQueue() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Grading Queue",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "4 Pending",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _gradingItem(
            subject: "Advanced Algorithms",
            subtitle: "Mid-Term · 42 Papers left",
            actionText: "Grade",
          ),
          _gradingItem(
            subject: "Operating Systems",
            subtitle: "Final Quiz · Completed",
            actionText: "Send to Exam Dept",
            filled: true,
          ),
        ],
      ),
    );
  }

  Widget _gradingItem({
    required String subject,
    required String subtitle,
    required String actionText,
    bool filled = false,
  }) {
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
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: filled
                  ? ApplicationColors.primaryBlue
                  : Colors.transparent,
              foregroundColor: filled
                  ? Colors.white
                  : ApplicationColors.primaryBlue,
              side: BorderSide(color: ApplicationColors.primaryBlue),
            ),
            onPressed: () {},
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  // ───────────────── Question Paper Submission ─────────────────
  Widget _questionPaperSubmission() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Question Paper Submission",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Row(
            children: const [
              Icon(Icons.description, color: ApplicationColors.primaryBlue),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Software Engineering - Sem Final",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "Draft saved 2h ago",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F2A3A),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {},
            child: const Text("Submit for Approval"),
          ),
        ],
      ),
    );
  }

  // ───────────────── Quick Student Notice ─────────────────
  Widget _quickStudentNotice() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Student Notice",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField(
            decoration: _inputDecoration("Select Class / Subject"),
            items: const [],
            onChanged: (_) {},
          ),
          const SizedBox(height: 12),

          TextField(
            maxLines: 3,
            decoration: _inputDecoration("Type your alert message here..."),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Sent to 85 students",
                style: TextStyle(color: Colors.grey),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ApplicationColors.primaryBlue,
                ),
                onPressed: () {},
                child: const Text("Send"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────── Bottom Navigation ─────────────────
  Widget _bottomNav() {
    return BottomNavigationBar(
      selectedItemColor: ApplicationColors.primaryBlue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.play_circle_outline),
          label: "Lectures",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_turned_in),
          label: "Grading",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.event_note), label: "Exams"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Setup"),
      ],
    );
  }

  // ───────────────── Helpers ─────────────────
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF4F6FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
