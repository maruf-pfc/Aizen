import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/habit.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';
import 'contribution_grid.dart';
import 'relapse_dialog.dart';
import 'failure_ledger.dart';

class HabitCard extends StatefulWidget {
  final Habit habit;

  const HabitCard({super.key, required this.habit});

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  Timer? _tickerTimer;
  String _timeString = '00d 00h 00m 00s';

  @override
  void initState() {
    super.initState();
    if (widget.habit.isAutomatic) {
      _updateTimeString();
      _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _updateTimeString();
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant HabitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.habit.isAutomatic != oldWidget.habit.isAutomatic) {
      _tickerTimer?.cancel();
      if (widget.habit.isAutomatic) {
        _updateTimeString();
        _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() {
              _updateTimeString();
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }

  void _updateTimeString() {
    final start = widget.habit.lastResetAt ?? widget.habit.createdAt;
    final diff = DateTime.now().difference(start);

    if (diff.isNegative) {
      _timeString = '00d 00h 00m 00s';
      return;
    }

    final d = diff.inDays.toString().padLeft(2, '0');
    final h = (diff.inHours % 24).toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');

    _timeString = '${d}d ${h}h ${m}m ${s}s';
  }

  Color _getLevelColor(int days) {
    if (days < 1) return const Color(0xFF9E9E9E); // Recruit
    if (days < 3) return const Color(0xFF4CAF50); // Apprentice
    if (days < 7) return const Color(0xFF00BCD4); // Sentinel
    if (days < 14) return const Color(0xFF2196F3); // Guardian
    if (days < 30) return const Color(0xFF9C27B0); // Overlord
    if (days < 60) return const Color(0xFFFF9800); // Conqueror
    if (days < 90) return const Color(0xFFE91E63); // Immortal
    return const Color(0xFF7C4DFF); // Iron Will
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month}-${now.day}';
    final completedToday = habit.completionHistory.any(
      (d) {
        final local = d.toLocal();
        return local.year == now.year && local.month == now.month && local.day == now.day;
      },
    );

    final activeDays = habit.activeStreakDays;
    final levelColor = _getLevelColor(activeDays);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF161618),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF242426), width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title + Level badge
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.title.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          habit.isAutomatic ? 'AUTOMATIC MODE' : 'MANUAL CHECK-IN MODE',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: levelColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: levelColor.withValues(alpha: 0.5), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          size: 11,
                          color: levelColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          habit.levelTitle.toUpperCase(),
                          style: TextStyle(
                            color: levelColor,
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Level progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: habit.levelProgress,
                    backgroundColor: const Color(0xFF242426),
                    color: levelColor,
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Streak: $activeDays days',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        'Longest: ${habit.longestStreak} days',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(color: Color(0xFF242426), height: 1),

            // Main Content Area: Automatic time counter OR manual button
            Padding(
              padding: const EdgeInsets.all(16),
              child: habit.isAutomatic
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _timeString,
                            style: TextStyle(
                              color: levelColor,
                              fontSize: 26,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'TIME ELAPSED CLEAN',
                            style: TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${habit.currentStreak}',
                                  style: const TextStyle(
                                    color: Color(0xFF7C4DFF),
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'CURRENT STREAK',
                                  style: TextStyle(
                                    color: Color(0xFF00E676),
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                            if (completedToday)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0x1B00E676),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF00E676), width: 1.0),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 14,
                                      color: Color(0xFF00E676),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'COMPLETED',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF00E676),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00E676),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  context.read<HabitBloc>().add(
                                        CompleteHabitDayEvent(id: habit.id, date: DateTime.now()),
                                      );
                                },
                                icon: const Icon(
                                  Icons.add_task,
                                  size: 14,
                                ),
                                label: const Text(
                                  'COMPLETE TODAY',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ContributionGrid(habit: habit),
                      ],
                    ),
            ),

            const Divider(color: Color(0xFF242426), height: 1),

            // Card Footer Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF7C4DFF),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        icon: const Icon(Icons.analytics_outlined, size: 16),
                        label: const Text('HISTORY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FailureLedger(habit: habit)),
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFFF5252),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('RESET STREAK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => BlocProvider.value(
                              value: context.read<HabitBloc>(),
                              child: RelapseDialog(habitId: habit.id),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Color(0xFF9E9E9E), size: 18),
                    tooltip: 'Delete Habit',
                    onPressed: () => _confirmDelete(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (diagContext) => AlertDialog(
        backgroundColor: const Color(0xFF161618),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF242426)),
        ),
        title: const Text(
          'DELETE HABIT TRACKER',
          style: TextStyle(color: Color(0xFFFF5252), fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this habit and all its history permanently?',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
        actions: [
          TextButton(
            child: Text('CANCEL', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
            onPressed: () => Navigator.of(diagContext).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0,
            ),
            onPressed: () {
              context.read<HabitBloc>().add(DeleteHabitEvent(widget.habit.id));
              Navigator.of(diagContext).pop();
            },
            child: const Text('DELETE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
