import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      buildWhen: (previous, current) => previous.sortOrder != current.sortOrder,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              const Text(
                'Sort by:',
                style: TextStyle(
                  color: Color(0x66FFFFFF),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              _SortChip(
                label: 'Priority',
                order: SortOrder.priority,
                selected: state.sortOrder == SortOrder.priority,
              ),
              const SizedBox(width: 8),
              _SortChip(
                label: 'Due Date',
                order: SortOrder.dueDate,
                selected: state.sortOrder == SortOrder.dueDate,
              ),
              const SizedBox(width: 8),
              _SortChip(
                label: 'Newest',
                order: SortOrder.creationDate,
                selected: state.sortOrder == SortOrder.creationDate,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final SortOrder order;
  final bool selected;

  const _SortChip({
    required this.label,
    required this.order,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<TodoBloc>().add(ChangeSortOrderEvent(order));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF7C4DFF).withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF7C4DFF).withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF7C4DFF) : Colors.white.withValues(alpha: 0.5),
            fontSize: 10,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
