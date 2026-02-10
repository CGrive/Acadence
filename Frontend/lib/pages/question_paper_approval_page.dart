import 'package:flutter/material.dart';
import '../theme_colors.dart';

class PaperApprovalPage extends StatelessWidget {
  const PaperApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Paper Approval",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pending Reviews",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _paperCard(
              context,
              subject: "CS401 – Advanced AI",
              faculty: "Dr. Alan Turing",
              date: "24 OCT",
            ),
            _paperCard(
              context,
              subject: "CS302 – OS Design",
              faculty: "Prof. Grace Hopper",
              date: "25 OCT",
            ),

            const SizedBox(height: 28),
            _reviewChecklist(),
          ],
        ),
      ),
    );
  }

  Widget _paperCard(
    BuildContext context, {
    required String subject,
    required String faculty,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subject,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(faculty,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(date),
              ),
            ],
          ),

          const SizedBox(height: 16),

          OutlinedButton.icon(
            icon: const Icon(Icons.remove_red_eye),
            label: const Text("View Paper"),
            onPressed: () {},
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.15),
                    foregroundColor: Colors.green,
                  ),
                  onPressed: () {},
                  child: const Text("Approve"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.15),
                    foregroundColor: Colors.red,
                  ),
                  onPressed: () {},
                  child: const Text("Reject"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reviewChecklist() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Review Checklist",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _ChecklistItem("Bloom’s Taxonomy Alignment"),
          _ChecklistItem("Time & Duration Check"),
          _ChecklistItem("Syllabus Coverage"),
          _ChecklistItem("Formatting Standards"),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final String text;
  const _ChecklistItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.radio_button_unchecked, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
