import 'enums.dart';

class QuestionPaper {
  final String subject;
  final String faculty;
  PaperStatus status;

  QuestionPaper({
    required this.subject,
    required this.faculty,
    this.status = PaperStatus.draft,
  });
}
