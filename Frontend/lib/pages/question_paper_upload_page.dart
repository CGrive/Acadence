import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../theme_colors.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class QuestionPaperUploadPage extends StatefulWidget {
  const QuestionPaperUploadPage({super.key});

  @override
  State<QuestionPaperUploadPage> createState() =>
      _QuestionPaperUploadPageState();
}

class _QuestionPaperUploadPageState extends State<QuestionPaperUploadPage> {
  String? _selectedSubjectId;
  String? _selectedSubjectName;
  String? _selectedExamType;
  PlatformFile? _selectedFile;
  List<dynamic> _subjects = [];
  List<dynamic> _myPapers = [];
  bool _loadingSubjects = true;
  bool _loadingPapers = true;
  String? _error;

  final List<String> _examTypes = ["Midterm", "End Semester"];

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
    _fetchMyPapers();
  }

  Future<void> _fetchSubjects() async {
    final api = context.read<AuthProvider>().apiService;
    try {
      final response = await api.get('/faculty/subjects');
      if (response.statusCode == 200) {
        setState(() {
          _subjects = jsonDecode(response.body);
          _loadingSubjects = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load subjects';
          _loadingSubjects = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loadingSubjects = false;
      });
    }
  }

  Future<void> _fetchMyPapers() async {
    final api = context.read<AuthProvider>().apiService;
    try {
      final response = await api.get('/faculty/question-papers');
      if (response.statusCode == 200) {
        setState(() {
          _myPapers = jsonDecode(response.body);
          _loadingPapers = false;
        });
      } else {
        setState(() {
          _loadingPapers = false;
        });
      }
    } catch (e) {
      setState(() {
        _loadingPapers = false;
      });
    }
  }

  Future<void> _pickFile() async {
    if (kIsWeb) {
      final uploadInput = html.FileUploadInputElement();
      uploadInput.accept = '.pdf,.doc,.docx';
      uploadInput.click();
      uploadInput.onChange.listen((e) {
        final files = uploadInput.files;
        if (files != null && files.isNotEmpty) {
          final file = files[0];
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);
          reader.onLoadEnd.listen((e) {
            setState(() {
              _selectedFile = PlatformFile(
                name: file.name,
                size: file.size,
                bytes: reader.result as Uint8List?,
              );
            });
          });
        }
      });
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() => _selectedFile = result.files.first);
      }
    }
  }

  Future<void> _submitPaper() async {
    if (_selectedSubjectId == null ||
        _selectedExamType == null ||
        _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    final api = context.read<AuthProvider>().apiService;
    final uri = Uri.parse('${ApiService.baseUrl}/faculty/question-papers');
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll(api.headers);
    request.fields['subject_id'] = _selectedSubjectId!;
    request.fields['exam_type'] = _selectedExamType!;

    if (kIsWeb) {
      if (_selectedFile!.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          _selectedFile!.bytes!,
          filename: _selectedFile!.name,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("File data missing")),
        );
        return;
      }
    } else {
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        _selectedFile!.path!,
      ));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Paper uploaded successfully")),
        );
        _fetchMyPapers();
        setState(() {
          _selectedSubjectId = null;
          _selectedSubjectName = null;
          _selectedExamType = null;
          _selectedFile = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Question Paper Upload",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _deadlineBanner(),
            const SizedBox(height: 24),
            _uploadForm(),
            const SizedBox(height: 32),
            _submissionHistory(),
          ],
        ),
      ),
    );
  }

  Widget _uploadForm() {
    if (_loadingSubjects) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error loading subjects: $_error'));
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Submit New Paper",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedSubjectId,
            decoration: _inputDecoration("Select Subject"),
            items: _subjects.map<DropdownMenuItem<String>>((subject) {
              return DropdownMenuItem<String>(
                value: subject['id'].toString(),
                child: Text(subject['name'] ?? 'Unknown'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSubjectId = value;
                _selectedSubjectName = _subjects.firstWhere(
                  (s) => s['id'].toString() == value,
                )['name'];
              });
            },
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: _selectedExamType,
            decoration: _inputDecoration("Select Exam Type"),
            items: _examTypes
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) => setState(() => _selectedExamType = value),
          ),

          const SizedBox(height: 16),
          _fileUploadBox(),

          const SizedBox(height: 20),
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
              onPressed: _submitPaper,
              child: const Text("Upload for Approval"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fileUploadBox() {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: _pickFile,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _selectedFile == null
                ? Colors.grey.shade300
                : ApplicationColors.primaryPurple,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _selectedFile == null
                    ? Icons.cloud_upload_outlined
                    : Icons.insert_drive_file,
                size: 40,
                color: _selectedFile == null
                    ? Colors.grey
                    : ApplicationColors.primaryPurple,
              ),
              const SizedBox(height: 8),
              Text(
                _selectedFile == null
                    ? "Tap to browse or drop file"
                    : _selectedFile!.name,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _submissionHistory() {
    if (_loadingPapers) {
      return const Center(child: CircularProgressIndicator());
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Submission History",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_myPapers.isEmpty)
            const Text(
              "No submissions yet",
              style: TextStyle(color: Colors.grey),
            ),
          for (final paper in _myPapers)
            _HistoryRow(
              subject: paper['subject_name'] ?? paper['subject_id'] ?? 'Unknown',
              status: paper['status'].toString().toUpperCase(),
              color: _statusColor(paper['status']),
            ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _deadlineBanner() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.red),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Deadline Remaining: 02 Days 14 Hours",
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF4F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );

  Widget _card({required Widget child}) => Container(
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

class _HistoryRow extends StatelessWidget {
  final String subject;
  final String status;
  final Color color;

  const _HistoryRow({
    required this.subject,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(subject)),
          Chip(
            label: Text(status),
            backgroundColor: color.withOpacity(0.15),
            labelStyle: TextStyle(color: color),
          ),
        ],
      ),
    );
  }
}