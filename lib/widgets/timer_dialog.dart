import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/ritual.dart';
import '../theme/linear_gradient.dart';

class TimerDialog extends StatefulWidget {
  final Ritual ritual;
  final VoidCallback onComplete;

  const TimerDialog({super.key, required this.ritual, required this.onComplete});

  @override
  State<TimerDialog> createState() => _TimerDialogState();
}

class _TimerDialogState extends State<TimerDialog> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = (widget.ritual.durationMinutes ?? 10) * 60;
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        _finish();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _finish() {
    _timer?.cancel();
    widget.onComplete();
    Navigator.pop(context);
  }

  String get _timeString {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F36),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.ritual.icon, color: widget.ritual.color, size: 50),
              const SizedBox(height: 20),
              Text(widget.ritual.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(_timeString, style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w200, letterSpacing: 2)),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                    icon: Icon(_isRunning ? Icons.pause_circle_filled : Icons.play_circle_fill, color: AppColors.accentLavender, size: 64),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Colors.white38)),
              ),
              TextButton(
                onPressed: _finish,
                child: const Text("Skip to Finish", style: TextStyle(color: AppColors.accentLavender, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
