import 'package:flutter/material.dart';

class LectureMonitoringPage extends StatelessWidget {
  const LectureMonitoringPage({super.key});

  static const Color primaryAccent = Color(0xFF97A5C9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Lecture Monitoring",
          style: TextStyle(color: Colors.black),
        ),
        actions: const [
          CircleAvatar(backgroundColor: Color(0xFFF1D6A8), child: Text("A")),
          SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Daily Log",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Please confirm the lectures you have successfully conducted today to update the academic record.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),
            _markLectureConductedCard(),
            const SizedBox(height: 28),
            _conductedLecturesHistory(),
          ],
        ),
      ),
    );
  }

  // ───────────── Mark Lecture Conducted ─────────────
  Widget _markLectureConductedCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Mark Lecture Conducted",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          const Text("SUBJECT", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          DropdownButtonFormField(
            decoration: _inputDecoration("Select Subject"),
            items: const [],
            onChanged: (_) {},
          ),

          const SizedBox(height: 16),
          const Text("DATE", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          TextField(
            readOnly: true,
            decoration: _inputDecoration(
              "10/25/2023",
            ).copyWith(suffixIcon: const Icon(Icons.calendar_today)),
          ),

          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryAccent,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {},
            icon: const Icon(Icons.check_circle_outline),
            label: const Text("Mark as Conducted"),
          ),
        ],
      ),
    );
  }

  // ───────────── History ─────────────
  Widget _conductedLecturesHistory() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Conducted Lectures History",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.history, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 16),

          _historyRow(
            date: "Oct 24, 2023",
            time: "09:00 – 10:30 AM",
            subject: "Adv. Algorithms",
            room: "Room 402B",
          ),
          _historyRow(
            date: "Oct 23, 2023",
            time: "11:00 – 12:30 PM",
            subject: "Operating Sys.",
            room: "Room 105",
          ),
          _historyRow(
            date: "Oct 23, 2023",
            time: "02:00 – 03:30 PM",
            subject: "Database Mgmt.",
            room: "Lab 3",
          ),

          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text("View All Records"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyRow({
    required String date,
    required String time,
    required String subject,
    required String room,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(time, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(room, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Conducted",
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── Helpers ─────────────
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
