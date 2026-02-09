import 'package:flutter/material.dart';
import 'package:frontend/pages/subject_management.dart';
import '../../theme_colors.dart';

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
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
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

  Widget _statsRow() {
    return Row(
      children: const [
        _StatCard("Total Departments", "12", Icons.apartment),
        SizedBox(width: 16),
        _StatCard("Active Subjects", "450", Icons.book),
        SizedBox(width: 16),
        _StatCard("Daily Lectures", "85", Icons.school),
        SizedBox(width: 16),
        _StatCard("Question Papers", "32 / 40", Icons.description),
      ],
    );
  }

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
          rows: const [
            DataRow(
              cells: [
                DataCell(Text("CS101 - Introduction to CS")),
                DataCell(Text("Dr. Aris Thorne")),
                DataCell(Text("Oct 24, 2024")),
                DataCell(
                  Text("APPROVED", style: TextStyle(color: Colors.green)),
                ),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text("MATH202 - Calculus II")),
                DataCell(Text("Prof. Sarah Jenkins")),
                DataCell(Text("Oct 23, 2024")),
                DataCell(
                  Text("PENDING", style: TextStyle(color: Colors.orange)),
                ),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text("LIT110 - World Classics")),
                DataCell(Text("Prof. Elina Gilbert")),
                DataCell(Text("Oct 21, 2024")),
                DataCell(Text("REJECTED", style: TextStyle(color: Colors.red))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
