import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_colors.dart';
import '../providers/auth_provider.dart';
import 'lecture_monitoring.dart';
import 'question_paper_upload_page.dart';

class FacultyDashboardTab extends StatefulWidget {
  const FacultyDashboardTab({super.key});

  @override
  State<FacultyDashboardTab> createState() => _FacultyDashboardTabState();
}

class _FacultyDashboardTabState extends State<FacultyDashboardTab> {
  int _currentIndex = 0;
  List<dynamic> _lectures = [];
  List<dynamic> _papers = [];
  List<dynamic> _gradingItems = [];
  List<dynamic> _invigilations = [];
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
      final lecturesResp = await api.get('/faculty/lectures/today');
      final papersResp = await api.get('/faculty/question-papers');
      final gradingResp = await api.get('/faculty/grading-queue');
      final invigResp = await api.get('/faculty/invigilation');
      if (lecturesResp.statusCode == 200 && papersResp.statusCode == 200) {
        setState(() {
          _lectures = jsonDecode(lecturesResp.body);
          _papers = jsonDecode(papersResp.body);
          if (gradingResp.statusCode == 200) {
            _gradingItems = jsonDecode(gradingResp.body);
          }
          if (invigResp.statusCode == 200) {
            _invigilations = jsonDecode(invigResp.body);
          }
          _loading = false;
          _error = null;
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

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refresh,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Dashboard (index 0)
          _buildDashboard(),
          // Lectures (index 1)
          LectureMonitoringPage(lectures: _lectures),
          // Grading (index 2)
          _buildGradingPage(),
          // Exams (index 3)
          _buildExamsPage(),
          // Setup (index 4)
          _buildSetupPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: ApplicationColors.primaryPurple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), label: "Lectures"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_turned_in), label: "Grading"),
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: "Exams"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Setup"),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final auth = context.watch<AuthProvider>();
    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Faculty Dashboard",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "Welcome back, ${auth.name ?? 'Faculty'}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _todayStatsCard(),
            const SizedBox(height: 28),
            _gradingQueuePreview(),
            const SizedBox(height: 24),
            _questionPaperSubmission(),
            const SizedBox(height: 24),
            _invigilationCard(),
            const SizedBox(height: 24),
            _quickStudentNotice(),
          ],
        ),
      ),
    );
  }

  Widget _invigilationCard() {
    if (_invigilations.isEmpty) return const SizedBox.shrink();
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Invigilation Duties",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._invigilations.map((inv) => ListTile(
                leading: const Icon(Icons.event_seat, color: ApplicationColors.primaryPurple),
                title: Text(inv['exam_name'] ?? 'Exam'),
                subtitle: Text(
                  "${inv['date']} ${inv['start_time']} - ${inv['end_time']} · ${inv['room']}",
                ),
              )).toList(),
        ],
      ),
    );
  }

  Widget _todayStatsCard() {
    final lectureCount = _lectures.length;
    String nextLecture = 'No lectures';
    if (_lectures.isNotEmpty) {
      final first = _lectures.first;
      final time = first['start_time']?.toString() ?? '';
      if (time.isNotEmpty) {
        nextLecture = time.length >= 5 ? time.substring(0, 5) : time;
      }
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: ApplicationColors.primaryPurple.withOpacity(0.2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ApplicationColors.primaryPurple.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.schedule,
                    color: ApplicationColors.primaryPurple,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Lectures Today",
                  style: TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 6),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: ApplicationColors.primaryPurple,
                    foregroundColor: Colors.white,
                    side: BorderSide(color: ApplicationColors.primaryPurple),
                  ),
                  onPressed: () {
                    _onItemTapped(1);
                  },
                  child: Text(
                    "$lectureCount Session${lectureCount != 1 ? 's' : ''}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Next: $nextLecture",
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  Icons.calendar_today,
                  color: ApplicationColors.primaryPurple,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Semester Progress",
                  style: TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 6),
                const Text(
                  "N/A",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "No data",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradingQueuePreview() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Grading Queue",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => _onItemTapped(2),
                child: const Text("View All"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_gradingItems.isEmpty)
            const Center(
              child: Text(
                "No pending grading tasks.\n(This feature is coming soon.)",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ..._gradingItems.take(2).map((item) => ListTile(
                  leading: const Icon(Icons.assignment, color: ApplicationColors.primaryPurple),
                  title: Text(item['subject']),
                  subtitle: Text("${item['assignment']} · ${item['submissions']} submissions"),
                  trailing: Text(
                    "Due ${item['deadline']}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _questionPaperSubmission() {
    final pendingCount = _papers.where((p) => p['status'] == 'pending').length;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Question Paper Submission",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: pendingCount > 0
                      ? Colors.orange.withOpacity(0.12)
                      : Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  pendingCount > 0 ? "$pendingCount Pending" : "No Pending",
                  style: TextStyle(
                    color: pendingCount > 0 ? Colors.orange : Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_papers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  "No papers submitted yet.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ..._papers.take(2).map((paper) => ListTile(
                  leading: const Icon(Icons.description, color: ApplicationColors.primaryPurple),
                  title: Text(paper['subject_name'] ?? 'Unknown Subject'),
                  subtitle: Text(
                    "${paper['exam_type']} · Status: ${paper['status']}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Chip(
                    label: Text(
                      paper['status'],
                      style: TextStyle(
                        color: paper['status'] == 'approved'
                            ? Colors.green
                            : paper['status'] == 'rejected'
                                ? Colors.red
                                : Colors.orange,
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                )),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.cloud_upload_outlined),
              style: ElevatedButton.styleFrom(
                backgroundColor: ApplicationColors.primaryPurple,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QuestionPaperUploadPage(),
                  ),
                );
              },
              label: const Text(
                "Upload New Question Paper",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              "Deadline managed by Exam Department",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickStudentNotice() {
    final TextEditingController _noticeController = TextEditingController();
    String? _selectedTarget = 'students';

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Notice",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedTarget,
            decoration: _inputDecoration("Select Audience"),
            items: const [
              DropdownMenuItem(value: 'students', child: Text('Students')),
              DropdownMenuItem(value: 'faculty', child: Text('Faculty')),
              DropdownMenuItem(value: 'all', child: Text('All')),
            ],
            onChanged: (value) => setState(() => _selectedTarget = value),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noticeController,
            maxLines: 3,
            decoration: _inputDecoration("Type your message here..."),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Will be sent to ${_selectedTarget == 'all' ? 'everyone' : _selectedTarget}",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ApplicationColors.primaryPurple,
                ),
                onPressed: () async {
                  if (_noticeController.text.trim().isEmpty) return;
                  final api = context.read<AuthProvider>().apiService;
                  final notice = {
                    'title': 'Faculty Notice',
                    'content': _noticeController.text,
                    'target': _selectedTarget,
                  };
                  try {
                    final response = await api.postJson('/faculty/notices', notice);
                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notice sent!')),
                      );
                      _noticeController.clear();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed: ${response.body}')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: const Text("Send"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Placeholder pages for other tabs
  Widget _buildGradingPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Grading Queue",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_gradingItems.isEmpty)
            const Center(child: Text("No grading tasks available."))
          else
            ..._gradingItems.map((item) => Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: const Icon(Icons.assignment, color: ApplicationColors.primaryPurple),
                    title: Text(item['subject']),
                    subtitle: Text("${item['assignment']} · ${item['submissions']} submissions"),
                    trailing: Text("Due ${item['deadline']}"),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildExamsPage() {
    return const Center(
      child: Text("Exams page – coming soon"),
    );
  }

  Widget _buildSetupPage() {
    return const Center(
      child: Text("Setup page – coming soon"),
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
}