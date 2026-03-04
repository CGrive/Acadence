import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html; // Only used on web; safe for this project
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../providers/auth_provider.dart';

class PaperApprovalPage extends StatefulWidget {
  const PaperApprovalPage({super.key});

  @override
  State<PaperApprovalPage> createState() => _PaperApprovalPageState();
}

class _PaperApprovalPageState extends State<PaperApprovalPage> {
  List<dynamic> _pendingPapers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPapers();
  }

  Future<void> _fetchPapers() async {
    final api = context.read<AuthProvider>().apiService;
    try {
      final response = await api.get('/exam/pending-papers');
      if (response.statusCode == 200) {
        setState(() {
          _pendingPapers = jsonDecode(response.body);
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load papers';
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

  Future<void> _handleAction(String paperId, String action) async {
    final api = context.read<AuthProvider>().apiService;
    final response = await api.post('/exam/papers/$paperId/$action', {});
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Paper $action${action.endsWith('e') ? 'd' : 'ed'}')),
      );
      _fetchPapers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${response.body}')),
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
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Paper Approval", style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pending Reviews",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_pendingPapers.isEmpty)
              const Center(child: Text("No pending papers 🎉")),
            ..._pendingPapers.map((paper) => _PaperCard(
                  paper: paper,
                  onApprove: () => _handleAction(paper['id'], 'approve'),
                  onReject: () => _handleAction(paper['id'], 'reject'),
                )),
          ],
        ),
      ),
    );
  }
}

class _PaperCard extends StatelessWidget {
  final Map<String, dynamic> paper;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PaperCard({
    required this.paper,
    required this.onApprove,
    required this.onReject,
  });

  Future<void> _downloadBytes(BuildContext context, Uint8List bytes, String filename) async {
    if (kIsWeb) {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..target = 'blank'
        ..download = filename;
      anchor.click();
      html.Url.revokeObjectUrl(url);
    } else {
      // For mobile/desktop, you can add a plugin later
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download not implemented on this platform')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String dateDisplay = "No date";
    if (paper['date'] != null) {
      try {
        final date = DateTime.parse(paper['date']);
        dateDisplay = "${date.day}/${date.month}";
      } catch (_) {
        dateDisplay = "Invalid date";
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paper['subject_name'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    paper['faculty_name'] ?? 'Unknown',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(dateDisplay),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.download),
            label: const Text("Download Paper"),
            onPressed: () async {
              final paperId = paper['id'];
              if (paperId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No file available')),
                );
                return;
              }
              final api = context.read<AuthProvider>().apiService;
              final url = Uri.parse('${ApiService.baseUrl}/exam/download-paper/$paperId');
              try {
                final request = http.Request('GET', url);
                request.headers.addAll(api.headers);
                final streamedResponse = await request.send();
                final response = await http.Response.fromStream(streamedResponse);
                if (response.statusCode == 200) {
                  final bytes = response.bodyBytes;
                  String filename = 'paper.pdf';
                  final contentDisposition = response.headers['content-disposition'];
                  if (contentDisposition != null) {
                    final match = RegExp(r'filename="?([^"]+)"?').firstMatch(contentDisposition);
                    if (match != null) filename = match.group(1)!;
                  }
                  await _downloadBytes(context, bytes, filename);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Download failed: ${response.body}')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.15),
                    foregroundColor: Colors.green,
                  ),
                  onPressed: onApprove,
                  child: const Text("Approve"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.15),
                    foregroundColor: Colors.red,
                  ),
                  onPressed: onReject,
                  child: const Text("Reject"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}