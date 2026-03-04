import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme_colors.dart';
import '../providers/auth_provider.dart';

class ExamNoticesPage extends StatefulWidget {
  const ExamNoticesPage({super.key});

  @override
  State<ExamNoticesPage> createState() => _ExamNoticesPageState();
}

class _ExamNoticesPageState extends State<ExamNoticesPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedTarget = 'faculty';

  List<dynamic> _notices = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNotices();
  }

  Future<void> _fetchNotices() async {
    final api = context.read<AuthProvider>().apiService;
    try {
      final response = await api.get('/exam/notices');
      if (response.statusCode == 200) {
        setState(() {
          _notices = jsonDecode(response.body);
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load notices';
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

  Future<void> _sendNotice() async {
    if (!_formKey.currentState!.validate()) return;
    final api = context.read<AuthProvider>().apiService;
    final notice = {
      'title': _titleController.text,
      'content': _contentController.text,
      'target': _selectedTarget,
    };
    try {
      final response = await api.postJson('/exam/notices', notice);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notice sent')),
        );
        _titleController.clear();
        _contentController.clear();
        _fetchNotices(); // refresh list
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
        title: const Text("Exam Notices", style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Send Exam Notice",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildNoticeForm(),
            const SizedBox(height: 32),
            const Text("Notice History",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._notices.map((n) => ListTile(
                  title: Text(n['title']),
                  subtitle: Text(
                    "${n['content']} · Sent to ${n['target']}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  leading: const Icon(Icons.notifications_active),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildNoticeForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedTarget,
              decoration: _input("Target Audience"),
              items: const [
                DropdownMenuItem(value: 'faculty', child: Text('Faculty')),
                DropdownMenuItem(value: 'students', child: Text('Students')),
                DropdownMenuItem(value: 'all', child: Text('All')),
              ],
              onChanged: (value) => _selectedTarget = value,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: _input("Notice title"),
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contentController,
              maxLines: 3,
              decoration: _input("Type notice message"),
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ApplicationColors.primaryPurple,
                ),
                onPressed: _sendNotice,
                child: const Text("Send Notice"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _input(String hint) {
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