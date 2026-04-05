import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../widgets/app_theme.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});
  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> with SingleTickerProviderStateMixin {
  static const _totalSeconds = 25 * 60;
  int _remaining = _totalSeconds;
  bool _running  = false;
  Timer? _timer;
  final _svc = FirestoreService();
  late final String _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 0) {
        _timer?.cancel();
        setState(() { _running = false; _remaining = 0; });
        _onComplete();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  void _reset() {
    _timer?.cancel();
    setState(() { _running = false; _remaining = _totalSeconds; });
  }

  Future<void> _onComplete() async {
    await _svc.addPomodoroSession(_uid);
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Session Complete! 🎉', style: TextStyle(color: AppColors.navy)),
          content: const Text('Great work! Take a short 5-minute break before your next session.'),
          actions: [TextButton(onPressed: () { Navigator.pop(context); _reset(); }, child: const Text('Start Next'))],
        ),
      );
    }
  }

  String get _timeStr {
    final m = _remaining ~/ 60;
    final s = _remaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _progress => 1 - (_remaining / _totalSeconds);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.g100,
      appBar: AppBar(title: const Text('Pomodoro Timer')),
      body: StreamBuilder<int>(
        stream: _svc.getSessionCount(_uid),
        builder: (ctx, snap) {
          final sessions = snap.data ?? 0;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text('Stay focused. You can do this.',
                      style: TextStyle(color: AppColors.g500, fontSize: 14)),
                  const SizedBox(height: 40),
                  // Circular timer
                  SizedBox(
                    width: 220, height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 220, height: 220,
                          child: CircularProgressIndicator(
                            value: _progress,
                            strokeWidth: 12,
                            backgroundColor: AppColors.g100,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _running ? AppColors.blue : AppColors.g300,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_timeStr, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.navy, fontFeatures: [FontFeature.tabularFigures()])),
                            Text(_running ? 'Focus session' : _remaining == 0 ? 'Complete! 🎉' : 'Ready',
                                style: const TextStyle(color: AppColors.g500, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Session dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < (sessions % 5) ? AppColors.blue : AppColors.g300,
                      ),
                    )),
                  ),
                  const SizedBox(height: 8),
                  Text('$sessions sessions completed', style: const TextStyle(color: AppColors.g500, fontSize: 13)),
                  const SizedBox(height: 32),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!_running)
                        ElevatedButton.icon(
                          onPressed: _remaining == 0 ? null : _start,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start'),
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: _pause,
                          icon: const Icon(Icons.pause),
                          label: const Text('Pause'),
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                        ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: _reset,
                        icon: const Icon(Icons.refresh, color: AppColors.g500),
                        label: const Text('Reset', style: TextStyle(color: AppColors.g500)),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('How to Pomodoro', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
                        const SizedBox(height: 8),
                        ...[
                          '1. Pick a task to work on',
                          '2. Start the 25-minute timer',
                          '3. Work until the timer rings',
                          '4. Take a 5-minute break',
                          '5. Repeat 4 times, then take a longer break',
                        ].map((t) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(t, style: const TextStyle(color: AppColors.g700, fontSize: 13)),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
