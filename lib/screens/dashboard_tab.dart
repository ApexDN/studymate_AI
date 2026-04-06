import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Firebase authentication
import 'package:intl/intl.dart';  // For date formatting
import '../services/firestore_service.dart'; // Custom Firestore service
import '../models/app_models.dart';
import '../widgets/app_theme.dart';

// DashboardTab displays the main dashboard screen
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Get currently logged-in user
    final user = FirebaseAuth.instance.currentUser!;
    // Initialize Firestore service
    final svc  = FirestoreService();
    // Select a random motivational message
    final msg  = motivationalMessages[Random().nextInt(motivationalMessages.length)];

    return Scaffold(
      backgroundColor: AppColors.g100,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 100,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.navy,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting with user's first name
                    Text('Good day, ${user.displayName?.split(' ').first ?? 'Student'} ',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    // Current date
                    Text(DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                  ],
                ),
              ),
            ),

            // Main content padding
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Motivational message card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.navy, AppColors.blue]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Expanded(child: Text(msg, style: const TextStyle(color: Colors.white, fontSize: 13))),
                      ],
                    ),
                  ),
                  const SectionTitle('Overview'),
                  // Stats grid
                  FutureBuilder<Map<String, int>>(
                    future: svc.getDashboardStats(user.uid),
                    builder: (ctx, snap) {
                      final stats = snap.data ?? {'modules': 0, 'exams': 0, 'completedTasks': 0, 'sessions': 0};
                      // Grid layout for stats
                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.4,
                        children: [
                          StatCard(value: '${stats['exams']}',         label: 'Exams',     icon: Icons.calendar_today),
                          StatCard(value: '${stats['completedTasks']}',label: 'Tasks Done', icon: Icons.check_circle_outline),
                          StatCard(value: '${stats['sessions']}',       label: 'Sessions',  icon: Icons.timer),
                          StatCard(value: '${stats['modules']}',        label: 'Modules',   icon: Icons.book_outlined),
                        ],
                      );
                    },
                  ),
                  const SectionTitle('Upcoming Exams'),
                  // Real-time exam list using StreamBuilder
                  StreamBuilder<List<Exam>>(
                    stream: svc.getExams(user.uid),
                    builder: (ctx, snap) {
                      // Take only first 3 exams
                      final exams = snap.data?.take(3).toList() ?? [];
                      // If no exams exist
                      if (exams.isEmpty) return const AppCard(child: Center(child: Text('No exams yet. Add one!', style: TextStyle(color: AppColors.g500))));
                      // Display list of exam cards
                      return Column(
                        children: exams.map((e) => AppCard(
                          child: Row(
                            children: [
                              Container(width: 4, height: 48, decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(2))),
                              const SizedBox(width: 12),
                              // Exam details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Module name
                                    Text(e.moduleName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.g900)),
                                    // Exam date
                                    Text(DateFormat('dd MMM yyyy').format(e.examDate), style: const TextStyle(color: AppColors.g500, fontSize: 12)),
                                  ],
                                ),
                              ),
                              // Days remaining badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  // selected if exam is within 7 days
                                  color: e.daysRemaining <= 7 ? const Color(0xFFFEF2F2) : AppColors.blueLt,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${e.daysRemaining}d',
                                  style: TextStyle(
                                    color: e.daysRemaining <= 7 ? AppColors.red : AppColors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
