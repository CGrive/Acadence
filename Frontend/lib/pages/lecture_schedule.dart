import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme_colors.dart';
import '../providers/auth_provider.dart';

class LectureSchedulePage extends StatefulWidget {
  const LectureSchedulePage({super.key});

  @override
  State<LectureSchedulePage> createState() => _LectureSchedulePageState();
}

class _LectureSchedulePageState extends State<LectureSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSubjectId;
  String? _selectedFacultyId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 30);
  final _roomController = TextEditingController();

  List<dynamic> _subjects = [];
  List<dynamic> _faculty = [];
  List<dynamic> _lectures = [];
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
      final subjectsResp = await api.get('/admin/subjects');
      final facultyResp = await api.get('/admin/faculty');
      final lecturesResp = await api.get('/admin/lectures');
      if (subjectsResp.statusCode == 200 &&
          facultyResp.statusCode == 200 &&
          lecturesResp.statusCode == 200) {
        setState(() {
          _subjects = jsonDecode(subjectsResp.body);
          _faculty = jsonDecode(facultyResp.body);
          _lectures = jsonDecode(lecturesResp.body);
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

  Future<void> _addLecture() async {
    if (!_formKey.currentState!.validate()) return;

    final api = context.read<AuthProvider>().apiService;
    final body = {
      'subject_id': _selectedSubjectId,
      'faculty_id': _selectedFacultyId,
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'start_time': '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}:00',
      'end_time': '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}:00',
      'room': _roomController.text,
    };

    try {
      final response = await api.postJson('/admin/lectures', body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lecture scheduled successfully')),
        );
        _fetchData();
        _formKey.currentState!.reset();
        setState(() {
          _selectedSubjectId = null;
          _selectedFacultyId = null;
          _selectedDate = DateTime.now();
          _startTime = const TimeOfDay(hour: 9, minute: 0);
          _endTime = const TimeOfDay(hour: 10, minute: 30);
          _roomController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to schedule lecture: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Lecture Schedule",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Schedule New Lecture",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFormCard(),
            const SizedBox(height: 32),
            const Text(
              "Existing Lectures",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildLectureList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Subject", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedSubjectId,
                decoration: _inputDecoration("Select Subject"),
                items: _subjects.map<DropdownMenuItem<String>>((s) {
                  return DropdownMenuItem<String>(
                    value: s['id'],
                    child: Text(s['name']),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedSubjectId = value),
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              const Text("Faculty", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedFacultyId,
                decoration: _inputDecoration("Select Faculty"),
                items: _faculty.map<DropdownMenuItem<String>>((f) {
                  return DropdownMenuItem<String>(
                    value: f['id'],
                    child: Text(f['name']),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedFacultyId = value),
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              const Text("Date", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                      const Icon(Icons.calendar_today, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text("Start Time", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _startTime,
                  );
                  if (time != null) {
                    setState(() => _startTime = time);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_startTime.format(context)),
                      const Icon(Icons.access_time, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text("End Time", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _endTime,
                  );
                  if (time != null) {
                    setState(() => _endTime = time);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_endTime.format(context)),
                      const Icon(Icons.access_time, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text("Room", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _roomController,
                decoration: _inputDecoration("e.g. Room 301"),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ApplicationColors.primaryPurple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _addLecture,
                  child: const Text(
                    "Schedule Lecture",
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLectureList() {
    if (_lectures.isEmpty) {
      return const Center(child: Text("No lectures scheduled yet."));
    }

    final Map<String, String> subjectNames = {
      for (var s in _subjects) s['id']: s['name']
    };
    final Map<String, String> facultyNames = {
      for (var f in _faculty) f['id']: f['name']
    };

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _lectures.length,
      itemBuilder: (context, index) {
        final lecture = _lectures[index];
        final subjectName = subjectNames[lecture['subject_id']] ?? 'Unknown';
        final facultyName = facultyNames[lecture['faculty_id']] ?? 'Unknown';
        final date = lecture['date'];
        final start = lecture['start_time'].substring(0, 5);
        final end = lecture['end_time'].substring(0, 5);
        final room = lecture['room'] ?? 'N/A';
        final conducted = lecture['conducted'] ?? false;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: conducted ? Colors.green : Colors.orange,
              child: Icon(
                conducted ? Icons.check : Icons.schedule,
                color: Colors.white,
              ),
            ),
            title: Text(subjectName),
            subtitle: Text('$facultyName · $date $start-$end · $room'),
            trailing: Text(conducted ? 'Conducted' : 'Upcoming'),
          ),
        );
      },
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