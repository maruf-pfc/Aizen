import 'package:flutter/material.dart';
import '../../domain/entities/habit.dart';

class ContributionGrid extends StatelessWidget {
  final Habit habit;

  const ContributionGrid({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(const Duration(days: 364));

    final completedSet = habit.completionHistory.map(
      (d) {
        final local = d.toLocal();
        return '${local.year}-${local.month}-${local.day}';
      },
    ).toSet();

    final relapseSet = habit.relapseLogs.map(
      (l) {
        final local = l.timestamp.toLocal();
        return '${local.year}-${local.month}-${local.day}';
      },
    ).toSet();

    final localCreated = habit.createdAt.toLocal();
    final creationDate = DateTime(localCreated.year, localCreated.month, localCreated.day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '365-DAY DRIFT MAP',
              style: TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            Row(
              children: [
                _buildLegendItem('Active', const Color(0xFF00E676)),
                const SizedBox(width: 8),
                _buildLegendItem('Slipped', const Color(0xFFFF5252)),
                const SizedBox(width: 8),
                _buildLegendItem('Missed', const Color(0xFF1E1E1E)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 100,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF141414)),
          ),
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
              childAspectRatio: 1.0,
            ),
            itemCount: 365,
            itemBuilder: (context, index) {
              final date = DateTime(startDate.year, startDate.month, startDate.day + index);
              final dateKey = '${date.year}-${date.month}-${date.day}';

              Color cellColor = const Color(0xFF0D0D0D);

              if (completedSet.contains(dateKey)) {
                cellColor = const Color(0xFF00E676);
              } else if (relapseSet.contains(dateKey)) {
                cellColor = const Color(0xFFFF5252);
              } else if (date.isAfter(today)) {
                cellColor = Colors.transparent;
              } else if (date.isAfter(creationDate) || date.isAtSameMomentAs(creationDate)) {
                cellColor = const Color(0xFF1E1E1E);
              }

              return Container(
                decoration: BoxDecoration(
                  color: cellColor,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 8,
          ),
        ),
      ],
    );
  }
}
