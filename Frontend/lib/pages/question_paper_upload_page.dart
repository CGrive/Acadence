import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:file_picker/file_picker.dart';
import 'dart:math';

import '../theme_colors.dart';
import 'package:frontend/state/app_state.dart';
import 'package:frontend/models/enums.dart';

class QuestionPaperUploadPage extends StatefulWidget {
  const QuestionPaperUploadPage({super.key});

  @override
  State<QuestionPaperUploadPage> createState() =>
      _QuestionPaperUploadPageState();
}

class _QuestionPaperUploadPageState extends State<QuestionPaperUploadPage> {
  String? selectedSubject;
  String? selectedExamType;
  PlatformFile? selectedFile;

  final List<String> subjects = [
    "Advanced Algorithms",
    "Operating Systems",
    "Database Management",
    "Computer Networks",
  ];

  final List<String> examTypes = ["Midterm", "End Semester"];

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

  // ───────── Upload Form ─────────
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

          DropdownButtonFormField<String>(
            value: selectedSubject,
            decoration: _inputDecoration("Select Subject"),
            items: subjects
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (value) => setState(() => selectedSubject = value),
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: selectedExamType,
            decoration: _inputDecoration("Select Exam Type"),
            items: examTypes
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) => setState(() => selectedExamType = value),
          ),

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
              onPressed: _submitPaper,
              child: const Text("Upload for Approval"),
            ),
          ),
        ],
      ),
    );
  }

  // ───────── File Picker ─────────
  Widget _fileUploadBox() {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: _pickFile,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selectedFile == null
                ? Colors.grey.shade300
                : ApplicationColors.primaryBlue,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selectedFile == null
                    ? Icons.cloud_upload_outlined
                    : Icons.insert_drive_file,
                size: 40,
                color: selectedFile == null
                    ? Colors.grey
                    : ApplicationColors.primaryBlue,
              ),
              const SizedBox(height: 8),
              Text(
                selectedFile == null
                    ? "Tap to browse or drop file"
                    : selectedFile!.name,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    if (kIsWeb) {
      final input = html.FileUploadInputElement()..accept = '.pdf,.doc,.docx';
      input.click();

      input.onChange.listen((_) {
        final file = input.files?.first;
        if (file != null) {
          setState(() {
            selectedFile = PlatformFile(name: file.name, size: file.size);
          });
        }
      });
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() => selectedFile = result.files.first);
    }
  }

  // ───────── Submit ─────────
  void _submitPaper() {
    if (selectedSubject == null ||
        selectedExamType == null ||
        selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    final paper = Paper(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subject: selectedSubject!,
      faculty: "Faculty User",
      date: DateTime.now(),
      status: PaperStatus.pending,
    );

    context.read<AppState>().submitPaper(paper);

    setState(() {
      selectedSubject = null;
      selectedExamType = null;
      selectedFile = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Paper submitted for approval")),
    );
  }

  // ───────── Submission History ─────────
  Widget _submissionHistory() {
    final myPapers = AppState.papers
        .where((p) => p.faculty == "Faculty User")
        .toList();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Submission History",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (myPapers.isEmpty)
            const Text(
              "No submissions yet",
              style: TextStyle(color: Colors.grey),
            ),
          for (final paper in myPapers)
            _HistoryRow(
              subject: paper.subject,
              status: paper.status.name.toUpperCase(),
              color: _statusColor(paper.status),
            ),
        ],
      ),
    );
  }

  Color _statusColor(PaperStatus status) {
    switch (status) {
      case PaperStatus.approved:
        return Colors.green;
      case PaperStatus.pending:
        return Colors.orange;
      case PaperStatus.rejected:
        return Colors.red;
      case PaperStatus.draft:
        return Colors.grey;
    }
  }

  // ───────── UI helpers ─────────
  Widget _deadlineBanner() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.red.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Row(
      children: [
        Icon(Icons.warning_amber, color: Colors.red),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            "Deadline Remaining: 02 Days 14 Hours",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF4F6FA),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );

  Widget _card({required Widget child}) => Container(
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
