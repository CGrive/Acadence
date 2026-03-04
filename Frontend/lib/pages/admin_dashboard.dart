import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/pages/subject_management.dart';
import 'package:frontend/pages/lecture_schedule.dart';
import '../theme_colors.dart';
import '../providers/auth_provider.dart';

class AdminDashboardTab extends StatefulWidget {
  const AdminDashboardTab({super.key});

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  Map<String, dynamic>? _stats;
  List<dynamic>? _submissions;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final api = context.read<AuthProvider>().apiService;
    try {
      final statsResp = await api.get('/admin/stats');
      final subsResp = await api.get('/admin/recent-submissions?limit=5');
      if (statsResp.statusCode == 200 && subsResp.statusCode == 200) {
        setState(() {
          _stats = jsonDecode(statsResp.body);
          _submissions = jsonDecode(subsResp.body);
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load data';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
  final auth = context.watch<AuthProvider>(); 
  if (_loading) {
    return const Center(child: CircularProgressIndicator());
  }
  if (_error != null) {
    return Center(child: Text('Error: $_error'));
  }

  return Padding(
    padding: const EdgeInsets.all(24),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _topSearchBar(),
          const SizedBox(height: 8),
          Text( 
            "Welcome, ${auth.name ?? 'Admin'}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
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
                      child: Text("Assign Subjects"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LectureSchedulePage(),
                        ),
                      );
                    },
                    child: const Text("Schedule Lectures"),
                  ),
                ],
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
        fillColor: ApplicationColors.primaryPurple,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _statsRow() {
    return Row(
      children: [
        _StatCard(
          "Total Departments",
          _stats?['total_departments']?.toString() ?? '0',
          Icons.apartment,
        ),
        const SizedBox(width: 16),
        _StatCard(
          "Active Subjects",
          _stats?['active_subjects']?.toString() ?? '0',
          Icons.book,
        ),
        const SizedBox(width: 16),
        _StatCard(
          "Daily Lectures",
          _stats?['daily_lectures']?.toString() ?? '0',
          Icons.school,
        ),
        const SizedBox(width: 16),
        _StatCard(
          "Question Papers",
          "${_stats?['approved_papers'] ?? 0} / ${_stats?['total_papers'] ?? 0}",
          Icons.description,
        ),
      ],
    );
  }

  Widget _recentSubmissionsTable() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ApplicationColors.primaryPurple,
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
          rows: _submissions?.map((paper) {
                final date = DateTime.parse(paper['date']);
                return DataRow(
                  cells: [
                    DataCell(Text(paper['subject_name'] ?? 'Unknown')),
                    DataCell(Text(paper['faculty_name'] ?? 'Unknown')),
                    DataCell(
                      Text("${date.day}/${date.month}/${date.year}"),
                    ),
                    DataCell(_statusText(paper['status'])),
                  ],
                );
              }).toList() ??
              [],
        ),
      ),
    );
  }

  Widget _statusText(String? status) {
    switch (status) {
      case 'approved':
        return const Text("APPROVED", style: TextStyle(color: Colors.green));
      case 'pending':
        return const Text("PENDING", style: TextStyle(color: Colors.orange));
      case 'rejected':
        return const Text("REJECTED", style: TextStyle(color: Colors.red));
      default:
        return const Text("DRAFT", style: TextStyle(color: Colors.grey));
    }
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
          color: ApplicationColors.primaryPurple,
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