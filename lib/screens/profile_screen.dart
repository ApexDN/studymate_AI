import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.g100,
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.blue,
              child: Text(
                (user?.displayName?.isNotEmpty == true ? user!.displayName![0] : 'S').toUpperCase(),
                style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 14),
            Text(user?.displayName ?? 'Student', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy)),
            Text(user?.email ?? '', style: const TextStyle(color: AppColors.g500)),
            const SizedBox(height: 30),
            AppCard(
              child: Column(
                children: [
                  _tile(Icons.school, 'Module: PUSL2023'),
                  const Divider(height: 1),
                  _tile(Icons.auto_awesome, 'AI Study Plans: Enabled'),
                  const Divider(height: 1),
                  _tile(Icons.notifications_outlined, 'Notifications: Enabled'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: ListTile(
                leading: const Icon(Icons.logout, color: AppColors.red),
                title: const Text('Sign Out', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w500)),
                onTap: () async {
                  await auth.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
                  }
                },
              ),
            ),
            const Spacer(),
            const Text('StudyMate AI v1.0.0', style: TextStyle(color: AppColors.g300, fontSize: 12)),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  ListTile _tile(IconData icon, String text) => ListTile(
        leading: Icon(icon, color: AppColors.blue, size: 20),
        title: Text(text, style: const TextStyle(fontSize: 14, color: AppColors.g700)),
        dense: true,
      );
}
