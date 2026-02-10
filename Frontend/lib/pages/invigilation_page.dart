import 'package:flutter/material.dart';
import '../../theme_colors.dart';

class InvigilationPage extends StatelessWidget {
  const InvigilationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: _appBar("Invigilation"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Invigilation Allocation",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text("Assign faculty members for upcoming exams.",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),

            _invigilationCard("Data Structures", "01:00 PM", "Main Lab", false),
            _invigilationCard("Networking", "03:00 PM", "Room 405", true),
          ],
        ),
      ),
    );
  }

  Widget _invigilationCard(
      String subject, String time, String room, bool assigned) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12),
        ],
      ),
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  assigned ? Colors.green.withOpacity(0.15) : ApplicationColors.primaryBlue,
              foregroundColor: assigned ? Colors.green : Colors.white,
            ),
            onPressed: () {},
            child: Text(assigned ? "Assigned" : "Allocate"),
          ),
        ],
      ),
    );
  }

  AppBar _appBar(String title) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Text(title, style: const TextStyle(color: Colors.black)),
    );
  }
}
