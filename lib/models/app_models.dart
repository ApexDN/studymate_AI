import 'package:cloud_firestore/cloud_firestore.dart';


class UserProfile {
  final String uid;
  final String name;
  final String email;

  UserProfile({required this.uid, required this.name, required this.email});

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        uid: map['uid'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
      );

  Map<String, dynamic> toMap() => {'uid': uid, 'name': name, 'email': email};
}


class Module {
  final String id;
  final String name;
  final String userId;

  Module({required this.id, required this.name, required this.userId});

  factory Module.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Module(
      id: doc.id,
      name: data['name'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'userId': userId};
}


class Exam {
  final String id;
  final String moduleId;
  final String moduleName;
  final DateTime examDate;
  final String userId;

  Exam({
    required this.id,
    required this.moduleId,
    required this.moduleName,
    required this.examDate,
    required this.userId,
  });

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final exam = DateTime(examDate.year, examDate.month, examDate.day);
    return exam.difference(today).inDays;
  }

  factory Exam.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Exam(
      id: doc.id,
      moduleId: data['moduleId'] ?? '',
      moduleName: data['moduleName'] ?? '',
      examDate: (data['examDate'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'moduleId': moduleId,
        'moduleName': moduleName,
        'examDate': Timestamp.fromDate(examDate),
        'userId': userId,
      };
}


class StudyTask {
  final String id;
  final String title;
  final bool completed;
  final String userId;
  final DateTime date;
  final String? examId;

  StudyTask({
    required this.id,
    required this.title,
    required this.completed,
    required this.userId,
    required this.date,
    this.examId,
  });

  factory StudyTask.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudyTask(
      id: doc.id,
      title: data['title'] ?? '',
      completed: data['completed'] ?? false,
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      examId: data['examId'],
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'completed': completed,
        'userId': userId,
        'date': Timestamp.fromDate(date),
        'examId': examId,
      };
}


class PomodoroSession {
  final String id;
  final String userId;
  final DateTime date;

  PomodoroSession({required this.id, required this.userId, required this.date});

  factory PomodoroSession.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PomodoroSession(
      id: doc.id,
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'date': Timestamp.fromDate(date),
      };
}
