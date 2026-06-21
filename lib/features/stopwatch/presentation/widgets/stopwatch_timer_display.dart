import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class StopwatchTimerDisplay extends StatefulWidget {
  final Duration baseElapsedTime;
  final DateTime? startTime;
  final bool isRunning;
  final TextStyle textStyle;
  final TextStyle milliTextStyle;

  const StopwatchTimerDisplay({
    super.key,
    required this.baseElapsedTime,
    required this.startTime,
    required this.isRunning,
    required this.textStyle,
    required this.milliTextStyle,
  });

  @override
  State<StopwatchTimerDisplay> createState() => _StopwatchTimerDisplayState();
}

class _StopwatchTimerDisplayState extends State<StopwatchTimerDisplay>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  late Duration _currentDuration;

  @override
  void initState() {
    super.initState();
    _currentDuration = _calculateCurrentDuration();
    _ticker = createTicker((elapsed) {
      final newDuration = _calculateCurrentDuration();
      if (newDuration.inMilliseconds ~/ 10 != _currentDuration.inMilliseconds ~/ 10) {
        setState(() {
          _currentDuration = newDuration;
        });
      }
    });

    if (widget.isRunning) {
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(covariant StopwatchTimerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning != oldWidget.isRunning) {
      if (widget.isRunning) {
        if (!_ticker.isActive) {
          _ticker.start();
        }
      } else {
        if (_ticker.isActive) {
          _ticker.stop();
        }
      }
    }
    setState(() {
      _currentDuration = _calculateCurrentDuration();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Duration _calculateCurrentDuration() {
    if (widget.isRunning && widget.startTime != null) {
      return widget.baseElapsedTime + DateTime.now().difference(widget.startTime!);
    }
    return widget.baseElapsedTime;
  }

  @override
  Widget build(BuildContext context) {
    final totalMs = _currentDuration.inMilliseconds;
    final hundredths = (totalMs % 1000) ~/ 10;
    final totalSec = _currentDuration.inSeconds;
    final seconds = totalSec % 60;
    final totalMin = totalSec ~/ 60;
    final minutes = totalMin % 60;
    final hours = totalMin ~/ 60;

    final hoursStr = hours > 0 ? '${hours.toString().padLeft(2, '0')}:' : '';
    final minutesStr = '${minutes.toString().padLeft(2, '0')}:';
    final secondsStr = seconds.toString().padLeft(2, '0');
    final hundredthsStr = '.${hundredths.toString().padLeft(2, '0')}';

    final baseStyle = widget.textStyle.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final milliStyle = widget.milliTextStyle.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '$hoursStr$minutesStr$secondsStr',
            style: baseStyle,
          ),
          Text(
            hundredthsStr,
            style: milliStyle,
          ),
        ],
      ),
    );
  }
}
