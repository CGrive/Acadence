import 'package:flutter/material.dart';
import '../../theme_colors.dart';

class SubjectManagementPage extends StatelessWidget {
  const SubjectManagementPage({super.key});

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
          "Subject Management",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Subject Management",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Configure academic curriculum and faculty allocations for the current semester.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),
            _addNewSubjectCard(),

            const SizedBox(height: 32),
            _existingSubjectsCard(),
          ],
        ),
      ),
    );
  }

  // ───────────────── Add New Subject ─────────────────
  Widget _addNewSubjectCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.add_circle_outline,
                color: ApplicationColors.primaryBlue,
              ),
              SizedBox(width: 8),
              Text(
                "Add New Subject",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _label("SUBJECT NAME"),
          _inputField("e.g. Distributed Systems"),

          const SizedBox(height: 16),

          _label("SUBJECT CODE"),
          _inputField("e.g. CS401"),

          const SizedBox(height: 16),

          _label("DEPARTMENT"),
          _dropdownField("Select Department"),

          const SizedBox(height: 16),

          _label("PRIMARY FACULTY / TEACHER"),
          _dropdownField("Select Faculty"),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: ApplicationColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {},
              icon: const Icon(Icons.assignment_ind_outlined),
              label: const Text(
                "Add & Assign",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── Existing Subjects ─────────────────
  Widget _existingSubjectsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Existing Subjects",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.download, color: Colors.grey),
            ],
          ),

          const SizedBox(height: 16),
          _tableHeader(),

          const Divider(),

          _subjectRow(
            subject: "Advanced Algorithms",
            code: "CS301 · Comp. Science",
            faculty: "Dr. Alan Turing",
          ),
          _subjectRow(
            subject: "Operating Systems",
            code: "CS302 · Comp. Science",
            faculty: "Prof. Grace Hopper",
          ),
          _subjectRow(
            subject: "Database Mgmt.",
            code: "CS305 · IT Dept.",
            faculty: "Dr. Barbara Liskov",
          ),

          const SizedBox(height: 16),

          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text("Download Curriculum CSV"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Row(
      children: const [
        Expanded(
          flex: 3,
          child: Text(
            "SUBJECT & CODE",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            "ALLOCATION",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            "ACTIONS",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _subjectRow({
    required String subject,
    required String code,
    required String faculty,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(code, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(faculty),
                const Text(
                  "Assigned",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.grey),
              onPressed: () {},
            ),
          ),
        ],
      ),
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

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _inputField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF4F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _dropdownField(String hint) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF4F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: const [],
      onChanged: (_) {},
    );
  }
}
