import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme_colors.dart';
import 'package:frontend/state/app_state.dart';
import 'package:frontend/models/enums.dart';

class PaperApprovalPage extends StatelessWidget {
  const PaperApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pendingPapers = context.watch<AppState>().pendingPapers;

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

            if (pendingPapers.isEmpty)
              const Text(
                "No pending papers 🎉",
                style: TextStyle(color: Colors.grey),
              ),

            for (final paper in pendingPapers)
              _PaperCard(paper: paper),

            const SizedBox(height: 28),
            const _ReviewChecklist(),
          ],
        ),
      ),
    );
  }
}

/* ───────────────── PAPER CARD ───────────────── */

class _PaperCard extends StatelessWidget {
  final Paper paper;
  const _PaperCard({required this.paper});

  @override
  Widget build(BuildContext context) {
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
                  Text(
                    paper.subject,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    paper.faculty,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${paper.date.day}/${paper.date.month}",
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          OutlinedButton.icon(
            icon: const Icon(Icons.remove_red_eye),
            label: const Text("View Paper"),
            onPressed: () {
              // later: open PDF from backend / storage
            },
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
                  onPressed: () {
                    context.read<AppState>().approvePaper(paper);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Paper Approved")),
                    );
                  },
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
                  onPressed: () {
                    context.read<AppState>().rejectPaper(paper);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Paper Rejected")),
                    );
                  },
                  child: const Text("Reject"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ───────────────── REVIEW CHECKLIST ───────────────── */

class _ReviewChecklist extends StatelessWidget {
  const _ReviewChecklist();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
