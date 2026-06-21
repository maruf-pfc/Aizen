import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import 'subtask_list.dart';

class TaskRow extends StatelessWidget {
  final Task task;

  const TaskRow({super.key, required this.task});

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return const Color(0xFFFF5252); // Red
      case 2:
        return const Color(0xFFFFAB40); // Amber
      case 3:
        return const Color(0xFF40C4FF); // Blue
      default:
        return Colors.white.withValues(alpha: 0.1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(task.priority);

    return Dismissible(
      key: Key('task_dismiss_${task.id}'),
      direction: DismissDirection.horizontal,
      background: Container(
        color: const Color(0xFF00E676).withValues(alpha: 0.15),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20.0),
        child: const Icon(Icons.check, color: Color(0xFF00E676), size: 20),
      ),
      secondaryBackground: Container(
        color: const Color(0xFFFF5252).withValues(alpha: 0.15),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete_outline, color: Color(0xFFFF5252), size: 20),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe Right: Toggle complete
          context.read<TodoBloc>().add(ToggleTodoEvent(task.id));
          return false; // Don't actually dismiss (remove from widget tree)
        } else if (direction == DismissDirection.endToStart) {
          // Swipe Left: Delete
          context.read<TodoBloc>().add(DeleteTodoEvent(task.id));
          return true; // Let it dismiss
        }
        return false;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0C0C0C),
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(
                  color: priorityColor,
                  width: 3,
                ),
                top: BorderSide(color: Colors.white.withValues(alpha: 0.03)),
                right: BorderSide(color: Colors.white.withValues(alpha: 0.03)),
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.03)),
              ),
            ),
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Row(
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: Checkbox(
                    value: task.isCompleted,
                    activeColor: const Color(0xFF7C4DFF),
                    checkColor: Colors.black,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (_) {
                      context.read<TodoBloc>().add(ToggleTodoEvent(task.id));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          color: task.isCompleted
                              ? Colors.white.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      if (task.tags.isNotEmpty || task.dueDate != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (task.dueDate != null) ...[
                              Icon(
                                Icons.calendar_today,
                                color: task.isCompleted
                                    ? Colors.white.withValues(alpha: 0.15)
                                    : const Color(0xFF00E676),
                                size: 10,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${task.dueDate!.month}/${task.dueDate!.day} ${task.dueDate!.hour.toString().padLeft(2, '0')}:${task.dueDate!.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: task.isCompleted
                                      ? Colors.white.withValues(alpha: 0.15)
                                      : const Color(0xFF00E676),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (task.tags.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '•',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ],
                            ...task.tags.map((tag) => Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: Text(
                                    '#${tag.name}',
                                    style: TextStyle(
                                      color: task.isCompleted
                                          ? Colors.white.withValues(alpha: 0.15)
                                          : const Color(0xFF7C4DFF),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          SubtaskList(task: task),
        ],
      ),
    );
  }
}
