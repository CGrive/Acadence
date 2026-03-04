import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme_colors.dart';
import '../providers/auth_provider.dart';

class SubjectManagementPage extends StatefulWidget {
  const SubjectManagementPage({super.key});

  @override
  State<SubjectManagementPage> createState() => _SubjectManagementPageState();
}

class _SubjectManagementPageState extends State<SubjectManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  String? _selectedDepartment;
  String? _selectedFacultyId;
  int _semester = 1;

  List<dynamic> _subjects = [];
  List<dynamic> _faculty = [];
  Map<String, String> _facultyMap = {};
  bool _loading = true;
  String? _error;

  final List<String> _departments = [
    'Computer Science',
    'Information Technology',
    'Electronics',
    'Mechanical',
    'Civil',
    'Administration',
  ];

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
      if (subjectsResp.statusCode == 200 && facultyResp.statusCode == 200) {
        final subjects = jsonDecode(subjectsResp.body);
        final faculty = jsonDecode(facultyResp.body);
        
        final Map<String, String> facultyMap = {};
        for (var f in faculty) {
          final id = f['id'] as String?;
          final name = f['name'] as String?;
          if (id != null && name != null) {
            facultyMap[id] = name;
          }
        }
        
        setState(() {
          _subjects = subjects;
          _faculty = faculty;
          _facultyMap = facultyMap;
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

  Future<void> _addSubject() async {
    if (!_formKey.currentState!.validate()) return;

    final api = context.read<AuthProvider>().apiService;
    final body = {
      'name': _nameController.text,
      'code': _codeController.text,
      'department': _selectedDepartment ?? '',
      'semester': _semester,
      'faculty_id': _selectedFacultyId,
    };

    try {
      final response = await api.postJson('/admin/subjects', body);
      if (response.statusCode == 200) {
        _fetchData();
        _nameController.clear();
        _codeController.clear();
        setState(() {
          _selectedDepartment = null;
          _selectedFacultyId = null;
          _semester = 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subject added successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add subject: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _editSubject(Map<String, dynamic> subject) async {
    final nameController = TextEditingController(text: subject['name']);
    final codeController = TextEditingController(text: subject['code']);
    String selectedDept = subject['department'] ?? _departments.first;
    int selectedSemester = subject['semester'] ?? 1;
    String? selectedFacultyId = subject['faculty_id'];

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Subject'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Subject Name'),
              ),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Subject Code'),
              ),
              DropdownButtonFormField<String>(
                value: selectedDept,
                decoration: const InputDecoration(labelText: 'Department'),
                items: _departments.map((dept) {
                  return DropdownMenuItem(value: dept, child: Text(dept));
                }).toList(),
                onChanged: (value) => selectedDept = value!,
              ),
              DropdownButtonFormField<int>(
                value: selectedSemester,
                decoration: const InputDecoration(labelText: 'Semester'),
                items: List.generate(8, (i) => i + 1).map((sem) {
                  return DropdownMenuItem(value: sem, child: Text('Semester $sem'));
                }).toList(),
                onChanged: (value) => selectedSemester = value!,
              ),
              DropdownButtonFormField<String>(
                value: selectedFacultyId,
                decoration: const InputDecoration(labelText: 'Faculty'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('None')),
                  ..._faculty.map((f) => DropdownMenuItem(
                        value: f['id'],
                        child: Text(f['name']),
                      )),
                ],
                onChanged: (value) => selectedFacultyId = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final api = context.read<AuthProvider>().apiService;
              final body = {
                'name': nameController.text,
                'code': codeController.text,
                'department': selectedDept,
                'semester': selectedSemester,
                'faculty_id': selectedFacultyId,
              };
              try {
                final response = await api.put('/admin/subjects/${subject['id']}', body);
                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Subject updated')),
                  );
                  _fetchData();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Update failed: ${response.body}')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
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

  Widget _addNewSubjectCard() {
    return _card(
      child: Form(
        key: _formKey,
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
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration("e.g. Distributed Systems"),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            _label("SUBJECT CODE"),
            TextFormField(
              controller: _codeController,
              decoration: _inputDecoration("e.g. CS401"),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            _label("DEPARTMENT"),
            DropdownButtonFormField<String>(
              value: _selectedDepartment,
              decoration: _inputDecoration("Select Department"),
              items: _departments.map((dept) {
                return DropdownMenuItem(value: dept, child: Text(dept));
              }).toList(),
              onChanged: (value) => setState(() => _selectedDepartment = value),
              validator: (value) => value == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            _label("SEMESTER"),
            DropdownButtonFormField<int>(
              value: _semester,
              decoration: _inputDecoration("Select Semester"),
              items: List.generate(8, (i) => i + 1).map((sem) {
                return DropdownMenuItem(value: sem, child: Text('Semester $sem'));
              }).toList(),
              onChanged: (value) => setState(() => _semester = value!),
            ),
            const SizedBox(height: 16),

            _label("PRIMARY FACULTY / TEACHER (optional)"),
            DropdownButtonFormField<String>(
              value: _selectedFacultyId,
              decoration: _inputDecoration("Select Faculty"),
              items: [
                const DropdownMenuItem(value: null, child: Text('None')),
                ..._faculty.map((f) => DropdownMenuItem(
                      value: f['id'],
                      child: Text(f['name']),
                    )),
              ],
              onChanged: (value) => setState(() => _selectedFacultyId = value),
            ),
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
                onPressed: _addSubject,
                icon: const Icon(Icons.assignment_ind_outlined),
                label: const Text(
                  "Add & Assign",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          ..._subjects.map((subject) => _subjectRow(subject)).toList(),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {
                // TODO: export CSV
              },
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

  Widget _subjectRow(Map<String, dynamic> subject) {
    final facultyId = subject['faculty_id'];
    final facultyName = facultyId != null
        ? _facultyMap[facultyId] ?? 'Unknown'
        : 'Unassigned';
    final code = subject['code'] ?? '';
    final department = subject['department'] ?? '';
    final semester = subject['semester'] ?? '';

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
                  subject['name'] ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  "$code · $department · Sem $semester",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(facultyName),
                Text(
                  facultyId != null ? "Assigned" : "Unassigned",
                  style: TextStyle(
                    color: facultyId != null ? Colors.green : Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.grey),
              onPressed: () => _editSubject(subject),
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