import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme_colors.dart';

class LectureMonitoringPage extends StatefulWidget {
  final List<dynamic> lectures;
  const LectureMonitoringPage({super.key, required this.lectures});

  @override
  State<LectureMonitoringPage> createState() => _LectureMonitoringPageState();
}

class _LectureMonitoringPageState extends State<LectureMonitoringPage> {
  List<dynamic> _lectures = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _lectures = widget.lectures;
  }

  Future<void> _markConducted(String lectureId) async {
    setState(() => _loading = true);
    final api = context.read<AuthProvider>().apiService;
    try {
      final response = await api.post('/faculty/lectures/$lectureId/conduct', {});
      if (response.statusCode == 200) {
        final updated = await api.get('/faculty/lectures/today');
        if (updated.statusCode == 200) {
          setState(() {
            _lectures = jsonDecode(updated.body);
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lecture marked as conducted')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

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
          "Lecture Monitoring",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Lectures",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (_lectures.isEmpty)
                    const Center(child: Text("No lectures scheduled today."))
                  else
                    ..._lectures.map((lec) => _lectureCard(lec)).toList(),
                ],
              ),
            ),
    );
  }

  Widget _lectureCard(Map<String, dynamic> lecture) {
    final conducted = lecture['conducted'] ?? false;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Subject: ${lecture['subject_name'] ?? lecture['subject_id'] ?? 'Unknown'}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text("Time: ${lecture['start_time']} - ${lecture['end_time']}"),
                      Text("Room: ${lecture['room'] ?? 'N/A'}"),
                    ],
                  ),
                ),
                if (!conducted)
                  ElevatedButton(
                    onPressed: () => _markConducted(lecture['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text("Mark Conducted"),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Conducted",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}