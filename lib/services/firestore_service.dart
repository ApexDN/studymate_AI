import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Study Tasks ───────────────────────────────────────────────────────────────
  Stream<List<StudyTask>> getTodayTasks(String userId) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return _db
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((s) => s.docs.map((d) => StudyTask.fromDoc(d)).toList());
  }

  Stream<List<StudyTask>> getExamTasks(String examId) {
    return _db
        .collection('tasks')
        .where('examId', isEqualTo: examId)
        .snapshots()
        .map((s) => s.docs.map((d) => StudyTask.fromDoc(d)).toList());
  }

  Future<void> addTask(StudyTask task) =>
      _db.collection('tasks').add(task.toMap());

  Future<void> toggleTask(String id, bool completed) =>
      _db.collection('tasks').doc(id).update({'completed': completed});

  Future<void> deleteTask(String id) =>
      _db.collection('tasks').doc(id).delete();

  // ── Pomodoro Sessions ─────────────────────────────────────────────────────────
  Future<void> addPomodoroSession(String userId) =>
      _db.collection('pomodoro_sessions').add(
        PomodoroSession(id: '', userId: userId, date: DateTime.now()).toMap(),
      );

  Stream<int> getSessionCount(String userId) {
    return _db
        .collection('pomodoro_sessions')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((s) => s.docs.length);
  }

  // Store AI study plan tasks for an exam
  Future<void> saveStudyPlan(String examId, String userId, List<Map<String, String>> tasks) async {
    final batch = _db.batch();
    for (final task in tasks) {
      final ref = _db.collection('tasks').doc();
      batch.set(ref, StudyTask(
        id: '',
        title: task['title'] ?? '',
        completed: false,
        userId: userId,
        date: DateTime.now(),
        examId: examId,
      ).toMap());
    }
    await batch.commit();
  }
}
