import 'enums.dart';

class Invigilation {
  final String subject;
  final String room;
  final String time;
  String? faculty;
  InvigilationStatus status;

  Invigilation({
    required this.subject,
    required this.room,
    required this.time,
    this.faculty,
    this.status = InvigilationStatus.unassigned,
  });
}
