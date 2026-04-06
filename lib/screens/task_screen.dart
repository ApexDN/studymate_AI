import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../models/app_models.dart';
import '../widgets/app_theme.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});
  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _svc = FirestoreService();
  late final String _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
  }

  void _addTask() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Study Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy)),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Task description',
                prefixIcon: const Icon(Icons.edit_outlined, color: AppColors.g500),
                filled: true, fillColor: AppColors.g100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (ctrl.text.trim().isEmpty) return;
                  _svc.addTask(StudyTask(
                    id: '', title: ctrl.text.trim(), completed: false,
                    userId: _uid, date: DateTime.now(),
                  ));
                  Navigator.pop(ctx);
                },
                child: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.g100,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Today's Tasks"),
            Text(DateFormat('EEEE, d MMMM').format(DateTime.now()),
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        backgroundColor: AppColors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<StudyTask>>(
        stream: _svc.getTodayTasks(_uid),
        builder: (ctx, snap) {
          final tasks = snap.data ?? [];
          final done  = tasks.where((t) => t.completed).length;
          final pct   = tasks.isEmpty ? 0.0 : done / tasks.length;

          return Column(
            children: [
              // Progress bar
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.g300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Daily Progress', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
                        Text('$done / ${tasks.length} tasks', style: const TextStyle(color: AppColors.g500, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 10,
                        backgroundColor: AppColors.g100,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.blue),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('${(pct * 100).toStringAsFixed(0)}% complete',
                        style: const TextStyle(color: AppColors.g500, fontSize: 12)),
                  ],
                ),
              ),
              // Task list
              Expanded(
                child: tasks.isEmpty
                    ? const Center(child: Text('No tasks today.\nTap + to add a task!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.g500)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: tasks.length,
                        itemBuilder: (ctx, i) {
                          final t = tasks[i];
                          return Dismissible(
                            key: Key(t.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => _svc.deleteTask(t.id),
                            child: AppCard(
                              color: t.completed ? const Color(0xFFF0FDF4) : Colors.white,
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: t.completed,
                                    activeColor: AppColors.blue,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    onChanged: (v) => _svc.toggleTask(t.id, v ?? false),
                                  ),
                                  Expanded(
                                    child: Text(
                                      t.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: t.completed ? AppColors.g500 : AppColors.g900,
                                        decoration: t.completed ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
