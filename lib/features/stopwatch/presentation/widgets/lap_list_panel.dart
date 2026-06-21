import 'package:flutter/material.dart';
import '../../domain/entities/lap.dart';

class LapListPanel extends StatelessWidget {
  final List<Lap> laps;

  const LapListPanel({
    super.key,
    required this.laps,
  });

  String _formatDuration(Duration duration) {
    final totalMs = duration.inMilliseconds;
    final hundredths = (totalMs % 1000) ~/ 10;
    final totalSec = duration.inSeconds;
    final seconds = totalSec % 60;
    final totalMin = totalSec ~/ 60;
    final minutes = totalMin % 60;
    final hours = totalMin ~/ 60;

    final hoursStr = hours > 0 ? '${hours.toString().padLeft(2, '0')}:' : '';
    final minutesStr = '${minutes.toString().padLeft(2, '0')}:';
    final secondsStr = seconds.toString().padLeft(2, '0');
    final hundredthsStr = '.${hundredths.toString().padLeft(2, '0')}';

    return '$hoursStr$minutesStr$secondsStr$hundredthsStr';
  }

  @override
  Widget build(BuildContext context) {
    if (laps.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer_outlined,
                color: Colors.white.withValues(alpha: 0.15),
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'No Laps Recorded',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Find fastest and slowest laps for highlighting
    Lap? fastestLap;
    Lap? slowestLap;
    if (laps.length >= 2) {
      fastestLap = laps.reduce((a, b) => a.lapTime < b.lapTime ? a : b);
      slowestLap = laps.reduce((a, b) => a.lapTime > b.lapTime ? a : b);

      // If they are equal, don't highlight
      if (fastestLap.lapTime == slowestLap.lapTime) {
        fastestLap = null;
        slowestLap = null;
      }
    }

    final reversedLaps = laps.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Table Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'LAP',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'SPLIT',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'TOTAL TIME',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(color: Colors.white12, height: 1, thickness: 0.5),
        // Lap rows
        Expanded(
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: reversedLaps.length,
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            itemBuilder: (context, index) {
              final lap = reversedLaps[index];
              final isFastest = fastestLap != null && lap == fastestLap;
              final isSlowest = slowestLap != null && lap == slowestLap;

              Color lapTimeColor = Colors.white.withValues(alpha: 0.9);
              String label = '';
              if (isFastest) {
                lapTimeColor = const Color(0xFF00E676); // Mint green for fastest
                label = ' (Fast)';
              } else if (isSlowest) {
                lapTimeColor = const Color(0xFFFF5252); // Coral red for slowest
                label = ' (Slow)';
              }

              final rowBackground = index % 2 == 0
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.015);

              return Container(
                color: rowBackground,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                child: Row(
                  children: [
                    // Lap number
                    Expanded(
                      flex: 2,
                      child: Text(
                        '#${lap.index.toString().padLeft(2, '0')}$label',
                        style: TextStyle(
                          color: isFastest
                              ? const Color(0xFF00E676)
                              : isSlowest
                                  ? const Color(0xFFFF5252)
                                  : Colors.white.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    // Lap duration (Split)
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _formatDuration(lap.lapTime),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: lapTimeColor,
                              fontWeight: isFastest || isSlowest
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 13,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          if (isFastest || isSlowest)
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Icon(
                                isFastest
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                size: 12,
                                color: lapTimeColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Cumulative total time
                    Expanded(
                      flex: 4,
                      child: Text(
                        _formatDuration(lap.cumulativeTime),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
