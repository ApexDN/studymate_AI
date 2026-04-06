import 'package:flutter/material.dart';

class AppColors {
  static const navy  = Color(0xFF1E3A5F);
  static const blue  = Color(0xFF2563EB);
  static const blueLt= Color(0xFFDBEAFE);
  static const g900  = Color(0xFF111827);
  static const g700  = Color(0xFF374151);
  static const g500  = Color(0xFF6B7280);
  static const g300  = Color(0xFFD1D5DB);
  static const g100  = Color(0xFFF3F4F6);
  static const green = Color(0xFF16A34A);
  static const red   = Color(0xFFDC2626);
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  const AppCard({super.key, required this.child, this.padding, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.g300),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Padding(padding: padding ?? const EdgeInsets.all(14), child: child),
    );
  }
}

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const StatCard({super.key, required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppColors.blueLt, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: AppColors.blue),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.g900)),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.g500)),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navy)),
    );
  }
}

const List<String> motivationalMessages = [
  "Stay focused. Small progress every day leads to success. 🎯",
  "Your exam is coming soon. Keep pushing forward! 💪",
  "Consistency beats motivation. Study today. 📚",
  "Every hour you study now is an hour of confidence on exam day. ✨",
  "You've got this! Break it down, one task at a time. 🚀",
  "Hard work beats talent when talent doesn't work hard. 🔥",
  "Your future self will thank you for studying today. 🌟",
  "Progress, not perfection. Keep going! 📈",
];
