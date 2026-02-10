import 'package:flutter/material.dart';
import 'package:frontend/pages/subject_management.dart';
import '../theme_colors.dart';
import 'package:frontend/state/app_state.dart';
import 'package:frontend/models/enums.dart';

class AdminDashboardTab extends StatelessWidget {
  const AdminDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _topSearchBar(),
            const SizedBox(height: 24),

            const Text(
              "Institutional Overview",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: ApplicationColors.ivoryWhite,
              ),
            ),

            const SizedBox(height: 24),
            _statsRow(),

            const SizedBox(height: 32),
            _recentSubmissionsTable(),

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SubjectManagementPage(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Assign Subjects",
                    style: TextStyle(
                      fontSize: 20,
                      color: ApplicationColors.primaryBlue,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────── Search Bar ─────────────────
  Widget _topSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search for subjects, faculty or departments...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: ApplicationColors.primaryBlue,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ───────────────── Stats Row (CONNECTED) ─────────────────
  Widget _statsRow() {
    final approvedCount = AppState.papers
        .where((p) => p.status == PaperStatus.approved)
        .length;

    final totalPapers = AppState.papers.length;

    return Row(
      children: [
        const _StatCard("Total Departments", "12", Icons.apartment),
        const SizedBox(width: 16),
        const _StatCard("Active Subjects", "450", Icons.book),
        const SizedBox(width: 16),
        const _StatCard("Daily Lectures", "85", Icons.school),
        const SizedBox(width: 16),
        _StatCard(
          "Question Papers",
          "$approvedCount / $totalPapers",
          Icons.description,
        ),
      ],
    );
  }

  // ───────────────── Recent Submissions Table (CONNECTED) ─────────────────
  Widget _recentSubmissionsTable() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ApplicationColors.primaryBlue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: DataTable(
          headingTextStyle: const TextStyle(
            color: ApplicationColors.ivoryWhite,
          ),
          columns: const [
            DataColumn(label: Text("Subject")),
            DataColumn(label: Text("Faculty")),
            DataColumn(label: Text("Date")),
            DataColumn(label: Text("Status")),
          ],
          rows: AppState.papers.map((paper) {
            return DataRow(
              cells: [
                DataCell(Text(paper.subject)),
                DataCell(Text(paper.faculty)),
                DataCell(
                  Text(
                    "${paper.date.day}/${paper.date.month}/${paper.date.year}",
                  ),
                ),
                DataCell(_statusText(paper.status)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ───────────────── Status Text Helper ─────────────────
  Widget _statusText(PaperStatus status) {
    switch (status) {
      case PaperStatus.approved:
        return const Text("APPROVED", style: TextStyle(color: Colors.green));
      case PaperStatus.pending:
        return const Text("PENDING", style: TextStyle(color: Colors.orange));
      case PaperStatus.rejected:
        return const Text("REJECTED", style: TextStyle(color: Colors.red));
      default:
        return const Text("DRAFT", style: TextStyle(color: Colors.grey));
    }
  }
}

// ───────────────── Stat Card (UNCHANGED UI) ─────────────────
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard(this.title, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ApplicationColors.primaryBlue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: ApplicationColors.ivoryWhite),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ApplicationColors.adminSlate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
