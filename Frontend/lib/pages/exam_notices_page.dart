import 'package:flutter/material.dart';
import '../../theme_colors.dart';

class ExamNoticesPage extends StatelessWidget {
  const ExamNoticesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: _appBar("Exam Notices"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Send Exam Notice",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _noticeForm(),

            const SizedBox(height: 32),

            const Text(
              "Notice History",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _noticeHistory(
              title: "Question Paper Upload Deadline",
              subtitle: "Sent to all faculty · 2h ago",
            ),
            _noticeHistory(
              title: "Invigilation Assignment Reminder",
              subtitle: "Sent to selected faculty · Yesterday",
            ),
          ],
        ),
      ),
    );
  }

  Widget _noticeForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12),
        ],
      ),
      child: Column(
        children: [
          DropdownButtonFormField(
            decoration: _input("Target Audience"),
            items: const [],
            onChanged: (_) {},
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 3,
            decoration: _input("Type notice message"),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ApplicationColors.primaryBlue,
              ),
              onPressed: () {},
              child: const Text("Send Notice"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _noticeHistory({
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      leading: const Icon(Icons.notifications_active),
    );
  }

  InputDecoration _input(String hint) {
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

  AppBar _appBar(String title) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Text(title, style: const TextStyle(color: Colors.black)),
    );
  }
}
