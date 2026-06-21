import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';

class SubtaskList extends StatelessWidget {
  final Task task;

  const SubtaskList({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    if (task.subtasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 36.0, top: 4.0, bottom: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsets.only(left: 12.0),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: task.subtasks.length,
          itemBuilder: (context, index) {
            final sub = task.subtasks[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  SizedBox(
                    height: 18,
                    width: 18,
                    child: Checkbox(
                      value: sub.isCompleted,
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
                        context.read<TodoBloc>().add(
                              ToggleSubtaskEvent(
                                taskId: task.id,
                                subtaskId: sub.id,
                              ),
                            );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sub.title,
                      style: TextStyle(
                        color: sub.isCompleted
                            ? Colors.white.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                        decoration: sub.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
