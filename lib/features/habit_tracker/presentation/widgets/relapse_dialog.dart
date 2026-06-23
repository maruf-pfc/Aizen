import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../../../core/theme/aizen_theme.dart';
import '../../domain/entities/relapse_log.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';

class RelapseDialog extends StatefulWidget {
  final String habitId;

  const RelapseDialog({super.key, required this.habitId});

  @override
  State<RelapseDialog> createState() => _RelapseDialogState();
}

class _RelapseDialogState extends State<RelapseDialog> {
  final _formKey = GlobalKey<FormState>();
  String _selectedRootCause = 'Stress';
  final _triggerController = TextEditingController();
  final _notesController = TextEditingController();
  int _severity = 3;
  bool _showBreathing = false;

  final List<String> _rootCauses = [
    'Stress',
    'Fatigue',
    'Boredom',
    'Social pressure',
    'Anxiety',
    'Loneliness',
    'Other'
  ];

  final List<String> _quickTriggers = [
    'Work/Study fatigue',
    'Late night scrolling',
    'Negative thoughts',
    'Peer pressure',
    'Unstructured time',
  ];

  @override
  void dispose() {
    _triggerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final log = RelapseLog(
        id: UniqueKey().toString(),
        habitId: widget.habitId,
        timestamp: DateTime.now(),
        rootCause: _selectedRootCause,
        trigger: _triggerController.text.trim(),
        severity: _severity,
        notes: _notesController.text.trim(),
      );

      context.read<HabitBloc>().add(ResetHabitEvent(id: widget.habitId, log: log));
      
      setState(() {
        _showBreathing = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showBreathing) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AizenTheme.surfaceLow,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: BreathingTriageWidget(
            stressLevel: _severity,
            onFinished: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF161618),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'RELAPSE JOURNAL & NOTES',
                  style: TextStyle(
                    color: Color(0xFFFF5252),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Root Cause Category',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRootCause,
                      dropdownColor: const Color(0xFF161618),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      isExpanded: true,
                      items: _rootCauses.map((cause) {
                        return DropdownMenuItem<String>(
                          value: cause,
                          child: Text(cause),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedRootCause = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Trigger Context',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _triggerController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'What sparked the relapse?',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 13),
                    fillColor: const Color(0xFF0F0F10),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF5252), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Trigger is required' : null,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _quickTriggers.map((trig) {
                    return ActionChip(
                      label: Text(trig),
                      labelStyle: const TextStyle(color: Colors.white, fontSize: 10),
                      backgroundColor: const Color(0xFF0F0F10),
                      side: const BorderSide(color: Color(0xFF1E1E20)),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onPressed: () {
                        setState(() {
                          _triggerController.text = trig;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Stress & Anxiety Level (1-5)',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Stress: $_severity',
                      style: const TextStyle(color: Color(0xFFFF5252), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    activeTrackColor: const Color(0xFFFF5252),
                    inactiveTrackColor: const Color(0xFF1E1E20),
                    thumbColor: const Color(0xFFFF5252),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayColor: const Color(0xFFFF5252).withValues(alpha: 0.2),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  ),
                  child: Slider(
                    value: _severity.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    onChanged: (val) {
                      setState(() {
                        _severity = val.toInt();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Post-Relapse Reflection / Journal Note',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _notesController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Reflect on what to adjust for the next attempt...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 12),
                    fillColor: const Color(0xFF0F0F10),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF5252), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: Text('CANCEL', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5252),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        elevation: 0,
                      ),
                      onPressed: _submit,
                      child: const Text(
                        'RESET STREAK',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BreathingTriageWidget extends StatefulWidget {
  final int stressLevel;
  final VoidCallback onFinished;

  const BreathingTriageWidget({
    super.key,
    required this.stressLevel,
    required this.onFinished,
  });

  @override
  State<BreathingTriageWidget> createState() => _BreathingTriageWidgetState();
}

class _BreathingTriageWidgetState extends State<BreathingTriageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Timer? _timer;
  int _secondsRemaining = 4;
  String _phase = 'Inhale'; // 'Inhale', 'Hold', 'Exhale'
  int _cycle = 1;
  late final int _targetCycles;

  @override
  void initState() {
    super.initState();
    _targetCycles = widget.stressLevel >= 4 ? 4 : 2;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _startPhase('Inhale');
  }

  void _startPhase(String newPhase) {
    _phase = newPhase;
    _animController.stop();
    if (newPhase == 'Inhale') {
      _secondsRemaining = 4;
      _animController.duration = const Duration(seconds: 4);
      _animController.forward(from: 0.0);
    } else if (newPhase == 'Hold') {
      _secondsRemaining = 7;
      _animController.value = 1.0;
    } else {
      _secondsRemaining = 8;
      _animController.duration = const Duration(seconds: 8);
      _animController.reverse(from: 1.0);
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 1) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
          _nextPhase();
        }
      });
    });
  }

  void _nextPhase() {
    if (_phase == 'Inhale') {
      _startPhase('Hold');
    } else if (_phase == 'Hold') {
      _startPhase('Exhale');
    } else {
      if (_cycle < _targetCycles) {
        setState(() {
          _cycle++;
        });
        _startPhase('Inhale');
      } else {
        widget.onFinished();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _phase == 'Inhale'
        ? AizenTheme.accentCyan
        : (_phase == 'Hold' ? AizenTheme.primaryPurple : AizenTheme.accentAmber);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.spa_outlined, color: AizenTheme.accentCyan, size: 28),
          const SizedBox(height: 12),
          const Text(
            'BEHAVIORAL TRIAGE: CALMING DOWN',
            style: TextStyle(
              color: AizenTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Recommended: $_targetCycles cycles of 4-7-8 Breathing',
            style: const TextStyle(
              color: AizenTheme.textTertiary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                final scale = 1.0 + (_animController.value * 0.8);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.15),
                      border: Border.all(color: color, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_secondsRemaining',
                            style: TextStyle(
                              color: color,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            _phase.toUpperCase(),
                            style: TextStyle(
                              color: color,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 60),
          Text(
            _instructionText(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AizenTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cycle $_cycle of $_targetCycles',
            style: const TextStyle(
              color: AizenTheme.textTertiary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AizenTheme.textTertiary.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: widget.onFinished,
                child: const Text(
                  'SKIP EXERCISE',
                  style: TextStyle(
                    color: AizenTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _instructionText() {
    switch (_phase) {
      case 'Inhale':
        return 'Inhale deeply through your nose...';
      case 'Hold':
        return 'Hold your breath and stay still...';
      case 'Exhale':
        return 'Exhale completely through your mouth...';
      default:
        return '';
    }
  }
}
