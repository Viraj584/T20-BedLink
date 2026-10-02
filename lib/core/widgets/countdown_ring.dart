import 'dart:async';
import 'package:flutter/material.dart';

class CountdownRing extends StatefulWidget {
  final DateTime? offerExpiresAt;
  final int totalDurationSeconds;
  final VoidCallback? onExpired;
  final bool isDarkTheme;

  const CountdownRing({
    super.key,
    required this.offerExpiresAt,
    this.totalDurationSeconds = 120,
    this.onExpired,
    this.isDarkTheme = false,
  });

  @override
  State<CountdownRing> createState() => _CountdownRingState();
}

class _CountdownRingState extends State<CountdownRing> {
  Timer? _timer;
  int _remainingSeconds = 120;
  bool _hasTriggeredExpired = false;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    if (widget.offerExpiresAt == null) return;
    final now = DateTime.now();
    final diff = widget.offerExpiresAt!.difference(now).inSeconds;

    if (mounted) {
      setState(() {
        _remainingSeconds = diff > 0 ? diff : 0;
      });
    }

    if (_remainingSeconds <= 0 && !_hasTriggeredExpired) {
      _hasTriggeredExpired = true;
      widget.onExpired?.call();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSecs) {
    final mins = totalSecs ~/ 60;
    final secs = totalSecs % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_remainingSeconds / widget.totalDurationSeconds).clamp(0.0, 1.0);

    Color color;
    if (_remainingSeconds > 60) {
      color = widget.isDarkTheme ? const Color(0xFF2ECC71) : const Color(0xFF1E9E5A);
    } else if (_remainingSeconds > 30) {
      color = widget.isDarkTheme ? const Color(0xFFFFC107) : const Color(0xFFE8A317);
    } else {
      color = widget.isDarkTheme ? const Color(0xFFFF5252) : const Color(0xFFD32F2F);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: color.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatTime(_remainingSeconds),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: widget.isDarkTheme ? Colors.white : color,
                    ),
                  ),
                  Text(
                    'REMAINING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: widget.isDarkTheme ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
