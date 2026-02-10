import 'package:flutter/material.dart';
import '../../theme_colors.dart';

class QuestionPaperUploadPage extends StatelessWidget {
  const QuestionPaperUploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Question Paper Upload",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _deadlineBanner(),
            const SizedBox(height: 24),
            _uploadForm(),
            const SizedBox(height: 32),
            _submissionHistory(),
          ],
        ),
      ),
    );
  }

  Widget _deadlineBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: const [
          Icon(Icons.warning_amber, color: Colors.red),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Deadline Remaining: 02 Days 14 Hours",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _uploadForm() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Submit New Paper",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _dropdown("Select Subject"),
          const SizedBox(height: 12),
          _dropdown("Select Exam Type"),

          const SizedBox(height: 16),
          _fileUploadBox(),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ApplicationColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {},
              child: const Text("Upload for Approval"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fileUploadBox() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text("Tap to browse or drop file"),
          ],
        ),
      ),
    );
  }

  Widget _submissionHistory() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Submission History",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _HistoryRow(
            subject: "Advanced Algorithms",
            status: "Approved",
            color: Colors.green,
          ),
          _HistoryRow(
            subject: "Operating Systems",
            status: "Pending",
            color: Colors.orange,
          ),
          _HistoryRow(
            subject: "Database Mgmt.",
            status: "Revision Required",
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _dropdown(String hint) {
    return DropdownButtonFormField(
      decoration: _inputDecoration(hint),
      items: const [],
      onChanged: (_) {},
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

class _HistoryRow extends StatelessWidget {
  final String subject;
  final String status;
  final Color color;

  const _HistoryRow({
    required this.subject,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(subject),
          Chip(
            label: Text(status),
            backgroundColor: color.withOpacity(0.15),
            labelStyle: TextStyle(color: color),
          ),
        ],
      ),
    );
  }
}
