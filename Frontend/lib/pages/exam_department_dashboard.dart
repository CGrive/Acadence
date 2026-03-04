import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_colors.dart';
import '../providers/auth_provider.dart';

class ExamDepartmentDashboard extends StatefulWidget {
  const ExamDepartmentDashboard({super.key});

  @override
  State<ExamDepartmentDashboard> createState() => _ExamDepartmentDashboardState();
}

class _ExamDepartmentDashboardState extends State<ExamDepartmentDashboard> {
  List<dynamic> _pendingPapers = [];
  List<dynamic> _invigilation = [];
  List<dynamic> _recentNotices = [];
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
      final pendingResp = await api.get('/exam/pending-papers');
      final invigResp = await api.get('/exam/invigilation');
      final noticesResp = await api.get('/exam/notices?limit=2');
      if (pendingResp.statusCode == 200 && invigResp.statusCode == 200) {
        setState(() {
          _pendingPapers = jsonDecode(pendingResp.body);
          _invigilation = jsonDecode(invigResp.body);
          if (noticesResp.statusCode == 200) {
            _recentNotices = jsonDecode(noticesResp.body);
          }
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

  Future<void> _refresh() async {
    await _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        body: Center(child: Text('Error: $_error')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text("Exam Department",
            style: TextStyle(color: Colors.black)),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.black),
          SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome, ${auth.name ?? 'Exam Officer'}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text("Semester Finals · Operational Summary",
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              _kpiRow(),
              const SizedBox(height: 28),
              _recentNoticesCard(),
              const SizedBox(height: 28),
              _invigilationOverview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kpiRow() {
    final pendingCount = _pendingPapers.length;
    final invigilationGaps = _invigilation.where((i) => i['status'] == 'unassigned').length;
    return Row(
      children: [
        _MiniKpiCard("Pending Approvals", pendingCount.toString(), Colors.orange),
        const SizedBox(width: 12),
        _MiniKpiCard("Invigilation Gaps", invigilationGaps.toString(), Colors.red),
        const SizedBox(width: 12),
        _MiniKpiCard("Papers Uploaded", pendingCount.toString(), Colors.green),
        const SizedBox(width: 12),
        _MiniKpiCard("Active Exams", "25", Colors.blue),
      ],
    );
  }

  Widget _recentNoticesCard() {
    if (_recentNotices.isEmpty) return const SizedBox.shrink();
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recent Notices",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ..._recentNotices.map((n) => ListTile(
                leading: const Icon(Icons.notifications_active, color: ApplicationColors.primaryPurple),
                title: Text(n['title'] ?? 'No title'),
                subtitle: Text(n['content'] ?? ''),
              )).toList(),
        ],
      ),
    );
  }

  Widget _invigilationOverview() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Invigilation Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_invigilation.isEmpty)
            const Center(child: Text("No invigilation duties scheduled."))
          else
            ..._invigilation.map((i) => _InvigilationRow(
                  i['exam_name'] ?? i['subject'] ?? 'Exam',
                  i['start_time']?.toString() ?? '00:00',
                  i['room'] ?? 'Room?',
                  i['status'] == 'assigned',
                )).toList(),
        ],
      ),
    );
  }

  Widget _card(Widget child) {
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

class _MiniKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _MiniKpiCard(this.title, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _InvigilationRow extends StatelessWidget {
  final String subject;
  final String time;
  final String room;
  final bool assigned;

  const _InvigilationRow(this.subject, this.time, this.room, this.assigned);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: assigned
                  ? Colors.green.withOpacity(0.15)
                  : Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(assigned ? "Assigned" : "Allocate",
                style: TextStyle(color: assigned ? Colors.green : Colors.orange)),
          ),
        ],
      ),
    );
  }
}