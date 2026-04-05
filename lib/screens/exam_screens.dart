import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../services/ai_service.dart';
import '../models/app_models.dart';
import '../widgets/app_theme.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});
  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  final _svc = FirestoreService();
  late final String _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
  }

  void _showAddExam() {
    final nameCtrl = TextEditingController();
    DateTime? picked;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add New Exam', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy)),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Subject / Module Name',
                prefixIcon: const Icon(Icons.book_outlined, color: AppColors.g500),
                filled: true, fillColor: AppColors.g100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () async {
                final d = await showDatePicker(
                  context: ctx,
                  initialDate: DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (d != null) setSt(() => picked = d);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.g100, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.g300)),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.g500),
                    const SizedBox(width: 10),
                    Text(picked == null ? 'Select Exam Date' : DateFormat('dd MMMM yyyy').format(picked!),
                        style: TextStyle(color: picked == null ? AppColors.g500 : AppColors.g900)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty || picked == null) return;
                  Navigator.pop(ctx);
                  final ref = await _svc.addExam(Exam(
                    id: '', moduleId: '', moduleName: nameCtrl.text.trim(),
                    examDate: picked!, userId: _uid,
                  ));
                  // Generate AI study plan
                  final days = picked!.difference(DateTime.now()).inDays;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Generating AI study plan...'), backgroundColor: AppColors.blue),
                  );
                  final tasks = await AIService.generateStudyPlan(nameCtrl.text.trim(), days);
                  await _svc.saveStudyPlan(ref.id, _uid, tasks);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Study plan generated!'), backgroundColor: AppColors.green),
                    );
                  }
                },
                child: const Text('Add Exam + Generate Study Plan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final msg = motivationalMessages[Random().nextInt(motivationalMessages.length)];
    return Scaffold(
      backgroundColor: AppColors.g100,
      appBar: AppBar(title: const Text('My Exams')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExam,
        backgroundColor: AppColors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.blueLt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.format_quote, color: AppColors.blue),
                const SizedBox(width: 8),
                Expanded(child: Text(msg, style: const TextStyle(color: AppColors.navy, fontSize: 13))),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Exam>>(
              stream: _svc.getExams(_uid),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final exams = snap.data ?? [];
                if (exams.isEmpty) return const Center(child: Text('No exams yet.\nTap + to add your first exam!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.g500)));
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: exams.length,
                  itemBuilder: (ctx, i) => _ExamCard(exam: exams[i], svc: _svc, uid: _uid),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final Exam exam;
  final FirestoreService svc;
  final String uid;
  const _ExamCard({required this.exam, required this.svc, required this.uid});

  @override
  Widget build(BuildContext context) {
    final isUrgent = exam.daysRemaining <= 7;
    return AppCard(
      child: Row(
        children: [
          Container(width: 4, height: 60, decoration: BoxDecoration(color: isUrgent ? AppColors.red : AppColors.blue, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exam.moduleName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.g900)),
                const SizedBox(height: 2),
                Text(DateFormat('EEEE, dd MMM yyyy').format(exam.examDate), style: const TextStyle(color: AppColors.g500, fontSize: 12)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _showStudyPlan(context),
                  child: const Text('View Study Plan →', style: TextStyle(color: AppColors.blue, fontSize: 12, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isUrgent ? const Color(0xFFFEF2F2) : AppColors.blueLt,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${exam.daysRemaining}d', style: TextStyle(color: isUrgent ? AppColors.red : AppColors.blue, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => svc.deleteExam(exam.id),
                    child: const Icon(Icons.delete_outline, color: AppColors.g500, size: 18),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStudyPlan(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.7,
        builder: (_, scroll) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.blue),
                  const SizedBox(width: 8),
                  Expanded(child: Text('${exam.moduleName} — Study Plan', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.navy))),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirestoreService().getExamTasks(exam.id),
                builder: (ctx, snap) {
                  final tasks = snap.data ?? [];
                  if (tasks.isEmpty) return const Center(child: Text('No study plan yet.', style: TextStyle(color: AppColors.g500)));
                  // Group by examId (we use title prefix "Week X")
                  final weeks = <String, List<StudyTask>>{};
                  for (final t in tasks) {
                    final week = t.title.startsWith('Week') ? t.title.split(' - ').first.split(':').first : 'Tasks';
                    weeks.putIfAbsent(week, () => []).add(t);
                  }
                  return ListView(
                    controller: scroll,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: weeks.entries.map((e) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 8, bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(6)),
                          child: Text(e.key, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        ...e.value.map((t) => CheckboxListTile(
                          dense: true, value: t.completed, activeColor: AppColors.blue,
                          title: Text(t.title, style: TextStyle(fontSize: 13, decoration: t.completed ? TextDecoration.lineThrough : null, color: t.completed ? AppColors.g500 : AppColors.g900)),
                          onChanged: (v) => FirestoreService().toggleTask(t.id, v ?? false),
                        )),
                      ],
                    )).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
