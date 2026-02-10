import 'package:flutter/material.dart';
import '../models/enums.dart';

class Paper {
  final String id;
  final String subject;
  final String faculty;
  final DateTime date;
  PaperStatus status;

  Paper({
    required this.id,
    required this.subject,
    required this.faculty,
    required this.date,
    required this.status,
  });
}

class AppState extends ChangeNotifier {
  final List<Paper> _papers = [];

  List<Paper> get papers => _papers;

  List<Paper> get pendingPapers =>
      _papers.where((p) => p.status == PaperStatus.pending).toList();

  List<Paper> papersByFaculty(String faculty) =>
      _papers.where((p) => p.faculty == faculty).toList();

  void submitPaper(Paper paper) {
    _papers.insert(0, paper);
    notifyListeners();
  }

  void approvePaper(Paper paper) {
    paper.status = PaperStatus.approved;
    notifyListeners();
  }

  void rejectPaper(Paper paper) {
    paper.status = PaperStatus.rejected;
    notifyListeners();
  }
}
