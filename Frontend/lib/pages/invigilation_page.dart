import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme_colors.dart';
import '../providers/auth_provider.dart';

class InvigilationPage extends StatefulWidget {
  const InvigilationPage({super.key});

  @override
  State<InvigilationPage> createState() => _InvigilationPageState();
}

class _InvigilationPageState extends State<InvigilationPage> {
  List<dynamic> _invigilations = [];
  List<dynamic> _faculty = [];
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
      final invigResp = await api.get('/exam/invigilation');
      final facultyResp = await api.get('/exam/faculty');
      if (invigResp.statusCode == 200 && facultyResp.statusCode == 200) {
        setState(() {
          _invigilations = jsonDecode(invigResp.body);
          _faculty = jsonDecode(facultyResp.body);
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

  Future<void> _assignFaculty(String invigilationId, String facultyId) async {
    final api = context.read<AuthProvider>().apiService;
    try {
      final response = await api.post('/exam/invigilation/$invigilationId/assign', {
        'faculty_id': facultyId,
      });
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assigned successfully')),
        );
        _fetchData();
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
  }

  Future<void> _createInvigilation(Map<String, dynamic> data) async {
    final api = context.read<AuthProvider>().apiService;
    try {
      final response = await api.postJson('/exam/invigilation', data);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invigilation created')),
        );
        _fetchData();
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
  }

  void _showCreateDialog() {
    final formKey = GlobalKey<FormState>();
    final examNameController = TextEditingController();
    final subjectController = TextEditingController();
    final roomController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 12, minute: 0);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Invigilation'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: examNameController,
                  decoration: const InputDecoration(labelText: 'Exam Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: subjectController,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: roomController,
                  decoration: const InputDecoration(labelText: 'Room'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                // Date picker
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) selectedDate = date;
                  },
                ),
                // Start time picker
                ListTile(
                  title: const Text('Start Time'),
                  subtitle: Text(startTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: startTime,
                    );
                    if (time != null) startTime = time;
                  },
                ),
                // End time picker
                ListTile(
                  title: const Text('End Time'),
                  subtitle: Text(endTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: endTime,
                    );
                    if (time != null) endTime = time;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final data = {
                  'exam_name': examNameController.text,
                  'subject': subjectController.text,
                  'room': roomController.text,
                  'date': DateFormat('yyyy-MM-dd').format(selectedDate),
                  'start_time': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                  'end_time': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                };
                _createInvigilation(data);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAssignDialog(Map<String, dynamic> invigilation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Faculty'),
        content: DropdownButtonFormField<String>(
          items: _faculty.map<DropdownMenuItem<String>>((f) {
            return DropdownMenuItem<String>(
              value: f['id'],
              child: Text(f['name']),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              _assignFaculty(invigilation['id'], value);
              Navigator.pop(context);
            }
          },
          decoration: const InputDecoration(labelText: 'Select Faculty'),
        ),
      ),
    );
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
        body: Center(child: Text('Error: $_error')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text("Invigilation", style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Invigilation Allocation",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text("Assign faculty members for upcoming exams.",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            if (_invigilations.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "No invigilation duties scheduled.\nTap + to add one.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ..._invigilations.map((i) => _InvigilationCard(
                    invigilation: i,
                    onAssign: () => _showAssignDialog(i),
                  )).toList(),
          ],
        ),
      ),
    );
  }
}

class _InvigilationCard extends StatelessWidget {
  final Map<String, dynamic> invigilation;
  final VoidCallback onAssign;

  const _InvigilationCard({required this.invigilation, required this.onAssign});

  @override
  Widget build(BuildContext context) {
    final assigned = invigilation['status'] == 'assigned';
    final facultyName = invigilation['faculty_name'] ?? 'Unassigned';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invigilation['exam_name'] ?? 'Exam',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("${invigilation['subject']} · ${invigilation['room']}",
                    style: const TextStyle(color: Colors.grey)),
                Text("${invigilation['date']} ${invigilation['start_time']} - ${invigilation['end_time']}",
                    style: const TextStyle(color: Colors.grey)),
                if (assigned)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text("Assigned to: $facultyName",
                        style: const TextStyle(color: Colors.green)),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: assigned
                  ? Colors.green.withOpacity(0.15)
                  : ApplicationColors.primaryPurple,
              foregroundColor: assigned ? Colors.green : Colors.white,
            ),
            onPressed: assigned ? null : onAssign,
            child: Text(assigned ? "Assigned" : "Allocate"),
          ),
        ],
      ),
    );
  }
}