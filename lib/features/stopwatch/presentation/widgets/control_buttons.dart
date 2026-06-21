import 'package:flutter/material.dart';
import '../bloc/stopwatch_state.dart';

class ControlButtons extends StatelessWidget {
  final StopwatchStatus status;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;
  final VoidCallback onLap;

  const ControlButtons({
    super.key,
    required this.status,
    required this.onStart,
    required this.onPause,
    required this.onReset,
    required this.onLap,
  });

  @override
  Widget build(BuildContext context) {
    final isRunning = status == StopwatchStatus.running;
    final isPaused = status == StopwatchStatus.paused;
    final isInitial = status == StopwatchStatus.initial;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isInitial) ...[
            _buildButton(
              context: context,
              label: 'START',
              onPressed: onStart,
              color: const Color(0xFF7C4DFF), // Premium electric violet
              textColor: Colors.white,
              icon: Icons.play_arrow_rounded,
            ),
          ],
          if (isRunning) ...[
            _buildButton(
              context: context,
              label: 'LAP',
              onPressed: onLap,
              color: Colors.white.withValues(alpha: 0.08),
              textColor: Colors.white.withValues(alpha: 0.9),
              icon: Icons.flag_outlined,
              isOutlined: true,
            ),
            const SizedBox(width: 16),
            _buildButton(
              context: context,
              label: 'PAUSE',
              onPressed: onPause,
              color: const Color(0xFFFF5252), // Premium rose/coral
              textColor: Colors.white,
              icon: Icons.pause_rounded,
            ),
          ],
          if (isPaused) ...[
            _buildButton(
              context: context,
              label: 'RESET',
              onPressed: onReset,
              color: Colors.white.withValues(alpha: 0.08),
              textColor: const Color(0xFFFF5252),
              icon: Icons.refresh_rounded,
              isOutlined: true,
            ),
            const SizedBox(width: 16),
            _buildButton(
              context: context,
              label: 'RESUME',
              onPressed: onStart,
              color: const Color(0xFF00E676), // Neon mint/teal
              textColor: Colors.black,
              icon: Icons.play_arrow_rounded,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    required Color textColor,
    required IconData icon,
    bool isOutlined = false,
  }) {
    final style = ButtonStyle(
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(vertical: 14),
      ),
      backgroundColor: WidgetStateProperty.all(
        isOutlined ? Colors.transparent : color,
      ),
      foregroundColor: WidgetStateProperty.all(textColor),
      overlayColor: WidgetStateProperty.all(
        textColor.withValues(alpha: 0.1),
      ),
      side: WidgetStateProperty.all(
        isOutlined
            ? BorderSide(color: textColor.withValues(alpha: 0.2), width: 1.5)
            : BorderSide.none,
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    return Expanded(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 160),
        child: TextButton.icon(
          onPressed: onPressed,
          style: style,
          icon: Icon(icon, size: 18, color: textColor),
          label: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              fontSize: 12,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
