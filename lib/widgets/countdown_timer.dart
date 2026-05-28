import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Geri sayım sayacı — tartışma fazı için.
class CountdownTimer extends StatefulWidget {
  const CountdownTimer({
    super.key,
    required this.seconds,
    this.onFinish,
    this.size = 140,
  });

  final int seconds;
  final VoidCallback? onFinish;
  final double size;

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late int _remaining;
  Timer? _timer;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
    _start();
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (_paused) return;
      if (_remaining <= 0) {
        t.cancel();
        widget.onFinish?.call();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(int s) {
    final int m = s ~/ 60;
    final int sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final double progress = _remaining / widget.seconds;
    final Color color = _remaining < 30 ? AppColors.blood : AppColors.gold;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: AppColors.surface,
                  color: color,
                ),
              ),
              Text(
                _format(_remaining),
                style: AppTextStyles.displaySmall.copyWith(color: color),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              onPressed: () => setState(() => _paused = !_paused),
              icon: Icon(_paused ? Icons.play_arrow : Icons.pause),
              color: AppColors.gold,
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: () {
                setState(() {
                  _remaining = widget.seconds;
                  _paused = false;
                });
                _start();
              },
              icon: const Icon(Icons.refresh),
              color: AppColors.gold,
            ),
          ],
        ),
      ],
    );
  }
}
